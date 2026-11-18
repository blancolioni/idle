with Ada.Containers.Ordered_Maps;
with Ada.Containers.Vectors;
with Rose.Interfaces.Exchange.Client;
with Rose.Interfaces.Objects;
with Rose.Invocation;
with Rose.System_Calls;
with Rose.Texts;
with Rose.Words;
with System;

package body Rose.Interfaces.Exchange.Server is

   type Object_Access is access all Exchange_Interface'Class;

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

   procedure Handle_Get_Exchange_Interface
     (Server_Context : in out Rose.Server.Server_Context;
      Parameters     : in out Rose.Invocation.Invocation_Record);

   procedure Handle_Create_Endpoint
     (Server_Context : in out Rose.Server.Server_Context;
      Parameters     : in out Rose.Invocation.Invocation_Record);

   procedure Handle_Split
     (Server_Context : in out Rose.Server.Server_Context;
      Parameters     : in out Rose.Invocation.Invocation_Record);

   procedure Handle_Rename
     (Server_Context : in out Rose.Server.Server_Context;
      Parameters     : in out Rose.Invocation.Invocation_Record);

   procedure Handle_Partner
     (Server_Context : in out Rose.Server.Server_Context;
      Parameters     : in out Rose.Invocation.Invocation_Record);

   ------------
   -- Attach --
   ------------

   procedure Attach
     (Server_Context : in out Rose.Server.Server_Context;
      Object         : not null access Exchange_Interface'Class;
      Identifier     : Rose.Objects.Capability_Identifier := 0)
   is
      use type Rose.Objects.Capability_Identifier;
      Table : Table_Access := Table_Of (Server_Context);
   begin
      if Table = null then
         Table := new Attached_Table;
         Rose.Server.Add_Table
           (Server_Context,
            Rose.Interfaces.Exchange.Exchange_Interface,
            Rose.Server.Interface_Table_Access (Table));
         Rose.Server.Register_Context_Handler
           (Server_Context,
            Rose.Interfaces.Exchange.Exchange_Interface,
            Handle_Get_Exchange_Interface'Access,
            Owns'Access);
         Rose.Server.Register_Context_Handler
           (Server_Context,
            Create_Endpoint_Endpoint,
            Handle_Create_Endpoint'Access,
            Owns'Access);
         Rose.Server.Register_Context_Handler
           (Server_Context,
            Split_Endpoint,
            Handle_Split'Access,
            Owns'Access);
         Rose.Server.Register_Context_Handler
           (Server_Context,
            Rename_Endpoint,
            Handle_Rename'Access,
            Owns'Access);
         Rose.Server.Register_Context_Handler
           (Server_Context,
            Partner_Endpoint,
            Handle_Partner'Access,
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
          (Rose.Interfaces.Exchange.Exchange_Interface,
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
      Object         : Exchange_Interface'Class;
      Interface_Id   : Rose.Objects.Endpoint_Id :=
        Rose.Interfaces.Exchange.Exchange_Interface)
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
            if Interface_Id = Rose.Interfaces.Exchange.Exchange_Interface then
               return Table.Attached (Slot).Cap;
            end if;
         end;
      end if;
      raise Rose.Interfaces.Objects.Not_Served
        with "Rose.Interfaces.Exchange.Server.Cap_Of";
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

   ----------------------------
   -- Handle_Create_Endpoint --
   ----------------------------

   procedure Handle_Create_Endpoint
     (Server_Context : in out Rose.Server.Server_Context;
      Parameters     : in out Rose.Invocation.Invocation_Record)
   is
   begin
      begin
         declare
            Object  : constant Object_Access :=
              Find (Server_Context, Parameters.Identifier);
            Id      : constant Rose.Words.Word_64 :=
              Rose.System_Calls.Get_Word_64 (Parameters, 0);
            Receive : Rose.Capabilities.Capability :=
              Rose.Capabilities.Null_Capability;
            Send    : Rose.Capabilities.Capability :=
              Rose.Capabilities.Null_Capability;
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
            Object.Create_Endpoint (Id, Receive, Send);
            Rose.System_Calls.Initialize_Reply
              (Parameters,
               Parameters.Reply_Cap);
            Rose.System_Calls.Send_Cap (Parameters, Receive);
            Rose.System_Calls.Send_Cap (Parameters, Send);
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
   end Handle_Create_Endpoint;

   -----------------------------------
   -- Handle_Get_Exchange_Interface --
   -----------------------------------

   procedure Handle_Get_Exchange_Interface
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
      if First >= 4 then
         Rose.System_Calls.Send_Error
           (Parameters,
            Rose.Invocation.Invalid_Operation);
      else
         if 0 in First .. (First + Page - 1) then
            if not Rose.Server.Has_Instance
              (Table.Server_Instance,
               Create_Endpoint_Endpoint,
               Identifier)
            then
               Rose.Server.Set_Instance_Cap
                 (Table.Server_Instance,
                  Create_Endpoint_Endpoint,
                  Identifier,
                  Rose.Server.Create_Endpoint
                    (Create_Endpoint_Endpoint,
                     Identifier));
            end if;
            Cap :=
              Rose.Server.Get_Instance_Cap
                (Table.Server_Instance,
                 Create_Endpoint_Endpoint,
                 Identifier);
            Rose.System_Calls.Send_Cap (Parameters, Cap);
         end if;
         if 1 in First .. (First + Page - 1) then
            if not Rose.Server.Has_Instance
              (Table.Server_Instance,
               Split_Endpoint,
               Identifier)
            then
               Rose.Server.Set_Instance_Cap
                 (Table.Server_Instance,
                  Split_Endpoint,
                  Identifier,
                  Rose.Server.Create_Endpoint (Split_Endpoint, Identifier));
            end if;
            Cap :=
              Rose.Server.Get_Instance_Cap
                (Table.Server_Instance,
                 Split_Endpoint,
                 Identifier);
            Rose.System_Calls.Send_Cap (Parameters, Cap);
         end if;
         if 2 in First .. (First + Page - 1) then
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
         if 3 in First .. (First + Page - 1) then
            if not Rose.Server.Has_Instance
              (Table.Server_Instance,
               Partner_Endpoint,
               Identifier)
            then
               Rose.Server.Set_Instance_Cap
                 (Table.Server_Instance,
                  Partner_Endpoint,
                  Identifier,
                  Rose.Server.Create_Endpoint (Partner_Endpoint, Identifier));
            end if;
            Cap :=
              Rose.Server.Get_Instance_Cap
                (Table.Server_Instance,
                 Partner_Endpoint,
                 Identifier);
            Rose.System_Calls.Send_Cap (Parameters, Cap);
         end if;
      end if;
   end Handle_Get_Exchange_Interface;

   --------------------
   -- Handle_Partner --
   --------------------

   procedure Handle_Partner
     (Server_Context : in out Rose.Server.Server_Context;
      Parameters     : in out Rose.Invocation.Invocation_Record)
   is
   begin
      begin
         declare
            Object       : constant Object_Access :=
              Find (Server_Context, Parameters.Identifier);
            Other        : Rose.Interfaces.Exchange.Client.Exchange_Client;
            Label_Buffer : String (1 .. Natural (Parameters.Buffer_Length))
              with Import, Address => Parameters.Buffer_Address;
            Label        : Rose.Texts.Text;
            Label_Last   : Natural := 0;
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
            Object.Partner (Other, Label);
            Rose.System_Calls.Initialize_Reply
              (Parameters,
               Parameters.Reply_Cap);
            Rose.System_Calls.Send_Cap (Parameters, Other.Exchange_Cap);
            Rose.Texts.Copy (Label, Label_Buffer, Label_Last);
            Rose.System_Calls.Send_Word (Parameters, Label_Last);
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
   end Handle_Partner;

   -------------------
   -- Handle_Rename --
   -------------------

   procedure Handle_Rename
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
            Object      : constant Object_Access :=
              Find (Server_Context, Parameters.Identifier);
            Cap         : Rose.Capabilities.Capability := Parameters.Caps (0);
            Name_Buffer : String (1 .. Natural (Parameters.Buffer_Length))
              with Import, Address => Parameters.Buffer_Address;
            Name        : Rose.Texts.Text := Rose.Texts.To_Text (Name_Buffer);
            Name_Last   : Natural := 0;
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
            Object.Rename (Cap, Name);
            Rose.System_Calls.Initialize_Reply
              (Parameters,
               Parameters.Reply_Cap);
            Rose.System_Calls.Send_Cap (Parameters, Cap);
            Rose.Texts.Copy (Name, Name_Buffer, Name_Last);
            Rose.System_Calls.Send_Word (Parameters, Name_Last);
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
   end Handle_Rename;

   ------------------
   -- Handle_Split --
   ------------------

   procedure Handle_Split
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
            Object : constant Object_Access :=
              Find (Server_Context, Parameters.Identifier);
            Whole  : constant Rose.Capabilities.Capability :=
              Parameters.Caps (0);
            Part   : Rose.Capabilities.Capability :=
              Rose.Capabilities.Null_Capability;
            Result : Rose.Capabilities.Capability;
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
            Result := Object.Split (Whole, Part);
            Rose.System_Calls.Initialize_Reply
              (Parameters,
               Parameters.Reply_Cap);
            Rose.System_Calls.Send_Cap (Parameters, Part);
            Rose.System_Calls.Send_Cap (Parameters, Result);
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
   end Handle_Split;

   -------------------
   -- Identifier_Of --
   -------------------

   function Identifier_Of
     (Server_Context : Rose.Server.Server_Context;
      Object         : not null access Exchange_Interface'Class)
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
      Object         : not null access Exchange_Interface'Class)
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
      Object         : not null access Exchange_Interface'Class)
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
         Rose.Interfaces.Exchange.Exchange_Interface)));

end Rose.Interfaces.Exchange.Server;
