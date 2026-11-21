with Ada.Containers.Ordered_Maps;
with Ada.Containers.Vectors;
with Rose.Interfaces.Objects;
with Rose.Invocation;
with Rose.System_Calls;
with Rose.Words;
with System;

package body Rose.Interfaces.Lease.Server is

   type Object_Access is access all Lease_Interface'Class;

   type Attached_Object is record
      Object     : Object_Access;
      Identifier : Rose.Objects.Capability_Identifier := 0;
      Cap        : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
      Retired    : Boolean := False;
   end record;

   package Attached_Vectors is
     new Ada.Containers.Vectors (Natural, Attached_Object);

   package Address_Maps is
     new Ada.Containers.Ordered_Maps
       (System.Address, Natural, System."<");

   package Identifier_Maps is
     new Ada.Containers.Ordered_Maps
       (Rose.Objects.Capability_Identifier, Natural,
        Rose.Objects."<");

   type Attached_Table is
     new Rose.Server.Interface_Table with
      record
         Attached        : Attached_Vectors.Vector;
         By_Address      : Address_Maps.Map;
         By_Identifier   : Identifier_Maps.Map;
         Server_Instance : Rose.Server.Server_Instance;
      end record;

   type Table_Access is access all Attached_Table;

   function Table_Of
     (Server_Context : Rose.Server.Server_Context)
      return Table_Access;

   function Find
     (Server_Context : Rose.Server.Server_Context;
      Identifier     : Rose.Objects.Capability_Identifier)
      return Object_Access;

   function Owns
     (Server_Context : Rose.Server.Server_Context;
      Identifier     : Rose.Objects.Capability_Identifier)
      return Boolean;

   function Free_Slot (Table : not null Table_Access) return Natural;

   function Slot_Of
     (Table      : not null Table_Access;
      Identifier : Rose.Objects.Capability_Identifier)
      return Natural;

   procedure Detach
     (Server_Context : Rose.Server.Server_Context;
      Identifier     : Rose.Objects.Capability_Identifier);

   procedure Handle_Get_Named_Interface
     (Server_Context : in out Rose.Server.Server_Context;
      Parameters     : in out Rose.Invocation.Invocation_Record);

   procedure Handle_Get_Counter_Interface
     (Server_Context : in out Rose.Server.Server_Context;
      Parameters     : in out Rose.Invocation.Invocation_Record);

   procedure Handle_Get_Resource_Interface
     (Server_Context : in out Rose.Server.Server_Context;
      Parameters     : in out Rose.Invocation.Invocation_Record);

   procedure Handle_Get_Lease_Interface
     (Server_Context : in out Rose.Server.Server_Context;
      Parameters     : in out Rose.Invocation.Invocation_Record);

   procedure Handle_Badge
     (Server_Context : in out Rose.Server.Server_Context;
      Parameters     : in out Rose.Invocation.Invocation_Record);

   procedure Handle_Increment
     (Server_Context : in out Rose.Server.Server_Context;
      Parameters     : in out Rose.Invocation.Invocation_Record);

   procedure Handle_Value
     (Server_Context : in out Rose.Server.Server_Context;
      Parameters     : in out Rose.Invocation.Invocation_Record);

   procedure Handle_Release
     (Server_Context : in out Rose.Server.Server_Context;
      Parameters     : in out Rose.Invocation.Invocation_Record);

   procedure Handle_Remaining
     (Server_Context : in out Rose.Server.Server_Context;
      Parameters     : in out Rose.Invocation.Invocation_Record);

   ------------
   -- Attach --
   ------------

   procedure Attach
     (Server_Context : in out Rose.Server.Server_Context;
      Object         : not null access Lease_Interface'Class;
      Identifier     : Rose.Objects.Capability_Identifier := 0)
   is
      use type Rose.Objects.Capability_Identifier;
      Table : Table_Access := Table_Of (Server_Context);
      Slot  : Natural;
   begin
      if Table = null then
         Table := new Attached_Table;
         Rose.Server.Add_Table
           (Server_Context,
            Rose.Interfaces.Lease.Lease_Interface,
            Rose.Server.Interface_Table_Access (Table));
         Rose.Server.Register_Context_Handler
           (Server_Context,
            Rose.Interfaces.Lease.Named_Interface,
            Handle_Get_Named_Interface'Access,
            Owns'Access);
         Rose.Server.Register_Context_Handler
           (Server_Context,
            Rose.Interfaces.Lease.Counter_Interface,
            Handle_Get_Counter_Interface'Access,
            Owns'Access);
         Rose.Server.Register_Context_Handler
           (Server_Context,
            Rose.Interfaces.Lease.Resource_Interface,
            Handle_Get_Resource_Interface'Access,
            Owns'Access);
         Rose.Server.Register_Context_Handler
           (Server_Context,
            Rose.Interfaces.Lease.Lease_Interface,
            Handle_Get_Lease_Interface'Access,
            Owns'Access);
         Rose.Server.Register_Context_Handler
           (Server_Context,
            Badge_Endpoint,
            Handle_Badge'Access,
            Owns'Access);
         Rose.Server.Register_Context_Handler
           (Server_Context,
            Increment_Endpoint,
            Handle_Increment'Access,
            Owns'Access);
         Rose.Server.Register_Context_Handler
           (Server_Context,
            Value_Endpoint,
            Handle_Value'Access,
            Owns'Access);
         Rose.Server.Register_Context_Handler
           (Server_Context,
            Release_Endpoint,
            Handle_Release'Access,
            Owns'Access);
         Rose.Server.Register_Context_Handler
           (Server_Context,
            Remaining_Endpoint,
            Handle_Remaining'Access,
            Owns'Access);
      end if;
      Slot := Free_Slot (Table);
      if Slot = Natural (Table.Attached.Length) then
         Table.Attached.Append (Attached_Object'(others => <>));
      end if;
      Table.Attached (Slot).Object := Object_Access (Object);
      if Identifier = 0 then
         Table.Attached (Slot).Identifier := Rose.Server.New_Identifier;
      else
         Table.Attached (Slot).Identifier := Identifier;
      end if;
      Table.Attached (Slot).Cap :=
        Rose.Server.Create_Endpoint
          (Rose.Interfaces.Lease.Lease_Interface,
           Table.Attached (Slot).Identifier);
      Table.By_Address.Include (Object.all'Address, Slot);
      Table.By_Identifier.Include (Table.Attached (Slot).Identifier, Slot);
   end Attach;

   ------------
   -- Cap_Of --
   ------------

   function Cap_Of
     (Server_Context : Rose.Server.Server_Context;
      Object         : Lease_Interface'Class;
      Interface_Id   : Rose.Objects.Endpoint_Id :=
        Rose.Interfaces.Lease.Lease_Interface)
      return Rose.Capabilities.Capability
   is
      use type Rose.Objects.Endpoint_Id;
      Table : constant Table_Access := Table_Of (Server_Context);
   begin
      if Table /= null and then Table.By_Address.Contains (Object'Address) then
         declare
            Slot : constant Natural :=
              Table.By_Address.Element (Object'Address);
         begin
            if Interface_Id = Rose.Interfaces.Lease.Lease_Interface then
               return Table.Attached (Slot).Cap;
            else
               if Interface_Id = Rose.Interfaces.Lease.Named_Interface
                 or else Interface_Id = Rose.Interfaces.Lease.Counter_Interface
                 or else Interface_Id = Rose.Interfaces.Lease
                   .Resource_Interface
               then
                  if not Rose.Server.Has_Instance
                    (Table.Server_Instance,
                     Interface_Id,
                     Table.Attached (Slot).Identifier)
                  then
                     Rose.Server.Set_Instance_Cap
                       (Table.Server_Instance,
                        Interface_Id,
                        Table.Attached (Slot).Identifier,
                        Rose.Server.Create_Endpoint
                          (Interface_Id,
                           Table.Attached (Slot).Identifier));
                  end if;
                  return Rose.Server.Get_Instance_Cap
                    (Table.Server_Instance,
                     Interface_Id,
                     Table.Attached (Slot).Identifier);
               end if;
            end if;
         end;
      end if;
      raise Rose.Interfaces.Objects.Not_Served
        with "Rose.Interfaces.Lease.Server.Cap_Of";
   end Cap_Of;

   ------------
   -- Detach --
   ------------

   procedure Detach
     (Server_Context : Rose.Server.Server_Context;
      Identifier     : Rose.Objects.Capability_Identifier)
   is
      use type Rose.Capabilities.Capability;
      use type Rose.Objects.Capability_Identifier;
      Table : constant Table_Access := Table_Of (Server_Context);
      Slot  : constant Natural := Slot_Of (Table, Identifier);
   begin
      if Slot >= Natural (Table.Attached.Length) then
         return;
      end if;
      if Rose.System_Calls.Rescind_Cap_Capability = Rose.Capabilities
        .Null_Capability
      then
         Table.Attached (Slot).Retired := True;
      else
         Rose.System_Calls.Rescind_Cap (Table.Attached (Slot).Cap);
         if Rose.Server.Has_Instance
           (Table.Server_Instance,
            Badge_Endpoint,
            Identifier)
         then
            Rose.System_Calls.Rescind_Cap
              (Rose.Server.Get_Instance_Cap
                 (Table.Server_Instance,
                  Badge_Endpoint,
                  Identifier));
         end if;
         if Rose.Server.Has_Instance
           (Table.Server_Instance,
            Increment_Endpoint,
            Identifier)
         then
            Rose.System_Calls.Rescind_Cap
              (Rose.Server.Get_Instance_Cap
                 (Table.Server_Instance,
                  Increment_Endpoint,
                  Identifier));
         end if;
         if Rose.Server.Has_Instance
           (Table.Server_Instance,
            Value_Endpoint,
            Identifier)
         then
            Rose.System_Calls.Rescind_Cap
              (Rose.Server.Get_Instance_Cap
                 (Table.Server_Instance,
                  Value_Endpoint,
                  Identifier));
         end if;
         if Rose.Server.Has_Instance
           (Table.Server_Instance,
            Release_Endpoint,
            Identifier)
         then
            Rose.System_Calls.Rescind_Cap
              (Rose.Server.Get_Instance_Cap
                 (Table.Server_Instance,
                  Release_Endpoint,
                  Identifier));
         end if;
         if Rose.Server.Has_Instance
           (Table.Server_Instance,
            Remaining_Endpoint,
            Identifier)
         then
            Rose.System_Calls.Rescind_Cap
              (Rose.Server.Get_Instance_Cap
                 (Table.Server_Instance,
                  Remaining_Endpoint,
                  Identifier));
         end if;
         if Rose.Server.Has_Instance
           (Table.Server_Instance,
            Rose.Interfaces.Lease.Named_Interface,
            Identifier)
         then
            Rose.System_Calls.Rescind_Cap
              (Rose.Server.Get_Instance_Cap
                 (Table.Server_Instance,
                  Rose.Interfaces.Lease.Named_Interface,
                  Identifier));
         end if;
         if Rose.Server.Has_Instance
           (Table.Server_Instance,
            Rose.Interfaces.Lease.Counter_Interface,
            Identifier)
         then
            Rose.System_Calls.Rescind_Cap
              (Rose.Server.Get_Instance_Cap
                 (Table.Server_Instance,
                  Rose.Interfaces.Lease.Counter_Interface,
                  Identifier));
         end if;
         if Rose.Server.Has_Instance
           (Table.Server_Instance,
            Rose.Interfaces.Lease.Resource_Interface,
            Identifier)
         then
            Rose.System_Calls.Rescind_Cap
              (Rose.Server.Get_Instance_Cap
                 (Table.Server_Instance,
                  Rose.Interfaces.Lease.Resource_Interface,
                  Identifier));
         end if;
         if Rose.Server.Has_Instance
           (Table.Server_Instance,
            Rose.Interfaces.Lease.Lease_Interface,
            Identifier)
         then
            Rose.System_Calls.Rescind_Cap
              (Rose.Server.Get_Instance_Cap
                 (Table.Server_Instance,
                  Rose.Interfaces.Lease.Lease_Interface,
                  Identifier));
         end if;
         if Identifier /= 0 then
            Rose.Server.Free_Identifier (Identifier);
         end if;
      end if;
      Rose.Server.Remove_Instance (Table.Server_Instance, Identifier);
      Rose.System_Calls.Delete_Cap (Table.Attached (Slot).Cap);
      if Table.Attached (Slot).Object /= null then
         Table.By_Address.Exclude (Table.Attached (Slot).Object.all'Address);
      end if;
      Table.By_Identifier.Exclude (Table.Attached (Slot).Identifier);
      Table.Attached (Slot).Object := null;
      Table.Attached (Slot).Cap := Rose.Capabilities.Null_Capability;
   end Detach;

   ------------
   -- Detach --
   ------------

   procedure Detach
     (Server_Context : Rose.Server.Server_Context;
      Object         : not null access Lease_Interface'Class)
   is
      use type Rose.Objects.Capability_Identifier;
      Identifier : constant Rose.Objects.Capability_Identifier :=
        Identifier_Of (Server_Context, Object);
   begin
      if Identifier /= 0 then
         Detach (Server_Context, Identifier);
      end if;
   end Detach;

   ----------
   -- Find --
   ----------

   function Find
     (Server_Context : Rose.Server.Server_Context;
      Identifier     : Rose.Objects.Capability_Identifier)
      return Object_Access
   is
      use type Rose.Objects.Capability_Identifier;
      Table : constant Table_Access := Table_Of (Server_Context);
   begin
      if Table = null then
         return null;
      end if;
      if Identifier = 0 then
         if Table.Attached.Is_Empty then
            return null;
         end if;
         return Table.Attached (0).Object;
      end if;
      if Table.By_Identifier.Contains (Identifier) then
         declare
            Slot : constant Natural :=
              Table.By_Identifier.Element (Identifier);
         begin
            return Table.Attached (Slot).Object;
         end;
      end if;
      return null;
   end Find;

   ---------------
   -- Free_Slot --
   ---------------

   function Free_Slot (Table : not null Table_Access) return Natural is
      Index : Natural := 0;
   begin
      for Item of Table.Attached loop
         if Item.Object = null and then not Item.Retired then
            return Index;
         end if;
         Index := Index + 1;
      end loop;
      return Natural (Table.Attached.Length);
   end Free_Slot;

   ------------------
   -- Handle_Badge --
   ------------------

   procedure Handle_Badge
     (Server_Context : in out Rose.Server.Server_Context;
      Parameters     : in out Rose.Invocation.Invocation_Record)
   is
   begin
      begin
         declare
            Object : constant Object_Access :=
              Find (Server_Context, Parameters.Identifier);
            Result : Rose.Capabilities.Capability;
         begin
            if Object = null then
               Rose.System_Calls.Initialize_Reply
                 (Parameters,
                  Parameters.Reply_Cap);
               Rose.System_Calls.Send_Error
                 (Parameters,
                  Rose.Invocation.Invalid_Operation);
               return;
            end if;
            Result := Object.Badge;
            Rose.System_Calls.Initialize_Reply
              (Parameters,
               Parameters.Reply_Cap);
            Rose.System_Calls.Send_Cap (Parameters, Result);
         end;
      exception
         when others =>
            Rose.System_Calls.Initialize_Reply
              (Parameters,
               Parameters.Reply_Cap);
            Rose.System_Calls.Send_Error
              (Parameters,
               Rose.Invocation.Exception_Raised);
      end;
   end Handle_Badge;

   ----------------------------------
   -- Handle_Get_Counter_Interface --
   ----------------------------------

   procedure Handle_Get_Counter_Interface
     (Server_Context : in out Rose.Server.Server_Context;
      Parameters     : in out Rose.Invocation.Invocation_Record)
   is
      Cap        : Rose.Capabilities.Capability;
      Identifier : constant Rose.Objects.Capability_Identifier :=
        Parameters.Identifier;
      Table      : constant Table_Access := Table_Of (Server_Context);
      Ancestor   : Natural := 0;
      First      : Natural := 0;
      Page       : Natural := Rose.Invocation.Max_Capabilities;
   begin
      if Parameters.Control.Flags (Rose.Invocation.Send_Words) then
         Ancestor := Natural (Parameters.Data (0));
      end if;
      if Rose.Invocation.Sent_Word_Count (Parameters) >= 2 then
         First := Natural (Parameters.Data (1));
      end if;
      if Rose.Invocation.Sent_Word_Count (Parameters) >= 3 then
         Page := Natural'Min (Page, Natural (Parameters.Data (2)));
      end if;
      Rose.System_Calls.Initialize_Reply (Parameters, Parameters.Reply_Cap);
      if Ancestor = 0 then
         if First >= 3 then
            Rose.System_Calls.Send_Error
              (Parameters,
               Rose.Invocation.Invalid_Operation);
         else
            if 0 in First .. (First + Page - 1) then
               if not Rose.Server.Has_Instance
                 (Table.Server_Instance,
                  Badge_Endpoint,
                  Identifier)
               then
                  Rose.Server.Set_Instance_Cap
                    (Table.Server_Instance,
                     Badge_Endpoint,
                     Identifier,
                     Rose.Server.Create_Endpoint (Badge_Endpoint, Identifier));
               end if;
               Cap :=
                 Rose.Server.Get_Instance_Cap
                   (Table.Server_Instance,
                    Badge_Endpoint,
                    Identifier);
               Rose.System_Calls.Send_Cap (Parameters, Cap);
            end if;
            if 1 in First .. (First + Page - 1) then
               if not Rose.Server.Has_Instance
                 (Table.Server_Instance,
                  Increment_Endpoint,
                  Identifier)
               then
                  Rose.Server.Set_Instance_Cap
                    (Table.Server_Instance,
                     Increment_Endpoint,
                     Identifier,
                     Rose.Server.Create_Endpoint
                       (Increment_Endpoint,
                        Identifier));
               end if;
               Cap :=
                 Rose.Server.Get_Instance_Cap
                   (Table.Server_Instance,
                    Increment_Endpoint,
                    Identifier);
               Rose.System_Calls.Send_Cap (Parameters, Cap);
            end if;
            if 2 in First .. (First + Page - 1) then
               if not Rose.Server.Has_Instance
                 (Table.Server_Instance,
                  Value_Endpoint,
                  Identifier)
               then
                  Rose.Server.Set_Instance_Cap
                    (Table.Server_Instance,
                     Value_Endpoint,
                     Identifier,
                     Rose.Server.Create_Endpoint (Value_Endpoint, Identifier));
               end if;
               Cap :=
                 Rose.Server.Get_Instance_Cap
                   (Table.Server_Instance,
                    Value_Endpoint,
                    Identifier);
               Rose.System_Calls.Send_Cap (Parameters, Cap);
            end if;
         end if;
      else
         if Ancestor = 1 then
            if not Rose.Server.Has_Instance
              (Table.Server_Instance,
               Named_Interface,
               Identifier)
            then
               Rose.Server.Set_Instance_Cap
                 (Table.Server_Instance,
                  Named_Interface,
                  Identifier,
                  Rose.Server.Create_Endpoint (Named_Interface, Identifier));
            end if;
            Rose.System_Calls.Send_Cap
              (Parameters,
               Rose.Server.Get_Instance_Cap
                 (Table.Server_Instance,
                  Named_Interface,
                  Identifier));
         else
            Rose.System_Calls.Send_Error
              (Parameters,
               Rose.Invocation.Invalid_Operation);
         end if;
      end if;
   end Handle_Get_Counter_Interface;

   --------------------------------
   -- Handle_Get_Lease_Interface --
   --------------------------------

   procedure Handle_Get_Lease_Interface
     (Server_Context : in out Rose.Server.Server_Context;
      Parameters     : in out Rose.Invocation.Invocation_Record)
   is
      Cap        : Rose.Capabilities.Capability;
      Identifier : constant Rose.Objects.Capability_Identifier :=
        Parameters.Identifier;
      Table      : constant Table_Access := Table_Of (Server_Context);
      Ancestor   : Natural := 0;
      First      : Natural := 0;
      Page       : Natural := Rose.Invocation.Max_Capabilities;
   begin
      if Parameters.Control.Flags (Rose.Invocation.Send_Words) then
         Ancestor := Natural (Parameters.Data (0));
      end if;
      if Rose.Invocation.Sent_Word_Count (Parameters) >= 2 then
         First := Natural (Parameters.Data (1));
      end if;
      if Rose.Invocation.Sent_Word_Count (Parameters) >= 3 then
         Page := Natural'Min (Page, Natural (Parameters.Data (2)));
      end if;
      Rose.System_Calls.Initialize_Reply (Parameters, Parameters.Reply_Cap);
      if Ancestor = 0 then
         if First >= 5 then
            Rose.System_Calls.Send_Error
              (Parameters,
               Rose.Invocation.Invalid_Operation);
         else
            if 0 in First .. (First + Page - 1) then
               if not Rose.Server.Has_Instance
                 (Table.Server_Instance,
                  Badge_Endpoint,
                  Identifier)
               then
                  Rose.Server.Set_Instance_Cap
                    (Table.Server_Instance,
                     Badge_Endpoint,
                     Identifier,
                     Rose.Server.Create_Endpoint (Badge_Endpoint, Identifier));
               end if;
               Cap :=
                 Rose.Server.Get_Instance_Cap
                   (Table.Server_Instance,
                    Badge_Endpoint,
                    Identifier);
               Rose.System_Calls.Send_Cap (Parameters, Cap);
            end if;
            if 1 in First .. (First + Page - 1) then
               if not Rose.Server.Has_Instance
                 (Table.Server_Instance,
                  Increment_Endpoint,
                  Identifier)
               then
                  Rose.Server.Set_Instance_Cap
                    (Table.Server_Instance,
                     Increment_Endpoint,
                     Identifier,
                     Rose.Server.Create_Endpoint
                       (Increment_Endpoint,
                        Identifier));
               end if;
               Cap :=
                 Rose.Server.Get_Instance_Cap
                   (Table.Server_Instance,
                    Increment_Endpoint,
                    Identifier);
               Rose.System_Calls.Send_Cap (Parameters, Cap);
            end if;
            if 2 in First .. (First + Page - 1) then
               if not Rose.Server.Has_Instance
                 (Table.Server_Instance,
                  Value_Endpoint,
                  Identifier)
               then
                  Rose.Server.Set_Instance_Cap
                    (Table.Server_Instance,
                     Value_Endpoint,
                     Identifier,
                     Rose.Server.Create_Endpoint (Value_Endpoint, Identifier));
               end if;
               Cap :=
                 Rose.Server.Get_Instance_Cap
                   (Table.Server_Instance,
                    Value_Endpoint,
                    Identifier);
               Rose.System_Calls.Send_Cap (Parameters, Cap);
            end if;
            if 3 in First .. (First + Page - 1) then
               if not Rose.Server.Has_Instance
                 (Table.Server_Instance,
                  Release_Endpoint,
                  Identifier)
               then
                  Rose.Server.Set_Instance_Cap
                    (Table.Server_Instance,
                     Release_Endpoint,
                     Identifier,
                     Rose.Server.Create_Endpoint
                       (Release_Endpoint,
                        Identifier));
               end if;
               Cap :=
                 Rose.Server.Get_Instance_Cap
                   (Table.Server_Instance,
                    Release_Endpoint,
                    Identifier);
               Rose.System_Calls.Send_Cap (Parameters, Cap);
            end if;
            if 4 in First .. (First + Page - 1) then
               if not Rose.Server.Has_Instance
                 (Table.Server_Instance,
                  Remaining_Endpoint,
                  Identifier)
               then
                  Rose.Server.Set_Instance_Cap
                    (Table.Server_Instance,
                     Remaining_Endpoint,
                     Identifier,
                     Rose.Server.Create_Endpoint
                       (Remaining_Endpoint,
                        Identifier));
               end if;
               Cap :=
                 Rose.Server.Get_Instance_Cap
                   (Table.Server_Instance,
                    Remaining_Endpoint,
                    Identifier);
               Rose.System_Calls.Send_Cap (Parameters, Cap);
            end if;
         end if;
      else
         if Ancestor = 1 then
            if not Rose.Server.Has_Instance
              (Table.Server_Instance,
               Named_Interface,
               Identifier)
            then
               Rose.Server.Set_Instance_Cap
                 (Table.Server_Instance,
                  Named_Interface,
                  Identifier,
                  Rose.Server.Create_Endpoint (Named_Interface, Identifier));
            end if;
            Rose.System_Calls.Send_Cap
              (Parameters,
               Rose.Server.Get_Instance_Cap
                 (Table.Server_Instance,
                  Named_Interface,
                  Identifier));
         else
            if Ancestor = 2 then
               if not Rose.Server.Has_Instance
                 (Table.Server_Instance,
                  Counter_Interface,
                  Identifier)
               then
                  Rose.Server.Set_Instance_Cap
                    (Table.Server_Instance,
                     Counter_Interface,
                     Identifier,
                     Rose.Server.Create_Endpoint
                       (Counter_Interface,
                        Identifier));
               end if;
               Rose.System_Calls.Send_Cap
                 (Parameters,
                  Rose.Server.Get_Instance_Cap
                    (Table.Server_Instance,
                     Counter_Interface,
                     Identifier));
            else
               if Ancestor = 3 then
                  if not Rose.Server.Has_Instance
                    (Table.Server_Instance,
                     Resource_Interface,
                     Identifier)
                  then
                     Rose.Server.Set_Instance_Cap
                       (Table.Server_Instance,
                        Resource_Interface,
                        Identifier,
                        Rose.Server.Create_Endpoint
                          (Resource_Interface,
                           Identifier));
                  end if;
                  Rose.System_Calls.Send_Cap
                    (Parameters,
                     Rose.Server.Get_Instance_Cap
                       (Table.Server_Instance,
                        Resource_Interface,
                        Identifier));
               else
                  Rose.System_Calls.Send_Error
                    (Parameters,
                     Rose.Invocation.Invalid_Operation);
               end if;
            end if;
         end if;
      end if;
   end Handle_Get_Lease_Interface;

   --------------------------------
   -- Handle_Get_Named_Interface --
   --------------------------------

   procedure Handle_Get_Named_Interface
     (Server_Context : in out Rose.Server.Server_Context;
      Parameters     : in out Rose.Invocation.Invocation_Record)
   is
      Cap        : Rose.Capabilities.Capability;
      Identifier : constant Rose.Objects.Capability_Identifier :=
        Parameters.Identifier;
      Table      : constant Table_Access := Table_Of (Server_Context);
      First      : Natural := 0;
      Page       : Natural := Rose.Invocation.Max_Capabilities;
   begin
      if Rose.Invocation.Sent_Word_Count (Parameters) >= 2 then
         First := Natural (Parameters.Data (1));
      end if;
      if Rose.Invocation.Sent_Word_Count (Parameters) >= 3 then
         Page := Natural'Min (Page, Natural (Parameters.Data (2)));
      end if;
      Rose.System_Calls.Initialize_Reply (Parameters, Parameters.Reply_Cap);
      if First >= 1 then
         Rose.System_Calls.Send_Error
           (Parameters,
            Rose.Invocation.Invalid_Operation);
      else
         if 0 in First .. (First + Page - 1) then
            if not Rose.Server.Has_Instance
              (Table.Server_Instance,
               Badge_Endpoint,
               Identifier)
            then
               Rose.Server.Set_Instance_Cap
                 (Table.Server_Instance,
                  Badge_Endpoint,
                  Identifier,
                  Rose.Server.Create_Endpoint (Badge_Endpoint, Identifier));
            end if;
            Cap :=
              Rose.Server.Get_Instance_Cap
                (Table.Server_Instance,
                 Badge_Endpoint,
                 Identifier);
            Rose.System_Calls.Send_Cap (Parameters, Cap);
         end if;
      end if;
   end Handle_Get_Named_Interface;

   -----------------------------------
   -- Handle_Get_Resource_Interface --
   -----------------------------------

   procedure Handle_Get_Resource_Interface
     (Server_Context : in out Rose.Server.Server_Context;
      Parameters     : in out Rose.Invocation.Invocation_Record)
   is
      Cap        : Rose.Capabilities.Capability;
      Identifier : constant Rose.Objects.Capability_Identifier :=
        Parameters.Identifier;
      Table      : constant Table_Access := Table_Of (Server_Context);
      First      : Natural := 0;
      Page       : Natural := Rose.Invocation.Max_Capabilities;
   begin
      if Rose.Invocation.Sent_Word_Count (Parameters) >= 2 then
         First := Natural (Parameters.Data (1));
      end if;
      if Rose.Invocation.Sent_Word_Count (Parameters) >= 3 then
         Page := Natural'Min (Page, Natural (Parameters.Data (2)));
      end if;
      Rose.System_Calls.Initialize_Reply (Parameters, Parameters.Reply_Cap);
      if First >= 1 then
         Rose.System_Calls.Send_Error
           (Parameters,
            Rose.Invocation.Invalid_Operation);
      else
         if 0 in First .. (First + Page - 1) then
            if not Rose.Server.Has_Instance
              (Table.Server_Instance,
               Release_Endpoint,
               Identifier)
            then
               Rose.Server.Set_Instance_Cap
                 (Table.Server_Instance,
                  Release_Endpoint,
                  Identifier,
                  Rose.Server.Create_Endpoint (Release_Endpoint, Identifier));
            end if;
            Cap :=
              Rose.Server.Get_Instance_Cap
                (Table.Server_Instance,
                 Release_Endpoint,
                 Identifier);
            Rose.System_Calls.Send_Cap (Parameters, Cap);
         end if;
      end if;
   end Handle_Get_Resource_Interface;

   ----------------------
   -- Handle_Increment --
   ----------------------

   procedure Handle_Increment
     (Server_Context : in out Rose.Server.Server_Context;
      Parameters     : in out Rose.Invocation.Invocation_Record)
   is
   begin
      begin
         declare
            Object : constant Object_Access :=
              Find (Server_Context, Parameters.Identifier);
            By     : constant Rose.Words.Word :=
              Rose.System_Calls.Get_Word_32 (Parameters, 0);
         begin
            if Object = null then
               Rose.System_Calls.Initialize_Reply
                 (Parameters,
                  Parameters.Reply_Cap);
               Rose.System_Calls.Send_Error
                 (Parameters,
                  Rose.Invocation.Invalid_Operation);
               return;
            end if;
            Object.Increment (By);
            Rose.System_Calls.Initialize_Reply
              (Parameters,
               Parameters.Reply_Cap);
         end;
      exception
         when others =>
            Rose.System_Calls.Initialize_Reply
              (Parameters,
               Parameters.Reply_Cap);
            Rose.System_Calls.Send_Error
              (Parameters,
               Rose.Invocation.Exception_Raised);
      end;
   end Handle_Increment;

   --------------------
   -- Handle_Release --
   --------------------

   procedure Handle_Release
     (Server_Context : in out Rose.Server.Server_Context;
      Parameters     : in out Rose.Invocation.Invocation_Record)
   is
   begin
      begin
         declare
            Object : constant Object_Access :=
              Find (Server_Context, Parameters.Identifier);
         begin
            if Object = null then
               Rose.System_Calls.Initialize_Reply
                 (Parameters,
                  Parameters.Reply_Cap);
               Rose.System_Calls.Send_Error
                 (Parameters,
                  Rose.Invocation.Invalid_Operation);
               return;
            end if;
            Object.Release;
            Detach (Server_Context, Parameters.Identifier);
            Rose.System_Calls.Initialize_Reply
              (Parameters,
               Parameters.Reply_Cap);
         end;
      exception
         when others =>
            Rose.System_Calls.Initialize_Reply
              (Parameters,
               Parameters.Reply_Cap);
            Rose.System_Calls.Send_Error
              (Parameters,
               Rose.Invocation.Exception_Raised);
      end;
   end Handle_Release;

   ----------------------
   -- Handle_Remaining --
   ----------------------

   procedure Handle_Remaining
     (Server_Context : in out Rose.Server.Server_Context;
      Parameters     : in out Rose.Invocation.Invocation_Record)
   is
   begin
      begin
         declare
            Object : constant Object_Access :=
              Find (Server_Context, Parameters.Identifier);
            Result : Rose.Words.Word;
         begin
            if Object = null then
               Rose.System_Calls.Initialize_Reply
                 (Parameters,
                  Parameters.Reply_Cap);
               Rose.System_Calls.Send_Error
                 (Parameters,
                  Rose.Invocation.Invalid_Operation);
               return;
            end if;
            Result := Object.Remaining;
            Rose.System_Calls.Initialize_Reply
              (Parameters,
               Parameters.Reply_Cap);
            Rose.System_Calls.Send_Word (Parameters, Result);
         end;
      exception
         when others =>
            Rose.System_Calls.Initialize_Reply
              (Parameters,
               Parameters.Reply_Cap);
            Rose.System_Calls.Send_Error
              (Parameters,
               Rose.Invocation.Exception_Raised);
      end;
   end Handle_Remaining;

   ------------------
   -- Handle_Value --
   ------------------

   procedure Handle_Value
     (Server_Context : in out Rose.Server.Server_Context;
      Parameters     : in out Rose.Invocation.Invocation_Record)
   is
   begin
      begin
         declare
            Object : constant Object_Access :=
              Find (Server_Context, Parameters.Identifier);
            Result : Rose.Words.Word;
         begin
            if Object = null then
               Rose.System_Calls.Initialize_Reply
                 (Parameters,
                  Parameters.Reply_Cap);
               Rose.System_Calls.Send_Error
                 (Parameters,
                  Rose.Invocation.Invalid_Operation);
               return;
            end if;
            Result := Object.Value;
            Rose.System_Calls.Initialize_Reply
              (Parameters,
               Parameters.Reply_Cap);
            Rose.System_Calls.Send_Word (Parameters, Result);
         end;
      exception
         when others =>
            Rose.System_Calls.Initialize_Reply
              (Parameters,
               Parameters.Reply_Cap);
            Rose.System_Calls.Send_Error
              (Parameters,
               Rose.Invocation.Exception_Raised);
      end;
   end Handle_Value;

   -------------------
   -- Identifier_Of --
   -------------------

   function Identifier_Of
     (Server_Context : Rose.Server.Server_Context;
      Object         : not null access Lease_Interface'Class)
      return Rose.Objects.Capability_Identifier
   is
      Table : constant Table_Access := Table_Of (Server_Context);
   begin
      if Table /= null and then Table.By_Address.Contains (Object.all'Address)
      then
         declare
            Slot : constant Natural :=
              Table.By_Address.Element (Object.all'Address);
         begin
            return Table.Attached (Slot).Identifier;
         end;
      end if;
      return 0;
   end Identifier_Of;

   -------------------
   -- Interface_Cap --
   -------------------

   function Interface_Cap
     (Server_Context : Rose.Server.Server_Context;
      Object         : not null access Lease_Interface'Class)
      return Rose.Capabilities.Capability
   is
      Table : constant Table_Access := Table_Of (Server_Context);
   begin
      if Table /= null and then Table.By_Address.Contains (Object.all'Address)
      then
         declare
            Slot : constant Natural :=
              Table.By_Address.Element (Object.all'Address);
         begin
            return Table.Attached (Slot).Cap;
         end;
      end if;
      return Rose.Capabilities.Null_Capability;
   end Interface_Cap;

   ----------
   -- Owns --
   ----------

   function Owns
     (Server_Context : Rose.Server.Server_Context;
      Identifier     : Rose.Objects.Capability_Identifier)
      return Boolean
   is (Find (Server_Context, Identifier) /= null);

   -------------
   -- Publish --
   -------------

   procedure Publish
     (Server_Context : in out Rose.Server.Server_Context;
      Object         : not null access Lease_Interface'Class)
   is
   begin
      Attach (Server_Context, Object);
      Rose.Server.Publish_Interface (Interface_Cap (Server_Context, Object));
   end Publish;

   -------------
   -- Slot_Of --
   -------------

   function Slot_Of
     (Table      : not null Table_Access;
      Identifier : Rose.Objects.Capability_Identifier)
      return Natural
   is
      use type Rose.Objects.Capability_Identifier;
   begin
      if Identifier = 0 then
         return 0;
      end if;
      if Table.By_Identifier.Contains (Identifier) then
         return Table.By_Identifier.Element (Identifier);
      end if;
      return Natural (Table.Attached.Length);
   end Slot_Of;

   --------------
   -- Table_Of --
   --------------

   function Table_Of
     (Server_Context : Rose.Server.Server_Context)
      return Table_Access
   is (Table_Access
     (Rose.Server.Table
        (Server_Context,
         Rose.Interfaces.Lease.Lease_Interface)));

end Rose.Interfaces.Lease.Server;
