with Rose.Interfaces.Exchange.Client;
with Rose.Interfaces.Objects;
with Rose.Invocation;
with Rose.Strings;
with Rose.System_Calls;
with Rose.Words;
with System;

package body Rose.Interfaces.Exchange.Server is

   Server_Instance : Rose.Server.Server_Instance;

   type Object_Access is access all Exchange_Interface'Class;

   type Attached_Object is record
      Object : Object_Access;
      Cap    : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
   end record;

   Max_Attached    : constant := 16;

   type Attached_Array is array (0 .. (Max_Attached - 1)) of Attached_Object;

   Attached        : Attached_Array;

   Attached_Count  : Natural := 0;

   Registered      : Boolean := False;

   function Find
     (Identifier : Rose.Objects.Capability_Identifier)
      return Object_Access;

   procedure Handle_Get_Exchange_Interface
     (Parameters : in out Rose.Invocation.Invocation_Record);

   procedure Handle_Create_Endpoint
     (Parameters : in out Rose.Invocation.Invocation_Record);

   procedure Handle_Split
     (Parameters : in out Rose.Invocation.Invocation_Record);

   procedure Handle_Rename
     (Parameters : in out Rose.Invocation.Invocation_Record);

   procedure Handle_Partner
     (Parameters : in out Rose.Invocation.Invocation_Record);

   procedure Handle_Gather
     (Parameters : in out Rose.Invocation.Invocation_Record);

   ------------
   -- Attach --
   ------------

   procedure Attach
     (Server_Context : in out Rose.Server.Server_Context;
      Object         : not null access Exchange_Interface'Class)
   is
   begin
      if not Registered then
         Rose.Server.Register_Handler
           (Server_Context,
            Rose.Interfaces.Exchange.Exchange_Interface,
            Handle_Get_Exchange_Interface'Access);
         Rose.Server.Register_Handler
           (Server_Context,
            Create_Endpoint_Endpoint,
            Handle_Create_Endpoint'Access);
         Rose.Server.Register_Handler
           (Server_Context,
            Split_Endpoint,
            Handle_Split'Access);
         Rose.Server.Register_Handler
           (Server_Context,
            Rename_Endpoint,
            Handle_Rename'Access);
         Rose.Server.Register_Handler
           (Server_Context,
            Partner_Endpoint,
            Handle_Partner'Access);
         Rose.Server.Register_Handler
           (Server_Context,
            Gather_Endpoint,
            Handle_Gather'Access);
         Registered := True;
      end if;
      if Attached_Count = Max_Attached then
         raise Constraint_Error
           with "Rose.Interfaces.Exchange.Server: too many objects";
      end if;
      Attached (Attached_Count).Object := Object_Access (Object);
      Attached (Attached_Count).Cap :=
        Rose.Server.Create_Endpoint
          (Rose.Interfaces.Exchange.Exchange_Interface,
           Rose.Objects.Capability_Identifier (Attached_Count));
      Attached_Count := Attached_Count + 1;
   end Attach;

   ------------
   -- Cap_Of --
   ------------

   function Cap_Of
     (Object       : Exchange_Interface'Class;
      Interface_Id : Rose.Objects.Endpoint_Id :=
        Rose.Interfaces.Exchange.Exchange_Interface)
      return Rose.Capabilities.Capability
   is
      use type System.Address;
      use type Rose.Objects.Capability_Identifier;
      use type Rose.Objects.Endpoint_Id;
      Identifier : Rose.Objects.Capability_Identifier := 0;
   begin
      for Item of Attached loop
         if Item.Object /= null
           and then Item.Object.all'Address = Object'Address
         then
            if Interface_Id = Rose.Interfaces.Exchange.Exchange_Interface then
               return Item.Cap;
            end if;
         end if;
         Identifier := Identifier + 1;
      end loop;
      raise Rose.Interfaces.Objects.Not_Served
        with "Rose.Interfaces.Exchange.Server.Cap_Of";
   end Cap_Of;

   ----------
   -- Find --
   ----------

   function Find
     (Identifier : Rose.Objects.Capability_Identifier)
      return Object_Access
   is
      use type Rose.Objects.Capability_Identifier;
   begin
      if Identifier >= Rose.Objects.Capability_Identifier (Attached_Count) then
         return null;
      end if;
      return Attached (Natural (Identifier)).Object;
   end Find;

   ----------------------------
   -- Handle_Create_Endpoint --
   ----------------------------

   procedure Handle_Create_Endpoint
     (Parameters : in out Rose.Invocation.Invocation_Record)
   is
      Object  : constant Object_Access := Find (Parameters.Identifier);
      Id      : constant Rose.Words.Word_64 :=
        Rose.System_Calls.Get_Word_64 (Parameters, 0);
      Receive : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
      Send    : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
   begin
      if Object = null then
         Rose.System_Calls.Initialize_Reply (Parameters, Parameters.Reply_Cap);
         Rose.System_Calls.Send_Error
           (Parameters,
            Rose.Invocation.Invalid_Operation);
         return;
      end if;
      Object.Create_Endpoint (Id, Receive, Send);
      Rose.System_Calls.Initialize_Reply (Parameters, Parameters.Reply_Cap);
      Rose.System_Calls.Send_Cap (Parameters, Receive);
      Rose.System_Calls.Send_Cap (Parameters, Send);
   end Handle_Create_Endpoint;

   -------------------
   -- Handle_Gather --
   -------------------

   procedure Handle_Gather
     (Parameters : in out Rose.Invocation.Invocation_Record)
   is
      Object     : constant Object_Access := Find (Parameters.Identifier);
      Caps       : Rose.Capabilities.Capability_Array
        (1 .. Rose.Invocation.Max_Capabilities);
      Caps_Count : constant Natural :=
        Rose.System_Calls.Copy_Received_Caps (Parameters, 0, Caps);
      First      : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
   begin
      if Object = null then
         Rose.System_Calls.Initialize_Reply (Parameters, Parameters.Reply_Cap);
         Rose.System_Calls.Send_Error
           (Parameters,
            Rose.Invocation.Invalid_Operation);
         return;
      end if;
      Object.Gather (Caps (1 .. Caps_Count), First);
      Rose.System_Calls.Initialize_Reply (Parameters, Parameters.Reply_Cap);
      Rose.System_Calls.Send_Cap (Parameters, First);
   end Handle_Gather;

   -----------------------------------
   -- Handle_Get_Exchange_Interface --
   -----------------------------------

   procedure Handle_Get_Exchange_Interface
     (Parameters : in out Rose.Invocation.Invocation_Record)
   is
      Cap        : Rose.Capabilities.Capability;
      Identifier : constant Rose.Objects.Capability_Identifier :=
        Parameters.Identifier;
   begin
      Rose.System_Calls.Initialize_Reply (Parameters, Parameters.Reply_Cap);
      if not Rose.Server.Has_Instance
        (Server_Instance,
         Create_Endpoint_Endpoint,
         Identifier)
      then
         Rose.Server.Set_Instance_Cap
           (Server_Instance,
            Create_Endpoint_Endpoint,
            Identifier,
            Rose.Server.Create_Endpoint
              (Create_Endpoint_Endpoint,
               Identifier));
      end if;
      Cap :=
        Rose.Server.Get_Instance_Cap
          (Server_Instance,
           Create_Endpoint_Endpoint,
           Identifier);
      Rose.System_Calls.Send_Cap (Parameters, Cap);
      if not Rose.Server.Has_Instance
        (Server_Instance,
         Split_Endpoint,
         Identifier)
      then
         Rose.Server.Set_Instance_Cap
           (Server_Instance,
            Split_Endpoint,
            Identifier,
            Rose.Server.Create_Endpoint (Split_Endpoint, Identifier));
      end if;
      Cap :=
        Rose.Server.Get_Instance_Cap
          (Server_Instance,
           Split_Endpoint,
           Identifier);
      Rose.System_Calls.Send_Cap (Parameters, Cap);
      if not Rose.Server.Has_Instance
        (Server_Instance,
         Rename_Endpoint,
         Identifier)
      then
         Rose.Server.Set_Instance_Cap
           (Server_Instance,
            Rename_Endpoint,
            Identifier,
            Rose.Server.Create_Endpoint (Rename_Endpoint, Identifier));
      end if;
      Cap :=
        Rose.Server.Get_Instance_Cap
          (Server_Instance,
           Rename_Endpoint,
           Identifier);
      Rose.System_Calls.Send_Cap (Parameters, Cap);
      if not Rose.Server.Has_Instance
        (Server_Instance,
         Partner_Endpoint,
         Identifier)
      then
         Rose.Server.Set_Instance_Cap
           (Server_Instance,
            Partner_Endpoint,
            Identifier,
            Rose.Server.Create_Endpoint (Partner_Endpoint, Identifier));
      end if;
      Cap :=
        Rose.Server.Get_Instance_Cap
          (Server_Instance,
           Partner_Endpoint,
           Identifier);
      Rose.System_Calls.Send_Cap (Parameters, Cap);
      if not Rose.Server.Has_Instance
        (Server_Instance,
         Gather_Endpoint,
         Identifier)
      then
         Rose.Server.Set_Instance_Cap
           (Server_Instance,
            Gather_Endpoint,
            Identifier,
            Rose.Server.Create_Endpoint (Gather_Endpoint, Identifier));
      end if;
      Cap :=
        Rose.Server.Get_Instance_Cap
          (Server_Instance,
           Gather_Endpoint,
           Identifier);
      Rose.System_Calls.Send_Cap (Parameters, Cap);
   end Handle_Get_Exchange_Interface;

   --------------------
   -- Handle_Partner --
   --------------------

   procedure Handle_Partner
     (Parameters : in out Rose.Invocation.Invocation_Record)
   is
      Object       : constant Object_Access := Find (Parameters.Identifier);
      Other        : Rose.Interfaces.Exchange.Client.Exchange_Client;
      Label_Buffer : String (1 .. Natural (Parameters.Buffer_Length))
        with Import, Address => Parameters.Buffer_Address;
      Label        : Rose.Strings.Text;
      Label_Last   : Natural := 0;
   begin
      if Object = null then
         Rose.System_Calls.Initialize_Reply (Parameters, Parameters.Reply_Cap);
         Rose.System_Calls.Send_Error
           (Parameters,
            Rose.Invocation.Invalid_Operation);
         return;
      end if;
      Object.Partner (Other, Label);
      Rose.System_Calls.Initialize_Reply (Parameters, Parameters.Reply_Cap);
      Rose.System_Calls.Send_Cap (Parameters, Other.Exchange_Cap);
      Rose.Strings.Copy (Label, Label_Buffer, Label_Last);
      Rose.System_Calls.Send_Word (Parameters, Label_Last);
   end Handle_Partner;

   -------------------
   -- Handle_Rename --
   -------------------

   procedure Handle_Rename
     (Parameters : in out Rose.Invocation.Invocation_Record)
   is
      Object      : constant Object_Access := Find (Parameters.Identifier);
      Cap         : Rose.Capabilities.Capability := Parameters.Caps (0);
      Name_Buffer : String (1 .. Natural (Parameters.Buffer_Length))
        with Import, Address => Parameters.Buffer_Address;
      Name        : Rose.Strings.Text := Rose.Strings.To_Text (Name_Buffer);
      Name_Last   : Natural := 0;
   begin
      if Object = null then
         Rose.System_Calls.Initialize_Reply (Parameters, Parameters.Reply_Cap);
         Rose.System_Calls.Send_Error
           (Parameters,
            Rose.Invocation.Invalid_Operation);
         return;
      end if;
      Object.Rename (Cap, Name);
      Rose.System_Calls.Initialize_Reply (Parameters, Parameters.Reply_Cap);
      Rose.System_Calls.Send_Cap (Parameters, Cap);
      Rose.Strings.Copy (Name, Name_Buffer, Name_Last);
      Rose.System_Calls.Send_Word (Parameters, Name_Last);
   end Handle_Rename;

   ------------------
   -- Handle_Split --
   ------------------

   procedure Handle_Split
     (Parameters : in out Rose.Invocation.Invocation_Record)
   is
      Object : constant Object_Access := Find (Parameters.Identifier);
      Whole  : constant Rose.Capabilities.Capability := Parameters.Caps (0);
      Part   : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
      Result : Rose.Capabilities.Capability;
   begin
      if Object = null then
         Rose.System_Calls.Initialize_Reply (Parameters, Parameters.Reply_Cap);
         Rose.System_Calls.Send_Error
           (Parameters,
            Rose.Invocation.Invalid_Operation);
         return;
      end if;
      Result := Object.Split (Whole, Part);
      Rose.System_Calls.Initialize_Reply (Parameters, Parameters.Reply_Cap);
      Rose.System_Calls.Send_Cap (Parameters, Part);
      Rose.System_Calls.Send_Cap (Parameters, Result);
   end Handle_Split;

   -------------------
   -- Interface_Cap --
   -------------------

   function Interface_Cap
     (Object : not null access Exchange_Interface'Class)
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

   -------------
   -- Publish --
   -------------

   procedure Publish
     (Server_Context : in out Rose.Server.Server_Context;
      Object         : not null access Exchange_Interface'Class)
   is
   begin
      Attach (Server_Context, Object);
      Rose.Server.Publish_Interface (Interface_Cap (Object));
   end Publish;

end Rose.Interfaces.Exchange.Server;
