with Ada.Containers.Vectors;
with Rose.Interfaces.Objects;
with Rose.Invocation;
with Rose.System_Calls;
with Rose.Words;
with System;

package body Rose.Interfaces.Lease.Server is

   Server_Instance : Rose.Server.Server_Instance;

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

   Attached        : Attached_Vectors.Vector;

   Registered      : Boolean := False;

   function Find
     (Identifier : Rose.Objects.Capability_Identifier)
      return Object_Access;

   function Owns
     (Identifier : Rose.Objects.Capability_Identifier)
      return Boolean;

   function Free_Slot return Natural;

   function Slot_Of
     (Identifier : Rose.Objects.Capability_Identifier)
      return Natural;

   procedure Detach (Identifier : Rose.Objects.Capability_Identifier);

   procedure Handle_Get_Named_Interface
     (Parameters : in out Rose.Invocation.Invocation_Record);

   procedure Handle_Get_Counter_Interface
     (Parameters : in out Rose.Invocation.Invocation_Record);

   procedure Handle_Get_Resource_Interface
     (Parameters : in out Rose.Invocation.Invocation_Record);

   procedure Handle_Get_Lease_Interface
     (Parameters : in out Rose.Invocation.Invocation_Record);

   procedure Handle_Badge
     (Parameters : in out Rose.Invocation.Invocation_Record);

   procedure Handle_Increment
     (Parameters : in out Rose.Invocation.Invocation_Record);

   procedure Handle_Value
     (Parameters : in out Rose.Invocation.Invocation_Record);

   procedure Handle_Release
     (Parameters : in out Rose.Invocation.Invocation_Record);

   procedure Handle_Remaining
     (Parameters : in out Rose.Invocation.Invocation_Record);

   ------------
   -- Attach --
   ------------

   procedure Attach
     (Server_Context : in out Rose.Server.Server_Context;
      Object         : not null access Lease_Interface'Class)
   is
      Slot : constant Natural := Free_Slot;
   begin
      if not Registered then
         Rose.Server.Register_Handler
           (Server_Context,
            Rose.Interfaces.Lease.Named_Interface,
            Handle_Get_Named_Interface'Access,
            Owns'Access);
         Rose.Server.Register_Handler
           (Server_Context,
            Rose.Interfaces.Lease.Counter_Interface,
            Handle_Get_Counter_Interface'Access,
            Owns'Access);
         Rose.Server.Register_Handler
           (Server_Context,
            Rose.Interfaces.Lease.Resource_Interface,
            Handle_Get_Resource_Interface'Access,
            Owns'Access);
         Rose.Server.Register_Handler
           (Server_Context,
            Rose.Interfaces.Lease.Lease_Interface,
            Handle_Get_Lease_Interface'Access,
            Owns'Access);
         Rose.Server.Register_Handler
           (Server_Context,
            Badge_Endpoint,
            Handle_Badge'Access,
            Owns'Access);
         Rose.Server.Register_Handler
           (Server_Context,
            Increment_Endpoint,
            Handle_Increment'Access,
            Owns'Access);
         Rose.Server.Register_Handler
           (Server_Context,
            Value_Endpoint,
            Handle_Value'Access,
            Owns'Access);
         Rose.Server.Register_Handler
           (Server_Context,
            Release_Endpoint,
            Handle_Release'Access,
            Owns'Access);
         Rose.Server.Register_Handler
           (Server_Context,
            Remaining_Endpoint,
            Handle_Remaining'Access,
            Owns'Access);
         Registered := True;
      end if;
      if Slot = Natural (Attached.Length) then
         Attached.Append (Attached_Object'(others => <>));
      end if;
      Attached (Slot).Object := Object_Access (Object);
      Attached (Slot).Identifier := Rose.Server.New_Identifier;
      Attached (Slot).Cap :=
        Rose.Server.Create_Endpoint
          (Rose.Interfaces.Lease.Lease_Interface,
           Attached (Slot).Identifier);
   end Attach;

   ------------
   -- Cap_Of --
   ------------

   function Cap_Of
     (Object       : Lease_Interface'Class;
      Interface_Id : Rose.Objects.Endpoint_Id :=
        Rose.Interfaces.Lease.Lease_Interface)
      return Rose.Capabilities.Capability
   is
      use type System.Address;
      use type Rose.Objects.Endpoint_Id;
   begin
      for Item of Attached loop
         if Item.Object /= null
           and then Item.Object.all'Address = Object'Address
         then
            if Interface_Id = Rose.Interfaces.Lease.Lease_Interface then
               return Item.Cap;
            else
               if Interface_Id = Rose.Interfaces.Lease.Named_Interface
                 or else Interface_Id = Rose.Interfaces.Lease.Counter_Interface
                 or else Interface_Id = Rose.Interfaces.Lease
                   .Resource_Interface
               then
                  if not Rose.Server.Has_Instance
                    (Server_Instance,
                     Interface_Id,
                     Item.Identifier)
                  then
                     Rose.Server.Set_Instance_Cap
                       (Server_Instance,
                        Interface_Id,
                        Item.Identifier,
                        Rose.Server.Create_Endpoint
                          (Interface_Id,
                           Item.Identifier));
                  end if;
                  return Rose.Server.Get_Instance_Cap
                    (Server_Instance,
                     Interface_Id,
                     Item.Identifier);
               end if;
            end if;
         end if;
      end loop;
      raise Rose.Interfaces.Objects.Not_Served
        with "Rose.Interfaces.Lease.Server.Cap_Of";
   end Cap_Of;

   ------------
   -- Detach --
   ------------

   procedure Detach (Identifier : Rose.Objects.Capability_Identifier) is
      use type Rose.Capabilities.Capability;
      use type Rose.Objects.Capability_Identifier;
      Slot : constant Natural := Slot_Of (Identifier);
   begin
      if Slot >= Natural (Attached.Length) then
         return;
      end if;
      if Rose.System_Calls.Rescind_Cap_Capability = Rose.Capabilities
        .Null_Capability
      then
         Attached (Slot).Retired := True;
      else
         Rose.System_Calls.Rescind_Cap (Attached (Slot).Cap);
         if Rose.Server.Has_Instance
           (Server_Instance,
            Badge_Endpoint,
            Identifier)
         then
            Rose.System_Calls.Rescind_Cap
              (Rose.Server.Get_Instance_Cap
                 (Server_Instance,
                  Badge_Endpoint,
                  Identifier));
         end if;
         if Rose.Server.Has_Instance
           (Server_Instance,
            Increment_Endpoint,
            Identifier)
         then
            Rose.System_Calls.Rescind_Cap
              (Rose.Server.Get_Instance_Cap
                 (Server_Instance,
                  Increment_Endpoint,
                  Identifier));
         end if;
         if Rose.Server.Has_Instance
           (Server_Instance,
            Value_Endpoint,
            Identifier)
         then
            Rose.System_Calls.Rescind_Cap
              (Rose.Server.Get_Instance_Cap
                 (Server_Instance,
                  Value_Endpoint,
                  Identifier));
         end if;
         if Rose.Server.Has_Instance
           (Server_Instance,
            Release_Endpoint,
            Identifier)
         then
            Rose.System_Calls.Rescind_Cap
              (Rose.Server.Get_Instance_Cap
                 (Server_Instance,
                  Release_Endpoint,
                  Identifier));
         end if;
         if Rose.Server.Has_Instance
           (Server_Instance,
            Remaining_Endpoint,
            Identifier)
         then
            Rose.System_Calls.Rescind_Cap
              (Rose.Server.Get_Instance_Cap
                 (Server_Instance,
                  Remaining_Endpoint,
                  Identifier));
         end if;
         if Rose.Server.Has_Instance
           (Server_Instance,
            Rose.Interfaces.Lease.Named_Interface,
            Identifier)
         then
            Rose.System_Calls.Rescind_Cap
              (Rose.Server.Get_Instance_Cap
                 (Server_Instance,
                  Rose.Interfaces.Lease.Named_Interface,
                  Identifier));
         end if;
         if Rose.Server.Has_Instance
           (Server_Instance,
            Rose.Interfaces.Lease.Counter_Interface,
            Identifier)
         then
            Rose.System_Calls.Rescind_Cap
              (Rose.Server.Get_Instance_Cap
                 (Server_Instance,
                  Rose.Interfaces.Lease.Counter_Interface,
                  Identifier));
         end if;
         if Rose.Server.Has_Instance
           (Server_Instance,
            Rose.Interfaces.Lease.Resource_Interface,
            Identifier)
         then
            Rose.System_Calls.Rescind_Cap
              (Rose.Server.Get_Instance_Cap
                 (Server_Instance,
                  Rose.Interfaces.Lease.Resource_Interface,
                  Identifier));
         end if;
         if Rose.Server.Has_Instance
           (Server_Instance,
            Rose.Interfaces.Lease.Lease_Interface,
            Identifier)
         then
            Rose.System_Calls.Rescind_Cap
              (Rose.Server.Get_Instance_Cap
                 (Server_Instance,
                  Rose.Interfaces.Lease.Lease_Interface,
                  Identifier));
         end if;
         if Identifier /= 0 then
            Rose.Server.Free_Identifier (Identifier);
         end if;
      end if;
      Rose.Server.Remove_Instance (Server_Instance, Identifier);
      Rose.System_Calls.Delete_Cap (Attached (Slot).Cap);
      Attached (Slot).Object := null;
      Attached (Slot).Cap := Rose.Capabilities.Null_Capability;
   end Detach;

   ----------
   -- Find --
   ----------

   function Find
     (Identifier : Rose.Objects.Capability_Identifier)
      return Object_Access
   is
      use type Rose.Objects.Capability_Identifier;
   begin
      if Identifier = 0 then
         if Attached.Is_Empty then
            return null;
         end if;
         return Attached (0).Object;
      end if;
      for Item of Attached loop
         if Item.Object /= null and then Item.Identifier = Identifier then
            return Item.Object;
         end if;
      end loop;
      return null;
   end Find;

   ---------------
   -- Free_Slot --
   ---------------

   function Free_Slot return Natural is
      Index : Natural := 0;
   begin
      for Item of Attached loop
         if Item.Object = null and then not Item.Retired then
            return Index;
         end if;
         Index := Index + 1;
      end loop;
      return Natural (Attached.Length);
   end Free_Slot;

   ------------------
   -- Handle_Badge --
   ------------------

   procedure Handle_Badge
     (Parameters : in out Rose.Invocation.Invocation_Record)
   is
   begin
      begin
         declare
            Object : constant Object_Access := Find (Parameters.Identifier);
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
     (Parameters : in out Rose.Invocation.Invocation_Record)
   is
      Cap        : Rose.Capabilities.Capability;
      Identifier : constant Rose.Objects.Capability_Identifier :=
        Parameters.Identifier;
      Ancestor   : Natural := 0;
   begin
      if Parameters.Control.Flags (Rose.Invocation.Send_Words) then
         Ancestor := Natural (Parameters.Data (0));
      end if;
      Rose.System_Calls.Initialize_Reply (Parameters, Parameters.Reply_Cap);
      if Ancestor = 0 then
         if not Rose.Server.Has_Instance
           (Server_Instance,
            Badge_Endpoint,
            Identifier)
         then
            Rose.Server.Set_Instance_Cap
              (Server_Instance,
               Badge_Endpoint,
               Identifier,
               Rose.Server.Create_Endpoint (Badge_Endpoint, Identifier));
         end if;
         Cap :=
           Rose.Server.Get_Instance_Cap
             (Server_Instance,
              Badge_Endpoint,
              Identifier);
         Rose.System_Calls.Send_Cap (Parameters, Cap);
         if not Rose.Server.Has_Instance
           (Server_Instance,
            Increment_Endpoint,
            Identifier)
         then
            Rose.Server.Set_Instance_Cap
              (Server_Instance,
               Increment_Endpoint,
               Identifier,
               Rose.Server.Create_Endpoint (Increment_Endpoint, Identifier));
         end if;
         Cap :=
           Rose.Server.Get_Instance_Cap
             (Server_Instance,
              Increment_Endpoint,
              Identifier);
         Rose.System_Calls.Send_Cap (Parameters, Cap);
         if not Rose.Server.Has_Instance
           (Server_Instance,
            Value_Endpoint,
            Identifier)
         then
            Rose.Server.Set_Instance_Cap
              (Server_Instance,
               Value_Endpoint,
               Identifier,
               Rose.Server.Create_Endpoint (Value_Endpoint, Identifier));
         end if;
         Cap :=
           Rose.Server.Get_Instance_Cap
             (Server_Instance,
              Value_Endpoint,
              Identifier);
         Rose.System_Calls.Send_Cap (Parameters, Cap);
      else
         if Ancestor = 1 then
            if not Rose.Server.Has_Instance
              (Server_Instance,
               Named_Interface,
               Identifier)
            then
               Rose.Server.Set_Instance_Cap
                 (Server_Instance,
                  Named_Interface,
                  Identifier,
                  Rose.Server.Create_Endpoint (Named_Interface, Identifier));
            end if;
            Rose.System_Calls.Send_Cap
              (Parameters,
               Rose.Server.Get_Instance_Cap
                 (Server_Instance,
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
     (Parameters : in out Rose.Invocation.Invocation_Record)
   is
      Cap        : Rose.Capabilities.Capability;
      Identifier : constant Rose.Objects.Capability_Identifier :=
        Parameters.Identifier;
      Ancestor   : Natural := 0;
   begin
      if Parameters.Control.Flags (Rose.Invocation.Send_Words) then
         Ancestor := Natural (Parameters.Data (0));
      end if;
      Rose.System_Calls.Initialize_Reply (Parameters, Parameters.Reply_Cap);
      if Ancestor = 0 then
         if not Rose.Server.Has_Instance
           (Server_Instance,
            Badge_Endpoint,
            Identifier)
         then
            Rose.Server.Set_Instance_Cap
              (Server_Instance,
               Badge_Endpoint,
               Identifier,
               Rose.Server.Create_Endpoint (Badge_Endpoint, Identifier));
         end if;
         Cap :=
           Rose.Server.Get_Instance_Cap
             (Server_Instance,
              Badge_Endpoint,
              Identifier);
         Rose.System_Calls.Send_Cap (Parameters, Cap);
         if not Rose.Server.Has_Instance
           (Server_Instance,
            Increment_Endpoint,
            Identifier)
         then
            Rose.Server.Set_Instance_Cap
              (Server_Instance,
               Increment_Endpoint,
               Identifier,
               Rose.Server.Create_Endpoint (Increment_Endpoint, Identifier));
         end if;
         Cap :=
           Rose.Server.Get_Instance_Cap
             (Server_Instance,
              Increment_Endpoint,
              Identifier);
         Rose.System_Calls.Send_Cap (Parameters, Cap);
         if not Rose.Server.Has_Instance
           (Server_Instance,
            Value_Endpoint,
            Identifier)
         then
            Rose.Server.Set_Instance_Cap
              (Server_Instance,
               Value_Endpoint,
               Identifier,
               Rose.Server.Create_Endpoint (Value_Endpoint, Identifier));
         end if;
         Cap :=
           Rose.Server.Get_Instance_Cap
             (Server_Instance,
              Value_Endpoint,
              Identifier);
         Rose.System_Calls.Send_Cap (Parameters, Cap);
         if not Rose.Server.Has_Instance
           (Server_Instance,
            Release_Endpoint,
            Identifier)
         then
            Rose.Server.Set_Instance_Cap
              (Server_Instance,
               Release_Endpoint,
               Identifier,
               Rose.Server.Create_Endpoint (Release_Endpoint, Identifier));
         end if;
         Cap :=
           Rose.Server.Get_Instance_Cap
             (Server_Instance,
              Release_Endpoint,
              Identifier);
         Rose.System_Calls.Send_Cap (Parameters, Cap);
         if not Rose.Server.Has_Instance
           (Server_Instance,
            Remaining_Endpoint,
            Identifier)
         then
            Rose.Server.Set_Instance_Cap
              (Server_Instance,
               Remaining_Endpoint,
               Identifier,
               Rose.Server.Create_Endpoint (Remaining_Endpoint, Identifier));
         end if;
         Cap :=
           Rose.Server.Get_Instance_Cap
             (Server_Instance,
              Remaining_Endpoint,
              Identifier);
         Rose.System_Calls.Send_Cap (Parameters, Cap);
      else
         if Ancestor = 1 then
            if not Rose.Server.Has_Instance
              (Server_Instance,
               Named_Interface,
               Identifier)
            then
               Rose.Server.Set_Instance_Cap
                 (Server_Instance,
                  Named_Interface,
                  Identifier,
                  Rose.Server.Create_Endpoint (Named_Interface, Identifier));
            end if;
            Rose.System_Calls.Send_Cap
              (Parameters,
               Rose.Server.Get_Instance_Cap
                 (Server_Instance,
                  Named_Interface,
                  Identifier));
         else
            if Ancestor = 2 then
               if not Rose.Server.Has_Instance
                 (Server_Instance,
                  Counter_Interface,
                  Identifier)
               then
                  Rose.Server.Set_Instance_Cap
                    (Server_Instance,
                     Counter_Interface,
                     Identifier,
                     Rose.Server.Create_Endpoint
                       (Counter_Interface,
                        Identifier));
               end if;
               Rose.System_Calls.Send_Cap
                 (Parameters,
                  Rose.Server.Get_Instance_Cap
                    (Server_Instance,
                     Counter_Interface,
                     Identifier));
            else
               if Ancestor = 3 then
                  if not Rose.Server.Has_Instance
                    (Server_Instance,
                     Resource_Interface,
                     Identifier)
                  then
                     Rose.Server.Set_Instance_Cap
                       (Server_Instance,
                        Resource_Interface,
                        Identifier,
                        Rose.Server.Create_Endpoint
                          (Resource_Interface,
                           Identifier));
                  end if;
                  Rose.System_Calls.Send_Cap
                    (Parameters,
                     Rose.Server.Get_Instance_Cap
                       (Server_Instance,
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
     (Parameters : in out Rose.Invocation.Invocation_Record)
   is
      Cap        : Rose.Capabilities.Capability;
      Identifier : constant Rose.Objects.Capability_Identifier :=
        Parameters.Identifier;
   begin
      Rose.System_Calls.Initialize_Reply (Parameters, Parameters.Reply_Cap);
      if not Rose.Server.Has_Instance
        (Server_Instance,
         Badge_Endpoint,
         Identifier)
      then
         Rose.Server.Set_Instance_Cap
           (Server_Instance,
            Badge_Endpoint,
            Identifier,
            Rose.Server.Create_Endpoint (Badge_Endpoint, Identifier));
      end if;
      Cap :=
        Rose.Server.Get_Instance_Cap
          (Server_Instance,
           Badge_Endpoint,
           Identifier);
      Rose.System_Calls.Send_Cap (Parameters, Cap);
   end Handle_Get_Named_Interface;

   -----------------------------------
   -- Handle_Get_Resource_Interface --
   -----------------------------------

   procedure Handle_Get_Resource_Interface
     (Parameters : in out Rose.Invocation.Invocation_Record)
   is
      Cap        : Rose.Capabilities.Capability;
      Identifier : constant Rose.Objects.Capability_Identifier :=
        Parameters.Identifier;
   begin
      Rose.System_Calls.Initialize_Reply (Parameters, Parameters.Reply_Cap);
      if not Rose.Server.Has_Instance
        (Server_Instance,
         Release_Endpoint,
         Identifier)
      then
         Rose.Server.Set_Instance_Cap
           (Server_Instance,
            Release_Endpoint,
            Identifier,
            Rose.Server.Create_Endpoint (Release_Endpoint, Identifier));
      end if;
      Cap :=
        Rose.Server.Get_Instance_Cap
          (Server_Instance,
           Release_Endpoint,
           Identifier);
      Rose.System_Calls.Send_Cap (Parameters, Cap);
   end Handle_Get_Resource_Interface;

   ----------------------
   -- Handle_Increment --
   ----------------------

   procedure Handle_Increment
     (Parameters : in out Rose.Invocation.Invocation_Record)
   is
   begin
      begin
         declare
            Object : constant Object_Access := Find (Parameters.Identifier);
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
     (Parameters : in out Rose.Invocation.Invocation_Record)
   is
   begin
      begin
         declare
            Object : constant Object_Access := Find (Parameters.Identifier);
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
            Detach (Parameters.Identifier);
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
     (Parameters : in out Rose.Invocation.Invocation_Record)
   is
   begin
      begin
         declare
            Object : constant Object_Access := Find (Parameters.Identifier);
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
     (Parameters : in out Rose.Invocation.Invocation_Record)
   is
   begin
      begin
         declare
            Object : constant Object_Access := Find (Parameters.Identifier);
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
   -- Interface_Cap --
   -------------------

   function Interface_Cap
     (Object : not null access Lease_Interface'Class)
      return Rose.Capabilities.Capability
   is
   begin
      for Item of Attached loop
         if Item.Object = Object_Access (Object) then
            return Item.Cap;
         end if;
      end loop;
      return Rose.Capabilities.Null_Capability;
   end Interface_Cap;

   ----------
   -- Owns --
   ----------

   function Owns
     (Identifier : Rose.Objects.Capability_Identifier)
      return Boolean
   is
   begin
      return Find (Identifier) /= null;
   end Owns;

   -------------
   -- Publish --
   -------------

   procedure Publish
     (Server_Context : in out Rose.Server.Server_Context;
      Object         : not null access Lease_Interface'Class)
   is
   begin
      Attach (Server_Context, Object);
      Rose.Server.Publish_Interface (Interface_Cap (Object));
   end Publish;

   -------------
   -- Slot_Of --
   -------------

   function Slot_Of
     (Identifier : Rose.Objects.Capability_Identifier)
      return Natural
   is
      use type Rose.Objects.Capability_Identifier;
      Index : Natural := 0;
   begin
      if Identifier = 0 then
         return 0;
      end if;
      for Item of Attached loop
         if Item.Object /= null and then Item.Identifier = Identifier then
            return Index;
         end if;
         Index := Index + 1;
      end loop;
      return Natural (Attached.Length);
   end Slot_Of;

end Rose.Interfaces.Lease.Server;
