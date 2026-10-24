with Rose.Invocation;
with Rose.System_Calls;

package body Rose.Interfaces.Exec.Server is

   Server_Instance : Rose.Server.Server_Instance;

   Local_Launch    : Launch_Handler;

   Launch_Cap      : Rose.Capabilities.Capability :=
     Rose.Capabilities.Null_Capability;

   Local_Install   : Install_Handler;

   Install_Cap     : Rose.Capabilities.Capability :=
     Rose.Capabilities.Null_Capability;

   Published_Cap   : Rose.Capabilities.Capability :=
     Rose.Capabilities.Null_Capability;

   procedure Handle_Get_Launch_Interface
     (Parameters : in out Rose.Invocation.Invocation_Record);

   procedure Handle_Get_Exec_Interface
     (Parameters : in out Rose.Invocation.Invocation_Record);

   procedure Handle_Launch
     (Parameters : in out Rose.Invocation.Invocation_Record);

   procedure Handle_Install
     (Parameters : in out Rose.Invocation.Invocation_Record);

   ----------------------
   -- Attach_Interface --
   ----------------------

   procedure Attach_Interface
     (Server_Context : in out Rose.Server.Server_Context;
      Launch         : Launch_Handler;
      Install        : Install_Handler;
      Instanced      : Boolean := False)
   is
   begin
      Local_Launch := Launch;
      Local_Install := Install;
      Rose.Server.Register_Handler
        (Server_Context,
         Launch_Interface,
         Handle_Get_Launch_Interface'Access);
      Rose.Server.Register_Handler
        (Server_Context,
         Exec_Interface,
         Handle_Get_Exec_Interface'Access);
      if not Instanced then
         Launch_Cap := Rose.Server.Create_Endpoint (Launch_Endpoint);
         Install_Cap := Rose.Server.Create_Endpoint (Install_Endpoint);
         Rose.Server.Create_Anonymous_Endpoint (Launch_Interface);
         Rose.Server.Create_Anonymous_Endpoint (Exec_Interface);
      end if;
      Rose.Server.Register_Handler
        (Server_Context,
         Launch_Endpoint,
         Handle_Launch'Access);
      Rose.Server.Register_Handler
        (Server_Context,
         Install_Endpoint,
         Handle_Install'Access);
   end Attach_Interface;

   -------------------
   -- Create_Server --
   -------------------

   procedure Create_Server
     (Server_Context : in out Rose.Server.Server_Context;
      Launch         : Launch_Handler;
      Install        : Install_Handler;
      Instanced      : Boolean := False)
   is
   begin
      Attach_Interface (Server_Context, Launch, Install, Instanced);
   end Create_Server;

   ---------------------
   -- Get_Install_Cap --
   ---------------------

   function Get_Install_Cap
      return Rose.Capabilities.Capability
   is (Install_Cap);

   --------------------
   -- Get_Launch_Cap --
   --------------------

   function Get_Launch_Cap return Rose.Capabilities.Capability is (Launch_Cap);

   -------------------------------
   -- Handle_Get_Exec_Interface --
   -------------------------------

   procedure Handle_Get_Exec_Interface
     (Parameters : in out Rose.Invocation.Invocation_Record)
   is
      use type Rose.Capabilities.Capability;
      Cap        : Rose.Capabilities.Capability;
      Identifier : constant Rose.Objects.Capability_Identifier :=
        Parameters.Identifier;
   begin
      Rose.System_Calls.Initialize_Reply (Parameters, Parameters.Reply_Cap);
      if Launch_Cap = Rose.Capabilities.Null_Capability then
         if not Rose.Server.Has_Instance
           (Server_Instance,
            Launch_Endpoint,
            Identifier)
         then
            Rose.Server.Set_Instance_Cap
              (Server_Instance,
               Launch_Endpoint,
               Identifier,
               Rose.Server.Create_Endpoint (Launch_Endpoint, Identifier));
         end if;
         Cap :=
           Rose.Server.Get_Instance_Cap
             (Server_Instance,
              Launch_Endpoint,
              Identifier);
      else
         Cap := Launch_Cap;
      end if;
      Rose.System_Calls.Send_Cap (Parameters, Cap);
      if Install_Cap = Rose.Capabilities.Null_Capability then
         if not Rose.Server.Has_Instance
           (Server_Instance,
            Install_Endpoint,
            Identifier)
         then
            Rose.Server.Set_Instance_Cap
              (Server_Instance,
               Install_Endpoint,
               Identifier,
               Rose.Server.Create_Endpoint (Install_Endpoint, Identifier));
         end if;
         Cap :=
           Rose.Server.Get_Instance_Cap
             (Server_Instance,
              Install_Endpoint,
              Identifier);
      else
         Cap := Install_Cap;
      end if;
      Rose.System_Calls.Send_Cap (Parameters, Cap);
   end Handle_Get_Exec_Interface;

   ---------------------------------
   -- Handle_Get_Launch_Interface --
   ---------------------------------

   procedure Handle_Get_Launch_Interface
     (Parameters : in out Rose.Invocation.Invocation_Record)
   is
      use type Rose.Capabilities.Capability;
      Cap        : Rose.Capabilities.Capability;
      Identifier : constant Rose.Objects.Capability_Identifier :=
        Parameters.Identifier;
   begin
      Rose.System_Calls.Initialize_Reply (Parameters, Parameters.Reply_Cap);
      if Launch_Cap = Rose.Capabilities.Null_Capability then
         if not Rose.Server.Has_Instance
           (Server_Instance,
            Launch_Endpoint,
            Identifier)
         then
            Rose.Server.Set_Instance_Cap
              (Server_Instance,
               Launch_Endpoint,
               Identifier,
               Rose.Server.Create_Endpoint (Launch_Endpoint, Identifier));
         end if;
         Cap :=
           Rose.Server.Get_Instance_Cap
             (Server_Instance,
              Launch_Endpoint,
              Identifier);
      else
         Cap := Launch_Cap;
      end if;
      Rose.System_Calls.Send_Cap (Parameters, Cap);
   end Handle_Get_Launch_Interface;

   --------------------
   -- Handle_Install --
   --------------------

   procedure Handle_Install
     (Parameters : in out Rose.Invocation.Invocation_Record)
   is
      Executable         : constant Rose.Capabilities.Capability :=
        Parameters.Caps (0);
      Name               : String (1 .. Natural (Parameters.Buffer_Length))
        with Import, Address => Parameters.Buffer_Address;
      Install_Caps       : Rose.Capabilities.Capability_Array
        (1 .. Rose.Invocation.Max_Capabilities);
      Install_Caps_Count : constant Natural :=
        Rose.System_Calls.Copy_Received_Caps (Parameters, 1, Install_Caps);
      Result             : constant Rose.Capabilities.Capability :=
        Local_Install
          (Parameters.Identifier,
           Executable,
           Name,
           Install_Caps (1 .. Install_Caps_Count));
   begin
      Rose.System_Calls.Initialize_Reply (Parameters, Parameters.Reply_Cap);
      Rose.System_Calls.Send_Cap (Parameters, Result);
   end Handle_Install;

   -------------------
   -- Handle_Launch --
   -------------------

   procedure Handle_Launch
     (Parameters : in out Rose.Invocation.Invocation_Record)
   is
      Caps        : Rose.Capabilities.Capability_Array
        (1 .. Rose.Invocation.Max_Capabilities);
      Caps_Count  : constant Natural :=
        Rose.System_Calls.Copy_Received_Caps (Parameters, 0, Caps);
      Environment : System.Storage_Elements.Storage_Array
        (1 .. Parameters.Buffer_Length)
        with Import, Address => Parameters.Buffer_Address;
      Result      : constant Rose.Capabilities.Capability :=
        Local_Launch
          (Parameters.Identifier,
           Caps (1 .. Caps_Count),
           Environment);
   begin
      Rose.System_Calls.Initialize_Reply (Parameters, Parameters.Reply_Cap);
      Rose.System_Calls.Send_Cap (Parameters, Result);
   end Handle_Launch;

   -----------------------
   -- Publish_Interface --
   -----------------------

   procedure Publish_Interface
     (Server_Context : in out Rose.Server.Server_Context;
      Launch         : Launch_Handler;
      Install        : Install_Handler)
   is
   begin
      Local_Launch := Launch;
      Local_Install := Install;
      Launch_Cap := Rose.Server.Create_Endpoint (Launch_Endpoint);
      Install_Cap := Rose.Server.Create_Endpoint (Install_Endpoint);
      Published_Cap := Rose.Server.Create_Endpoint (Exec_Interface);
      Rose.Server.Register_Handler
        (Server_Context,
         Launch_Interface,
         Handle_Get_Launch_Interface'Access);
      Rose.Server.Register_Handler
        (Server_Context,
         Exec_Interface,
         Handle_Get_Exec_Interface'Access);
      Rose.Server.Register_Handler
        (Server_Context,
         Launch_Endpoint,
         Handle_Launch'Access);
      Rose.Server.Register_Handler
        (Server_Context,
         Install_Endpoint,
         Handle_Install'Access);
      Rose.Server.Publish_Interface (Published_Cap);
   end Publish_Interface;

end Rose.Interfaces.Exec.Server;
