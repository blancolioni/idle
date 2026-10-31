with Rose.Invocation;
with Rose.System_Calls;

package body Rose.Interfaces.Boolean_Out.Server is

   Server_Instance : Rose.Server.Server_Instance;

   Local_Get       : Get_Handler;

   Get_Cap         : Rose.Capabilities.Capability :=
     Rose.Capabilities.Null_Capability;

   Published_Cap   : Rose.Capabilities.Capability :=
     Rose.Capabilities.Null_Capability;

   procedure Handle_Get_Boolean_Out_Interface
     (Parameters : in out Rose.Invocation.Invocation_Record);

   procedure Handle_Get
     (Parameters : in out Rose.Invocation.Invocation_Record);

   ----------------------
   -- Attach_Interface --
   ----------------------

   procedure Attach_Interface
     (Server_Context : in out Rose.Server.Server_Context;
      Get            : Get_Handler;
      Instanced      : Boolean := False)
   is
   begin
      Local_Get := Get;
      Rose.Server.Register_Handler
        (Server_Context,
         Boolean_Out_Interface,
         Handle_Get_Boolean_Out_Interface'Access);
      if not Instanced then
         Get_Cap := Rose.Server.Create_Endpoint (Get_Endpoint);
         Rose.Server.Create_Anonymous_Endpoint (Boolean_Out_Interface);
      end if;
      Rose.Server.Register_Handler
        (Server_Context,
         Get_Endpoint,
         Handle_Get'Access);
   end Attach_Interface;

   -------------------
   -- Create_Server --
   -------------------

   procedure Create_Server
     (Server_Context : in out Rose.Server.Server_Context;
      Get            : Get_Handler;
      Instanced      : Boolean := False)
   is
   begin
      Attach_Interface (Server_Context, Get, Instanced);
   end Create_Server;

   -----------------
   -- Get_Get_Cap --
   -----------------

   function Get_Get_Cap return Rose.Capabilities.Capability is (Get_Cap);

   ----------------
   -- Handle_Get --
   ----------------

   procedure Handle_Get
     (Parameters : in out Rose.Invocation.Invocation_Record)
   is
      On : Boolean;
   begin
      Local_Get (Parameters.Identifier, On);
      Rose.System_Calls.Initialize_Reply (Parameters, Parameters.Reply_Cap);
      Rose.System_Calls.Send_Word (Parameters, Natural (Boolean'Pos (On)));
   end Handle_Get;

   --------------------------------------
   -- Handle_Get_Boolean_Out_Interface --
   --------------------------------------

   procedure Handle_Get_Boolean_Out_Interface
     (Parameters : in out Rose.Invocation.Invocation_Record)
   is
      use type Rose.Capabilities.Capability;
      Cap        : Rose.Capabilities.Capability;
      Identifier : constant Rose.Objects.Capability_Identifier :=
        Parameters.Identifier;
   begin
      Rose.System_Calls.Initialize_Reply (Parameters, Parameters.Reply_Cap);
      if Get_Cap = Rose.Capabilities.Null_Capability then
         if not Rose.Server.Has_Instance
           (Server_Instance,
            Get_Endpoint,
            Identifier)
         then
            Rose.Server.Set_Instance_Cap
              (Server_Instance,
               Get_Endpoint,
               Identifier,
               Rose.Server.Create_Endpoint (Get_Endpoint, Identifier));
         end if;
         Cap :=
           Rose.Server.Get_Instance_Cap
             (Server_Instance,
              Get_Endpoint,
              Identifier);
      else
         Cap := Get_Cap;
      end if;
      Rose.System_Calls.Send_Cap (Parameters, Cap);
   end Handle_Get_Boolean_Out_Interface;

   -----------------------
   -- Publish_Interface --
   -----------------------

   procedure Publish_Interface
     (Server_Context : in out Rose.Server.Server_Context;
      Get            : Get_Handler)
   is
   begin
      Local_Get := Get;
      Get_Cap := Rose.Server.Create_Endpoint (Get_Endpoint);
      Published_Cap := Rose.Server.Create_Endpoint (Boolean_Out_Interface);
      Rose.Server.Register_Handler
        (Server_Context,
         Boolean_Out_Interface,
         Handle_Get_Boolean_Out_Interface'Access);
      Rose.Server.Register_Handler
        (Server_Context,
         Get_Endpoint,
         Handle_Get'Access);
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

end Rose.Interfaces.Boolean_Out.Server;
