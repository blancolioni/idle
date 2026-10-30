with Rose.Invocation;
with Rose.System_Calls;

package body Rose.Interfaces.Exchange.Server is

   Server_Instance       : Rose.Server.Server_Instance;

   Local_Create_Endpoint : Create_Endpoint_Handler;

   Create_Endpoint_Cap   : Rose.Capabilities.Capability :=
     Rose.Capabilities.Null_Capability;

   Local_Split           : Split_Handler;

   Split_Cap             : Rose.Capabilities.Capability :=
     Rose.Capabilities.Null_Capability;

   Local_Rename          : Rename_Handler;

   Rename_Cap            : Rose.Capabilities.Capability :=
     Rose.Capabilities.Null_Capability;

   Local_Partner         : Partner_Handler;

   Partner_Cap           : Rose.Capabilities.Capability :=
     Rose.Capabilities.Null_Capability;

   Local_Gather          : Gather_Handler;

   Gather_Cap            : Rose.Capabilities.Capability :=
     Rose.Capabilities.Null_Capability;

   Published_Cap         : Rose.Capabilities.Capability :=
     Rose.Capabilities.Null_Capability;

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

   ----------------------
   -- Attach_Interface --
   ----------------------

   procedure Attach_Interface
     (Server_Context  : in out Rose.Server.Server_Context;
      Create_Endpoint : Create_Endpoint_Handler;
      Split           : Split_Handler;
      Rename          : Rename_Handler;
      Partner         : Partner_Handler;
      Gather          : Gather_Handler;
      Instanced       : Boolean := False)
   is
   begin
      Local_Create_Endpoint := Create_Endpoint;
      Local_Split := Split;
      Local_Rename := Rename;
      Local_Partner := Partner;
      Local_Gather := Gather;
      Rose.Server.Register_Handler
        (Server_Context,
         Exchange_Interface,
         Handle_Get_Exchange_Interface'Access);
      if not Instanced then
         Create_Endpoint_Cap :=
           Rose.Server.Create_Endpoint (Create_Endpoint_Endpoint);
         Split_Cap := Rose.Server.Create_Endpoint (Split_Endpoint);
         Rename_Cap := Rose.Server.Create_Endpoint (Rename_Endpoint);
         Partner_Cap := Rose.Server.Create_Endpoint (Partner_Endpoint);
         Gather_Cap := Rose.Server.Create_Endpoint (Gather_Endpoint);
         Rose.Server.Create_Anonymous_Endpoint (Exchange_Interface);
      end if;
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
   end Attach_Interface;

   -------------------
   -- Create_Server --
   -------------------

   procedure Create_Server
     (Server_Context  : in out Rose.Server.Server_Context;
      Create_Endpoint : Create_Endpoint_Handler;
      Split           : Split_Handler;
      Rename          : Rename_Handler;
      Partner         : Partner_Handler;
      Gather          : Gather_Handler;
      Instanced       : Boolean := False)
   is
   begin
      Attach_Interface
        (Server_Context,
         Create_Endpoint,
         Split,
         Rename,
         Partner,
         Gather,
         Instanced);
   end Create_Server;

   -----------------------------
   -- Get_Create_Endpoint_Cap --
   -----------------------------

   function Get_Create_Endpoint_Cap
      return Rose.Capabilities.Capability
   is (Create_Endpoint_Cap);

   --------------------
   -- Get_Gather_Cap --
   --------------------

   function Get_Gather_Cap return Rose.Capabilities.Capability is (Gather_Cap);

   ---------------------
   -- Get_Partner_Cap --
   ---------------------

   function Get_Partner_Cap
      return Rose.Capabilities.Capability
   is (Partner_Cap);

   --------------------
   -- Get_Rename_Cap --
   --------------------

   function Get_Rename_Cap return Rose.Capabilities.Capability is (Rename_Cap);

   -------------------
   -- Get_Split_Cap --
   -------------------

   function Get_Split_Cap return Rose.Capabilities.Capability is (Split_Cap);

   ----------------------------
   -- Handle_Create_Endpoint --
   ----------------------------

   procedure Handle_Create_Endpoint
     (Parameters : in out Rose.Invocation.Invocation_Record)
   is
   begin
      declare
         Id      : constant Rose.Words.Word_64 :=
           Rose.System_Calls.Get_Word_64 (Parameters, 0);
         Receive : Rose.Capabilities.Capability :=
           Rose.Capabilities.Null_Capability;
         Send    : Rose.Capabilities.Capability :=
           Rose.Capabilities.Null_Capability;
      begin
         Local_Create_Endpoint (Parameters.Identifier, Id, Receive, Send);
         Rose.System_Calls.Initialize_Reply (Parameters, Parameters.Reply_Cap);
         Rose.System_Calls.Send_Cap (Parameters, Receive);
         Rose.System_Calls.Send_Cap (Parameters, Send);
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

   -------------------
   -- Handle_Gather --
   -------------------

   procedure Handle_Gather
     (Parameters : in out Rose.Invocation.Invocation_Record)
   is
   begin
      declare
         Caps       : Rose.Capabilities.Capability_Array
           (1 .. Rose.Invocation.Max_Capabilities);
         Caps_Count : constant Natural :=
           Rose.System_Calls.Copy_Received_Caps (Parameters, 0, Caps);
         First      : Rose.Capabilities.Capability :=
           Rose.Capabilities.Null_Capability;
      begin
         Local_Gather (Parameters.Identifier, Caps (1 .. Caps_Count), First);
         Rose.System_Calls.Initialize_Reply (Parameters, Parameters.Reply_Cap);
         Rose.System_Calls.Send_Cap (Parameters, First);
      exception
         when others =>
            Rose.System_Calls.Initialize_Reply
              (Parameters,
               Parameters.Reply_Cap);
            Rose.System_Calls.Send_Error
              (Parameters,
               Rose.Invocation.Exception_Raised);
      end;
   end Handle_Gather;

   -----------------------------------
   -- Handle_Get_Exchange_Interface --
   -----------------------------------

   procedure Handle_Get_Exchange_Interface
     (Parameters : in out Rose.Invocation.Invocation_Record)
   is
      use type Rose.Capabilities.Capability;
      Cap        : Rose.Capabilities.Capability;
      Identifier : constant Rose.Objects.Capability_Identifier :=
        Parameters.Identifier;
   begin
      Rose.System_Calls.Initialize_Reply (Parameters, Parameters.Reply_Cap);
      if Create_Endpoint_Cap = Rose.Capabilities.Null_Capability then
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
      else
         Cap := Create_Endpoint_Cap;
      end if;
      Rose.System_Calls.Send_Cap (Parameters, Cap);
      if Split_Cap = Rose.Capabilities.Null_Capability then
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
      else
         Cap := Split_Cap;
      end if;
      Rose.System_Calls.Send_Cap (Parameters, Cap);
      if Rename_Cap = Rose.Capabilities.Null_Capability then
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
      else
         Cap := Rename_Cap;
      end if;
      Rose.System_Calls.Send_Cap (Parameters, Cap);
      if Partner_Cap = Rose.Capabilities.Null_Capability then
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
      else
         Cap := Partner_Cap;
      end if;
      Rose.System_Calls.Send_Cap (Parameters, Cap);
      if Gather_Cap = Rose.Capabilities.Null_Capability then
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
      else
         Cap := Gather_Cap;
      end if;
      Rose.System_Calls.Send_Cap (Parameters, Cap);
   end Handle_Get_Exchange_Interface;

   --------------------
   -- Handle_Partner --
   --------------------

   procedure Handle_Partner
     (Parameters : in out Rose.Invocation.Invocation_Record)
   is
   begin
      declare
         Other      : Rose.Capabilities.Capability :=
           Rose.Capabilities.Null_Capability;
         Label      : String (1 .. Natural (Parameters.Buffer_Length))
           with Import, Address => Parameters.Buffer_Address;
         Label_Last : Natural := 0;
      begin
         Local_Partner (Parameters.Identifier, Other, Label, Label_Last);
         Rose.System_Calls.Initialize_Reply (Parameters, Parameters.Reply_Cap);
         Rose.System_Calls.Send_Cap (Parameters, Other);
         Rose.System_Calls.Send_Word (Parameters, Label_Last);
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
     (Parameters : in out Rose.Invocation.Invocation_Record)
   is
   begin
      declare
         Cap       : Rose.Capabilities.Capability := Parameters.Caps (0);
         Name      : String (1 .. Natural (Parameters.Buffer_Length))
           with Import, Address => Parameters.Buffer_Address;
         Name_Last : Natural := 0;
      begin
         Local_Rename (Parameters.Identifier, Cap, Name, Name_Last);
         Rose.System_Calls.Initialize_Reply (Parameters, Parameters.Reply_Cap);
         Rose.System_Calls.Send_Cap (Parameters, Cap);
         Rose.System_Calls.Send_Word (Parameters, Name_Last);
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

   ------------------
   -- Handle_Split --
   ------------------

   procedure Handle_Split
     (Parameters : in out Rose.Invocation.Invocation_Record)
   is
   begin
      declare
         Whole  : constant Rose.Capabilities.Capability := Parameters.Caps (0);
         Part   : Rose.Capabilities.Capability :=
           Rose.Capabilities.Null_Capability;
         Result : constant Rose.Capabilities.Capability :=
           Local_Split (Parameters.Identifier, Whole, Part);
      begin
         Rose.System_Calls.Initialize_Reply (Parameters, Parameters.Reply_Cap);
         Rose.System_Calls.Send_Cap (Parameters, Part);
         Rose.System_Calls.Send_Cap (Parameters, Result);
      exception
         when others =>
            Rose.System_Calls.Initialize_Reply
              (Parameters,
               Parameters.Reply_Cap);
            Rose.System_Calls.Send_Error
              (Parameters,
               Rose.Invocation.Exception_Raised);
      end;
   end Handle_Split;

   -----------------------
   -- Publish_Interface --
   -----------------------

   procedure Publish_Interface
     (Server_Context  : in out Rose.Server.Server_Context;
      Create_Endpoint : Create_Endpoint_Handler;
      Split           : Split_Handler;
      Rename          : Rename_Handler;
      Partner         : Partner_Handler;
      Gather          : Gather_Handler)
   is
   begin
      Local_Create_Endpoint := Create_Endpoint;
      Local_Split := Split;
      Local_Rename := Rename;
      Local_Partner := Partner;
      Local_Gather := Gather;
      Create_Endpoint_Cap :=
        Rose.Server.Create_Endpoint (Create_Endpoint_Endpoint);
      Split_Cap := Rose.Server.Create_Endpoint (Split_Endpoint);
      Rename_Cap := Rose.Server.Create_Endpoint (Rename_Endpoint);
      Partner_Cap := Rose.Server.Create_Endpoint (Partner_Endpoint);
      Gather_Cap := Rose.Server.Create_Endpoint (Gather_Endpoint);
      Published_Cap := Rose.Server.Create_Endpoint (Exchange_Interface);
      Rose.Server.Register_Handler
        (Server_Context,
         Exchange_Interface,
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
      Rose.Server.Publish_Interface (Published_Cap);
   end Publish_Interface;

   ---------------------
   -- Remove_Instance --
   ---------------------

   procedure Remove_Instance
     (Identifier : Rose.Objects.Capability_Identifier)
   is
   begin
      Rose.Server.Remove_Instance (Server_Instance, Identifier);
   end Remove_Instance;

end Rose.Interfaces.Exchange.Server;
