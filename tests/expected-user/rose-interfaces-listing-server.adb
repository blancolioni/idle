with Ada.Containers.Ordered_Maps;
with Ada.Containers.Vectors;
with Rose.Interfaces.Objects;
with Rose.Invocation;
with Rose.System_Calls;
with System;
with System.Storage_Elements;

package body Rose.Interfaces.Listing.Server is

   type Object_Access is access all Listing_Interface'Class;

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

   procedure Handle_Get_Listing_Interface
     (Server_Context : in out Rose.Server.Server_Context;
      Parameters     : in out Rose.Invocation.Invocation_Record);

   procedure Handle_Add
     (Server_Context : in out Rose.Server.Server_Context;
      Parameters     : in out Rose.Invocation.Invocation_Record);

   procedure Handle_Rename
     (Server_Context : in out Rose.Server.Server_Context;
      Parameters     : in out Rose.Invocation.Invocation_Record);

   procedure Handle_Find
     (Server_Context : in out Rose.Server.Server_Context;
      Parameters     : in out Rose.Invocation.Invocation_Record);

   procedure Handle_Get
     (Server_Context : in out Rose.Server.Server_Context;
      Parameters     : in out Rose.Invocation.Invocation_Record);

   procedure Handle_Now
     (Server_Context : in out Rose.Server.Server_Context;
      Parameters     : in out Rose.Invocation.Invocation_Record);

   ------------
   -- Attach --
   ------------

   procedure Attach
     (Server_Context : in out Rose.Server.Server_Context;
      Object         : not null access Listing_Interface'Class;
      Identifier     : Rose.Objects.Capability_Identifier := 0)
   is
      use type Rose.Objects.Capability_Identifier;
      Table : Table_Access := Table_Of (Server_Context);
   begin
      if Table = null then
         Table := new Attached_Table;
         Rose.Server.Add_Table
           (Server_Context,
            Rose.Interfaces.Listing.Listing_Interface,
            Rose.Server.Interface_Table_Access (Table));
         Rose.Server.Register_Context_Handler
           (Server_Context,
            Rose.Interfaces.Listing.Listing_Interface,
            Handle_Get_Listing_Interface'Access,
            Owns'Access);
         Rose.Server.Register_Context_Handler
           (Server_Context,
            Add_Endpoint,
            Handle_Add'Access,
            Owns'Access);
         Rose.Server.Register_Context_Handler
           (Server_Context,
            Rename_Endpoint,
            Handle_Rename'Access,
            Owns'Access);
         Rose.Server.Register_Context_Handler
           (Server_Context,
            Find_Endpoint,
            Handle_Find'Access,
            Owns'Access);
         Rose.Server.Register_Context_Handler
           (Server_Context,
            Get_Endpoint,
            Handle_Get'Access,
            Owns'Access);
         Rose.Server.Register_Context_Handler
           (Server_Context,
            Now_Endpoint,
            Handle_Now'Access,
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
          (Rose.Interfaces.Listing.Listing_Interface,
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
      Object         : Listing_Interface'Class;
      Interface_Id   : Rose.Objects.Endpoint_Id :=
        Rose.Interfaces.Listing.Listing_Interface)
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
            if Interface_Id = Rose.Interfaces.Listing.Listing_Interface then
               return Table.Attached (Slot).Cap;
            end if;
         end;
      end if;
      raise Rose.Interfaces.Objects.Not_Served
        with "Rose.Interfaces.Listing.Server.Cap_Of";
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

   ----------------
   -- Handle_Add --
   ----------------

   procedure Handle_Add
     (Server_Context : in out Rose.Server.Server_Context;
      Parameters     : in out Rose.Invocation.Invocation_Record)
   is
   begin
      begin
         declare
            Object      : constant Object_Access :=
              Find (Server_Context, Parameters.Identifier);
            Info_Buffer : System.Storage_Elements.Storage_Array
              (1 .. Rose.Invocation.Sent_Buffer_Length (Parameters))
              with Import, Address => Parameters.Buffer_Address;
            Info        : constant Rose.Interfaces.Listing.File_Info :=
              Rose.Interfaces.Listing.Decode (Info_Buffer);
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
            Object.Add (Info);
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
   end Handle_Add;

   -----------------
   -- Handle_Find --
   -----------------

   procedure Handle_Find
     (Server_Context : in out Rose.Server.Server_Context;
      Parameters     : in out Rose.Invocation.Invocation_Record)
   is
   begin
      begin
         declare
            Object        : constant Object_Access :=
              Find (Server_Context, Parameters.Identifier);
            Index         : constant Natural :=
              Natural (Rose.System_Calls.Get_Word_32 (Parameters, 0));
            Result_Buffer : System.Storage_Elements.Storage_Array
              (1 .. Rose.Invocation.Sent_Buffer_Length (Parameters))
              with Import, Address => Parameters.Buffer_Address;
            Result_Last   : System.Storage_Elements.Storage_Offset := 0;
            Result        : Rose.Interfaces.Listing.File_Info;
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
            Result := Object.Find (Index);
            Rose.Interfaces.Listing.Encode
              (Result,
               Result_Buffer,
               Result_Last);
            Rose.System_Calls.Initialize_Reply
              (Parameters,
               Parameters.Reply_Cap);
            Rose.System_Calls.Send_Word (Parameters, Natural (Result_Last));
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
   end Handle_Find;

   ----------------
   -- Handle_Get --
   ----------------

   procedure Handle_Get
     (Server_Context : in out Rose.Server.Server_Context;
      Parameters     : in out Rose.Invocation.Invocation_Record)
   is
   begin
      begin
         declare
            Object      : constant Object_Access :=
              Find (Server_Context, Parameters.Identifier);
            Index       : constant Natural :=
              Natural (Rose.System_Calls.Get_Word_32 (Parameters, 0));
            Info_Buffer : System.Storage_Elements.Storage_Array
              (1 .. Rose.Invocation.Sent_Buffer_Length (Parameters))
              with Import, Address => Parameters.Buffer_Address;
            Info        : Rose.Interfaces.Listing.File_Info;
            Info_Last   : System.Storage_Elements.Storage_Offset := 0;
            Count       : Natural;
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
            Object.Get (Index, Info, Count);
            Rose.Interfaces.Listing.Encode (Info, Info_Buffer, Info_Last);
            Rose.System_Calls.Initialize_Reply
              (Parameters,
               Parameters.Reply_Cap);
            Rose.System_Calls.Send_Word (Parameters, Natural (Info_Last));
            Rose.System_Calls.Send_Word (Parameters, Count);
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
   end Handle_Get;

   ----------------------------------
   -- Handle_Get_Listing_Interface --
   ----------------------------------

   procedure Handle_Get_Listing_Interface
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
      if First >= 5 then
         Rose.System_Calls.Send_Error
           (Parameters,
            Rose.Invocation.Invalid_Operation);
      else
         if 0 in First .. (First + Page - 1) then
            if not Rose.Server.Has_Instance
              (Table.Server_Instance,
               Add_Endpoint,
               Identifier)
            then
               Rose.Server.Set_Instance_Cap
                 (Table.Server_Instance,
                  Add_Endpoint,
                  Identifier,
                  Rose.Server.Create_Endpoint (Add_Endpoint, Identifier));
            end if;
            Cap :=
              Rose.Server.Get_Instance_Cap
                (Table.Server_Instance,
                 Add_Endpoint,
                 Identifier);
            Rose.System_Calls.Send_Cap (Parameters, Cap);
         end if;
         if 1 in First .. (First + Page - 1) then
            if not Rose.Server.Has_Instance
              (Table.Server_Instance,
               Rename_Endpoint,
               Identifier)
            then
               Rose.Server.Set_Instance_Cap
                 (Table.Server_Instance,
                  Rename_Endpoint,
                  Identifier,
                  Rose.Server.Create_Endpoint (Rename_Endpoint, Identifier));
            end if;
            Cap :=
              Rose.Server.Get_Instance_Cap
                (Table.Server_Instance,
                 Rename_Endpoint,
                 Identifier);
            Rose.System_Calls.Send_Cap (Parameters, Cap);
         end if;
         if 2 in First .. (First + Page - 1) then
            if not Rose.Server.Has_Instance
              (Table.Server_Instance,
               Find_Endpoint,
               Identifier)
            then
               Rose.Server.Set_Instance_Cap
                 (Table.Server_Instance,
                  Find_Endpoint,
                  Identifier,
                  Rose.Server.Create_Endpoint (Find_Endpoint, Identifier));
            end if;
            Cap :=
              Rose.Server.Get_Instance_Cap
                (Table.Server_Instance,
                 Find_Endpoint,
                 Identifier);
            Rose.System_Calls.Send_Cap (Parameters, Cap);
         end if;
         if 3 in First .. (First + Page - 1) then
            if not Rose.Server.Has_Instance
              (Table.Server_Instance,
               Get_Endpoint,
               Identifier)
            then
               Rose.Server.Set_Instance_Cap
                 (Table.Server_Instance,
                  Get_Endpoint,
                  Identifier,
                  Rose.Server.Create_Endpoint (Get_Endpoint, Identifier));
            end if;
            Cap :=
              Rose.Server.Get_Instance_Cap
                (Table.Server_Instance,
                 Get_Endpoint,
                 Identifier);
            Rose.System_Calls.Send_Cap (Parameters, Cap);
         end if;
         if 4 in First .. (First + Page - 1) then
            if not Rose.Server.Has_Instance
              (Table.Server_Instance,
               Now_Endpoint,
               Identifier)
            then
               Rose.Server.Set_Instance_Cap
                 (Table.Server_Instance,
                  Now_Endpoint,
                  Identifier,
                  Rose.Server.Create_Endpoint (Now_Endpoint, Identifier));
            end if;
            Cap :=
              Rose.Server.Get_Instance_Cap
                (Table.Server_Instance,
                 Now_Endpoint,
                 Identifier);
            Rose.System_Calls.Send_Cap (Parameters, Cap);
         end if;
      end if;
   end Handle_Get_Listing_Interface;

   ----------------
   -- Handle_Now --
   ----------------

   procedure Handle_Now
     (Server_Context : in out Rose.Server.Server_Context;
      Parameters     : in out Rose.Invocation.Invocation_Record)
   is
   begin
      begin
         declare
            Object        : constant Object_Access :=
              Find (Server_Context, Parameters.Identifier);
            Result_Buffer : System.Storage_Elements.Storage_Array
              (1 .. Rose.Invocation.Sent_Buffer_Length (Parameters))
              with Import, Address => Parameters.Buffer_Address;
            Result_Last   : System.Storage_Elements.Storage_Offset := 0;
            Result        : Rose.Interfaces.Listing.Stamp;
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
            Result := Object.Now;
            Rose.Interfaces.Listing.Encode
              (Result,
               Result_Buffer,
               Result_Last);
            Rose.System_Calls.Initialize_Reply
              (Parameters,
               Parameters.Reply_Cap);
            Rose.System_Calls.Send_Word (Parameters, Natural (Result_Last));
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
   end Handle_Now;

   -------------------
   -- Handle_Rename --
   -------------------

   procedure Handle_Rename
     (Server_Context : in out Rose.Server.Server_Context;
      Parameters     : in out Rose.Invocation.Invocation_Record)
   is
   begin
      begin
         declare
            Object           : constant Object_Access :=
              Find (Server_Context, Parameters.Identifier);
            Info_Buffer_Item : constant Rose.System_Calls.Buffer_Item :=
              Rose.System_Calls.Get_Buffer_Item (Parameters, 1);
            Info_Buffer      : System.Storage_Elements.Storage_Array
              (1 .. Info_Buffer_Item.Length)
              with Import, Address => Info_Buffer_Item.Address;
            Info             : constant Rose.Interfaces.Listing.File_Info :=
              Rose.Interfaces.Listing.Decode (Info_Buffer);
            New_Name_Item    : constant Rose.System_Calls.Buffer_Item :=
              Rose.System_Calls.Get_Buffer_Item (Parameters, 2);
            New_Name         : String (1 .. Natural (New_Name_Item.Length))
              with Import, Address => New_Name_Item.Address;
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
            Object.Rename (Info, New_Name);
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
   end Handle_Rename;

   -------------------
   -- Identifier_Of --
   -------------------

   function Identifier_Of
     (Server_Context : Rose.Server.Server_Context;
      Object         : not null access Listing_Interface'Class)
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
      Object         : not null access Listing_Interface'Class)
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
      Object         : not null access Listing_Interface'Class)
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
         Rose.Interfaces.Listing.Listing_Interface)));

end Rose.Interfaces.Listing.Server;
