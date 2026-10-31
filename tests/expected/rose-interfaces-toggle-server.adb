with Rose.Invocation;
with Rose.System_Calls;
with Rose.Words;

package body Rose.Interfaces.Toggle.Server is

   use type Rose.Words.Word_32;

   Server_Instance : Rose.Server.Server_Instance;

   Local_Is_On     : Is_On_Handler;

   Is_On_Cap       : Rose.Capabilities.Capability :=
     Rose.Capabilities.Null_Capability;

   Local_Switch    : Switch_Handler;

   Switch_Cap      : Rose.Capabilities.Capability :=
     Rose.Capabilities.Null_Capability;

   Published_Cap   : Rose.Capabilities.Capability :=
     Rose.Capabilities.Null_Capability;

   procedure Handle_Get_Toggle_Interface
     (Parameters : in out Rose.Invocation.Invocation_Record);

   procedure Handle_Is_On
     (Parameters : in out Rose.Invocation.Invocation_Record);

   procedure Handle_Switch
     (Parameters : in out Rose.Invocation.Invocation_Record);

   ----------------------
   -- Attach_Interface --
   ----------------------

   procedure Attach_Interface
     (Server_Context : in out Rose.Server.Server_Context;
      Is_On          : Is_On_Handler;
      Switch         : Switch_Handler;
      Instanced      : Boolean := False)
   is
   begin
      Local_Is_On := Is_On;
      Local_Switch := Switch;
      Rose.Server.Register_Handler
        (Server_Context,
         Toggle_Interface,
         Handle_Get_Toggle_Interface'Access);
      if not Instanced then
         Is_On_Cap := Rose.Server.Create_Endpoint (Is_On_Endpoint);
         Switch_Cap := Rose.Server.Create_Endpoint (Switch_Endpoint);
         Rose.Server.Create_Anonymous_Endpoint (Toggle_Interface);
      end if;
      Rose.Server.Register_Handler
        (Server_Context,
         Is_On_Endpoint,
         Handle_Is_On'Access);
      Rose.Server.Register_Handler
        (Server_Context,
         Switch_Endpoint,
         Handle_Switch'Access);
   end Attach_Interface;

   -------------------
   -- Create_Server --
   -------------------

   procedure Create_Server
     (Server_Context : in out Rose.Server.Server_Context;
      Is_On          : Is_On_Handler;
      Switch         : Switch_Handler;
      Instanced      : Boolean := False)
   is
   begin
      Attach_Interface (Server_Context, Is_On, Switch, Instanced);
   end Create_Server;

   -------------------
   -- Get_Is_On_Cap --
   -------------------

   function Get_Is_On_Cap return Rose.Capabilities.Capability is (Is_On_Cap);

   --------------------
   -- Get_Switch_Cap --
   --------------------

   function Get_Switch_Cap return Rose.Capabilities.Capability is (Switch_Cap);

   ---------------------------------
   -- Handle_Get_Toggle_Interface --
   ---------------------------------

   procedure Handle_Get_Toggle_Interface
     (Parameters : in out Rose.Invocation.Invocation_Record)
   is
      use type Rose.Capabilities.Capability;
      Cap        : Rose.Capabilities.Capability;
      Identifier : constant Rose.Objects.Capability_Identifier :=
        Parameters.Identifier;
   begin
      Rose.System_Calls.Initialize_Reply (Parameters, Parameters.Reply_Cap);
      if Is_On_Cap = Rose.Capabilities.Null_Capability then
         if not Rose.Server.Has_Instance
           (Server_Instance,
            Is_On_Endpoint,
            Identifier)
         then
            Rose.Server.Set_Instance_Cap
              (Server_Instance,
               Is_On_Endpoint,
               Identifier,
               Rose.Server.Create_Endpoint (Is_On_Endpoint, Identifier));
         end if;
         Cap :=
           Rose.Server.Get_Instance_Cap
             (Server_Instance,
              Is_On_Endpoint,
              Identifier);
      else
         Cap := Is_On_Cap;
      end if;
      Rose.System_Calls.Send_Cap (Parameters, Cap);
      if Switch_Cap = Rose.Capabilities.Null_Capability then
         if not Rose.Server.Has_Instance
           (Server_Instance,
            Switch_Endpoint,
            Identifier)
         then
            Rose.Server.Set_Instance_Cap
              (Server_Instance,
               Switch_Endpoint,
               Identifier,
               Rose.Server.Create_Endpoint (Switch_Endpoint, Identifier));
         end if;
         Cap :=
           Rose.Server.Get_Instance_Cap
             (Server_Instance,
              Switch_Endpoint,
              Identifier);
      else
         Cap := Switch_Cap;
      end if;
      Rose.System_Calls.Send_Cap (Parameters, Cap);
   end Handle_Get_Toggle_Interface;

   ------------------
   -- Handle_Is_On --
   ------------------

   procedure Handle_Is_On
     (Parameters : in out Rose.Invocation.Invocation_Record)
   is
      Result : constant Boolean := Local_Is_On (Parameters.Identifier);
   begin
      Rose.System_Calls.Initialize_Reply (Parameters, Parameters.Reply_Cap);
      Rose.System_Calls.Send_Word (Parameters, Natural (Boolean'Pos (Result)));
   end Handle_Is_On;

   -------------------
   -- Handle_Switch --
   -------------------

   procedure Handle_Switch
     (Parameters : in out Rose.Invocation.Invocation_Record)
   is
      On : constant Boolean :=
        Rose.System_Calls.Get_Word_32 (Parameters, 0) /= 0;
   begin
      Local_Switch (Parameters.Identifier, On);
      Rose.System_Calls.Initialize_Reply (Parameters, Parameters.Reply_Cap);
   end Handle_Switch;

   -----------------------
   -- Publish_Interface --
   -----------------------

   procedure Publish_Interface
     (Server_Context : in out Rose.Server.Server_Context;
      Is_On          : Is_On_Handler;
      Switch         : Switch_Handler)
   is
   begin
      Local_Is_On := Is_On;
      Local_Switch := Switch;
      Is_On_Cap := Rose.Server.Create_Endpoint (Is_On_Endpoint);
      Switch_Cap := Rose.Server.Create_Endpoint (Switch_Endpoint);
      Published_Cap := Rose.Server.Create_Endpoint (Toggle_Interface);
      Rose.Server.Register_Handler
        (Server_Context,
         Toggle_Interface,
         Handle_Get_Toggle_Interface'Access);
      Rose.Server.Register_Handler
        (Server_Context,
         Is_On_Endpoint,
         Handle_Is_On'Access);
      Rose.Server.Register_Handler
        (Server_Context,
         Switch_Endpoint,
         Handle_Switch'Access);
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

end Rose.Interfaces.Toggle.Server;
