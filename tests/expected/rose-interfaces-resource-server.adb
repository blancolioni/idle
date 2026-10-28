with Rose.Invocation;
with Rose.System_Calls;

package body Rose.Interfaces.Resource.Server is

   Server_Instance : Rose.Server.Server_Instance;

   Local_Release   : Release_Handler;

   Release_Cap     : Rose.Capabilities.Capability :=
     Rose.Capabilities.Null_Capability;

   Published_Cap   : Rose.Capabilities.Capability :=
     Rose.Capabilities.Null_Capability;

   procedure Handle_Get_Resource_Interface
     (Parameters : in out Rose.Invocation.Invocation_Record);

   procedure Handle_Release
     (Parameters : in out Rose.Invocation.Invocation_Record);

   ----------------------
   -- Attach_Interface --
   ----------------------

   procedure Attach_Interface
     (Server_Context : in out Rose.Server.Server_Context;
      Release        : Release_Handler;
      Instanced      : Boolean := False)
   is
   begin
      Local_Release := Release;
      Rose.Server.Register_Handler
        (Server_Context,
         Resource_Interface,
         Handle_Get_Resource_Interface'Access);
      if not Instanced then
         Release_Cap := Rose.Server.Create_Endpoint (Release_Endpoint);
         Rose.Server.Create_Anonymous_Endpoint (Resource_Interface);
      end if;
      Rose.Server.Register_Handler
        (Server_Context,
         Release_Endpoint,
         Handle_Release'Access);
   end Attach_Interface;

   -------------------
   -- Create_Server --
   -------------------

   procedure Create_Server
     (Server_Context : in out Rose.Server.Server_Context;
      Release        : Release_Handler;
      Instanced      : Boolean := False)
   is
   begin
      Attach_Interface (Server_Context, Release, Instanced);
   end Create_Server;

   ---------------------
   -- Get_Release_Cap --
   ---------------------

   function Get_Release_Cap
      return Rose.Capabilities.Capability
   is (Release_Cap);

   -----------------------------------
   -- Handle_Get_Resource_Interface --
   -----------------------------------

   procedure Handle_Get_Resource_Interface
     (Parameters : in out Rose.Invocation.Invocation_Record)
   is
      use type Rose.Capabilities.Capability;
      Cap        : Rose.Capabilities.Capability;
      Identifier : constant Rose.Objects.Capability_Identifier :=
        Parameters.Identifier;
   begin
      Rose.System_Calls.Initialize_Reply (Parameters, Parameters.Reply_Cap);
      if Release_Cap = Rose.Capabilities.Null_Capability then
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
      else
         Cap := Release_Cap;
      end if;
      Rose.System_Calls.Send_Cap (Parameters, Cap);
   end Handle_Get_Resource_Interface;

   --------------------
   -- Handle_Release --
   --------------------

   procedure Handle_Release
     (Parameters : in out Rose.Invocation.Invocation_Record)
   is
   begin
      Local_Release (Parameters.Identifier);
      Rose.Server.Remove_Instance (Server_Instance, Parameters.Identifier);
      Rose.System_Calls.Initialize_Reply (Parameters, Parameters.Reply_Cap);
   end Handle_Release;

   -----------------------
   -- Publish_Interface --
   -----------------------

   procedure Publish_Interface
     (Server_Context : in out Rose.Server.Server_Context;
      Release        : Release_Handler)
   is
   begin
      Local_Release := Release;
      Release_Cap := Rose.Server.Create_Endpoint (Release_Endpoint);
      Published_Cap := Rose.Server.Create_Endpoint (Resource_Interface);
      Rose.Server.Register_Handler
        (Server_Context,
         Resource_Interface,
         Handle_Get_Resource_Interface'Access);
      Rose.Server.Register_Handler
        (Server_Context,
         Release_Endpoint,
         Handle_Release'Access);
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

end Rose.Interfaces.Resource.Server;
