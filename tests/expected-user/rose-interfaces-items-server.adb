with Ada.Containers.Ordered_Maps;
with Ada.Containers.Vectors;
with Rose.Interfaces.Objects;
with Rose.Invocation;
with Rose.System_Calls;
with Rose.Words;
with System;
with System.Storage_Elements;

package body Rose.Interfaces.Items.Server is

   type Object_Access is access all Items_Interface'Class;

   type Attached_Object is record
      Object     : Object_Access;
      Identifier : Rose.Objects.Capability_Identifier := 0;
      Cap        : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
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

   procedure Handle_Get_Items_Interface
     (Server_Context : in out Rose.Server.Server_Context;
      Parameters     : in out Rose.Invocation.Invocation_Record);

   procedure Handle_Pair
     (Server_Context : in out Rose.Server.Server_Context;
      Parameters     : in out Rose.Invocation.Invocation_Record);

   procedure Handle_Store
     (Server_Context : in out Rose.Server.Server_Context;
      Parameters     : in out Rose.Invocation.Invocation_Record);

   procedure Handle_Single
     (Server_Context : in out Rose.Server.Server_Context;
      Parameters     : in out Rose.Invocation.Invocation_Record);

   ------------
   -- Attach --
   ------------

   procedure Attach
     (Server_Context : in out Rose.Server.Server_Context;
      Object         : not null access Items_Interface'Class;
      Identifier     : Rose.Objects.Capability_Identifier := 0)
   is
      use type Rose.Objects.Capability_Identifier;
      Table : Table_Access := Table_Of (Server_Context);
   begin
      if Table = null then
         Table := new Attached_Table;
         Rose.Server.Add_Table
           (Server_Context,
            Rose.Interfaces.Items.Items_Interface,
            Rose.Server.Interface_Table_Access (Table));
         Rose.Server.Register_Context_Handler
           (Server_Context,
            Rose.Interfaces.Items.Items_Interface,
            Handle_Get_Items_Interface'Access,
            Owns'Access);
         Rose.Server.Register_Context_Handler
           (Server_Context,
            Pair_Endpoint,
            Handle_Pair'Access,
            Owns'Access);
         Rose.Server.Register_Context_Handler
           (Server_Context,
            Store_Endpoint,
            Handle_Store'Access,
            Owns'Access);
         Rose.Server.Register_Context_Handler
           (Server_Context,
            Single_Endpoint,
            Handle_Single'Access,
            Owns'Access);
      end if;
      Table.Attached.Append (Attached_Object'(others => <>));
      Table.Attached (Table.Attached.Last_Index).Object :=
        Object_Access (Object);
      if Identifier = 0 then
         Table.Attached (Table.Attached.Last_Index).Identifier :=
           Rose.Server.New_Identifier;
      else
         Table.Attached (Table.Attached.Last_Index).Identifier := Identifier;
      end if;
      Table.Attached (Table.Attached.Last_Index).Cap :=
        Rose.Server.Create_Endpoint
          (Rose.Interfaces.Items.Items_Interface,
           Table.Attached (Table.Attached.Last_Index).Identifier);
      Table.By_Address.Include (Object.all'Address, Table.Attached.Last_Index);
      Table.By_Identifier.Include
        (Table.Attached (Table.Attached.Last_Index).Identifier,
         Table.Attached.Last_Index);
   end Attach;

   ------------
   -- Cap_Of --
   ------------

   function Cap_Of
     (Server_Context : Rose.Server.Server_Context;
      Object         : Items_Interface'Class;
      Interface_Id   : Rose.Objects.Endpoint_Id :=
        Rose.Interfaces.Items.Items_Interface)
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
            if Interface_Id = Rose.Interfaces.Items.Items_Interface then
               return Table.Attached (Slot).Cap;
            end if;
         end;
      end if;
      raise Rose.Interfaces.Objects.Not_Served
        with "Rose.Interfaces.Items.Server.Cap_Of";
   end Cap_Of;

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

   --------------------------------
   -- Handle_Get_Items_Interface --
   --------------------------------

   procedure Handle_Get_Items_Interface
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
      if First >= 3 then
         Rose.System_Calls.Send_Error
           (Parameters,
            Rose.Invocation.Invalid_Operation);
      else
         if 0 in First .. (First + Page - 1) then
            if not Rose.Server.Has_Instance
              (Table.Server_Instance,
               Pair_Endpoint,
               Identifier)
            then
               Rose.Server.Set_Instance_Cap
                 (Table.Server_Instance,
                  Pair_Endpoint,
                  Identifier,
                  Rose.Server.Create_Endpoint (Pair_Endpoint, Identifier));
            end if;
            Cap :=
              Rose.Server.Get_Instance_Cap
                (Table.Server_Instance,
                 Pair_Endpoint,
                 Identifier);
            Rose.System_Calls.Send_Cap (Parameters, Cap);
         end if;
         if 1 in First .. (First + Page - 1) then
            if not Rose.Server.Has_Instance
              (Table.Server_Instance,
               Store_Endpoint,
               Identifier)
            then
               Rose.Server.Set_Instance_Cap
                 (Table.Server_Instance,
                  Store_Endpoint,
                  Identifier,
                  Rose.Server.Create_Endpoint (Store_Endpoint, Identifier));
            end if;
            Cap :=
              Rose.Server.Get_Instance_Cap
                (Table.Server_Instance,
                 Store_Endpoint,
                 Identifier);
            Rose.System_Calls.Send_Cap (Parameters, Cap);
         end if;
         if 2 in First .. (First + Page - 1) then
            if not Rose.Server.Has_Instance
              (Table.Server_Instance,
               Single_Endpoint,
               Identifier)
            then
               Rose.Server.Set_Instance_Cap
                 (Table.Server_Instance,
                  Single_Endpoint,
                  Identifier,
                  Rose.Server.Create_Endpoint (Single_Endpoint, Identifier));
            end if;
            Cap :=
              Rose.Server.Get_Instance_Cap
                (Table.Server_Instance,
                 Single_Endpoint,
                 Identifier);
            Rose.System_Calls.Send_Cap (Parameters, Cap);
         end if;
      end if;
   end Handle_Get_Items_Interface;

   -----------------
   -- Handle_Pair --
   -----------------

   procedure Handle_Pair
     (Server_Context : in out Rose.Server.Server_Context;
      Parameters     : in out Rose.Invocation.Invocation_Record)
   is
   begin
      begin
         declare
            Object        : constant Object_Access :=
              Find (Server_Context, Parameters.Identifier);
            Name_Item     : constant Rose.System_Calls.Buffer_Item :=
              Rose.System_Calls.Get_Buffer_Item (Parameters, 1);
            Name          : String (1 .. Natural (Name_Item.Length))
              with Import, Address => Name_Item.Address;
            Password_Item : constant Rose.System_Calls.Buffer_Item :=
              Rose.System_Calls.Get_Buffer_Item (Parameters, 2);
            Password      : String (1 .. Natural (Password_Item.Length))
              with Import, Address => Password_Item.Address;
            Result        : Rose.Capabilities.Capability;
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
            Result := Object.Pair (Name, Password);
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
   end Handle_Pair;

   -------------------
   -- Handle_Single --
   -------------------

   procedure Handle_Single
     (Server_Context : in out Rose.Server.Server_Context;
      Parameters     : in out Rose.Invocation.Invocation_Record)
   is
   begin
      begin
         declare
            Object : constant Object_Access :=
              Find (Server_Context, Parameters.Identifier);
            Name   : String
              (1 .. Natural (Rose.Invocation.Sent_Buffer_Length (Parameters)))
              with Import, Address => Parameters.Buffer_Address;
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
            Object.Single (Name);
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
   end Handle_Single;

   ------------------
   -- Handle_Store --
   ------------------

   procedure Handle_Store
     (Server_Context : in out Rose.Server.Server_Context;
      Parameters     : in out Rose.Invocation.Invocation_Record)
   is
      Received       : Rose.Capabilities.Capability_Array
        (1 .. Rose.Invocation.Max_Capabilities);
      Received_Count : constant Natural :=
        Rose.System_Calls.Copy_Received_Caps (Parameters, 0, Received);
   begin
      begin
         declare
            Object    : constant Object_Access :=
              Find (Server_Context, Parameters.Identifier);
            Index     : constant Rose.Words.Word :=
              Rose.System_Calls.Get_Word_32 (Parameters, 0);
            Key_Item  : constant Rose.System_Calls.Buffer_Item :=
              Rose.System_Calls.Get_Buffer_Item (Parameters, 1);
            Key       : String (1 .. Natural (Key_Item.Length))
              with Import, Address => Key_Item.Address;
            Data_Item : constant Rose.System_Calls.Buffer_Item :=
              Rose.System_Calls.Get_Buffer_Item (Parameters, 2);
            Data      : System.Storage_Elements.Storage_Array
              (1 .. Data_Item.Length)
              with Import, Address => Data_Item.Address;
            Owner     : constant Rose.Capabilities.Capability :=
              Rose.Invocation.Sent_Cap (Parameters, 0);
         begin
            if Object = null then
               for Cap of Received (1 .. Received_Count) loop
                  Rose.System_Calls.Delete_Cap (Cap);
               end loop;
               Rose.System_Calls.Initialize_Reply
                 (Parameters,
                  Parameters.Reply_Cap);
               Rose.System_Calls.Send_Error
                 (Parameters,
                  Rose.Invocation.Invalid_Operation);
               return;
            end if;
            Object.Store (Index, Key, Data, Owner);
            Rose.System_Calls.Initialize_Reply
              (Parameters,
               Parameters.Reply_Cap);
         end;
      exception
         when others =>
            for Cap of Received (1 .. Received_Count) loop
               Rose.System_Calls.Delete_Cap (Cap);
            end loop;
            Rose.System_Calls.Initialize_Reply
              (Parameters,
               Parameters.Reply_Cap);
            Rose.System_Calls.Send_Error
              (Parameters,
               Rose.Invocation.Exception_Raised);
      end;
   end Handle_Store;

   -------------------
   -- Identifier_Of --
   -------------------

   function Identifier_Of
     (Server_Context : Rose.Server.Server_Context;
      Object         : not null access Items_Interface'Class)
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
      Object         : not null access Items_Interface'Class)
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
      Object         : not null access Items_Interface'Class)
   is
   begin
      Attach (Server_Context, Object);
      Rose.Server.Publish_Interface (Interface_Cap (Server_Context, Object));
   end Publish;

   --------------
   -- Table_Of --
   --------------

   function Table_Of
     (Server_Context : Rose.Server.Server_Context)
      return Table_Access
   is (Table_Access
     (Rose.Server.Table
        (Server_Context,
         Rose.Interfaces.Items.Items_Interface)));

end Rose.Interfaces.Items.Server;
