with Rose.Invocation;
with Rose.System_Calls;

package body Rose.Interfaces.Boolean_Result.Server is

   Server_Instance : Rose.Server.Server_Instance;

   Local_Is_Ready  : Is_Ready_Handler;

   Is_Ready_Cap    : Rose.Capabilities.Capability :=
     Rose.Capabilities.Null_Capability;

   Published_Cap   : Rose.Capabilities.Capability :=
     Rose.Capabilities.Null_Capability;

   procedure Handle_Get_Boolean_Result_Interface
     (Parameters : in out Rose.Invocation.Invocation_Record);

   procedure Handle_Is_Ready
     (Parameters : in out Rose.Invocation.Invocation_Record);

   ----------------------
   -- Attach_Interface --
   ----------------------

   procedure Attach_Interface
     (Server_Context : in out Rose.Server.Server_Context;
      Is_Ready       : Is_Ready_Handler;
      Instanced      : Boolean := False)
   is
   begin
      Local_Is_Ready := Is_Ready;
      Rose.Server.Register_Handler
        (Server_Context,
         Boolean_Result_Interface,
         Handle_Get_Boolean_Result_Interface'Access);
      if not Instanced then
         Is_Ready_Cap := Rose.Server.Create_Endpoint (Is_Ready_Endpoint);
         Rose.Server.Create_Anonymous_Endpoint (Boolean_Result_Interface);
      end if;
      Rose.Server.Register_Handler
        (Server_Context,
         Is_Ready_Endpoint,
         Handle_Is_Ready'Access);
   end Attach_Interface;

   -------------------
   -- Create_Server --
   -------------------

   procedure Create_Server
     (Server_Context : in out Rose.Server.Server_Context;
      Is_Ready       : Is_Ready_Handler;
      Instanced      : Boolean := False)
   is
   begin
      Attach_Interface (Server_Context, Is_Ready, Instanced);
   end Create_Server;

   ----------------------
   -- Get_Is_Ready_Cap --
   ----------------------

   function Get_Is_Ready_Cap
      return Rose.Capabilities.Capability
   is (Is_Ready_Cap);

   -----------------------------------------
   -- Handle_Get_Boolean_Result_Interface --
   -----------------------------------------

   procedure Handle_Get_Boolean_Result_Interface
     (Parameters : in out Rose.Invocation.Invocation_Record)
   is
      use type Rose.Capabilities.Capability;
      Cap        : Rose.Capabilities.Capability;
      Identifier : constant Rose.Objects.Capability_Identifier :=
        Parameters.Identifier;
   begin
      Rose.System_Calls.Initialize_Reply (Parameters, Parameters.Reply_Cap);
      if Is_Ready_Cap = Rose.Capabilities.Null_Capability then
         if not Rose.Server.Has_Instance
           (Server_Instance,
            Is_Ready_Endpoint,
            Identifier)
         then
            Rose.Server.Set_Instance_Cap
              (Server_Instance,
               Is_Ready_Endpoint,
               Identifier,
               Rose.Server.Create_Endpoint (Is_Ready_Endpoint, Identifier));
         end if;
         Cap :=
           Rose.Server.Get_Instance_Cap
             (Server_Instance,
              Is_Ready_Endpoint,
              Identifier);
      else
         Cap := Is_Ready_Cap;
      end if;
      Rose.System_Calls.Send_Cap (Parameters, Cap);
   end Handle_Get_Boolean_Result_Interface;

   ---------------------
   -- Handle_Is_Ready --
   ---------------------

   procedure Handle_Is_Ready
     (Parameters : in out Rose.Invocation.Invocation_Record)
   is
      Result : constant Boolean := Local_Is_Ready (Parameters.Identifier);
   begin
      Rose.System_Calls.Initialize_Reply (Parameters, Parameters.Reply_Cap);
      Rose.System_Calls.Send_Word (Parameters, Natural (Boolean'Pos (Result)));
   end Handle_Is_Ready;

   -----------------------
   -- Publish_Interface --
   -----------------------

   procedure Publish_Interface
     (Server_Context : in out Rose.Server.Server_Context;
      Is_Ready       : Is_Ready_Handler)
   is
   begin
      Local_Is_Ready := Is_Ready;
      Is_Ready_Cap := Rose.Server.Create_Endpoint (Is_Ready_Endpoint);
      Published_Cap := Rose.Server.Create_Endpoint (Boolean_Result_Interface);
      Rose.Server.Register_Handler
        (Server_Context,
         Boolean_Result_Interface,
         Handle_Get_Boolean_Result_Interface'Access);
      Rose.Server.Register_Handler
        (Server_Context,
         Is_Ready_Endpoint,
         Handle_Is_Ready'Access);
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

end Rose.Interfaces.Boolean_Result.Server;
