with Rose.Invocation;
with Rose.System_Calls;

package body Rose.Interfaces.Named.Server is

   Server_Instance : Rose.Server.Server_Instance;

   Local_Badge     : Badge_Handler;

   Badge_Cap       : Rose.Capabilities.Capability :=
     Rose.Capabilities.Null_Capability;

   Published_Cap   : Rose.Capabilities.Capability :=
     Rose.Capabilities.Null_Capability;

   procedure Handle_Get_Named_Interface
     (Parameters : in out Rose.Invocation.Invocation_Record);

   procedure Handle_Badge
     (Parameters : in out Rose.Invocation.Invocation_Record);

   ----------------------
   -- Attach_Interface --
   ----------------------

   procedure Attach_Interface
     (Server_Context : in out Rose.Server.Server_Context;
      Badge          : Badge_Handler;
      Instanced      : Boolean := False)
   is
   begin
      Local_Badge := Badge;
      Rose.Server.Register_Handler
        (Server_Context,
         Named_Interface,
         Handle_Get_Named_Interface'Access);
      if not Instanced then
         Badge_Cap := Rose.Server.Create_Endpoint (Badge_Endpoint);
         Rose.Server.Create_Anonymous_Endpoint (Named_Interface);
      end if;
      Rose.Server.Register_Handler
        (Server_Context,
         Badge_Endpoint,
         Handle_Badge'Access);
   end Attach_Interface;

   -------------------
   -- Create_Server --
   -------------------

   procedure Create_Server
     (Server_Context : in out Rose.Server.Server_Context;
      Badge          : Badge_Handler;
      Instanced      : Boolean := False)
   is
   begin
      Attach_Interface (Server_Context, Badge, Instanced);
   end Create_Server;

   -------------------
   -- Get_Badge_Cap --
   -------------------

   function Get_Badge_Cap return Rose.Capabilities.Capability is (Badge_Cap);

   ------------------
   -- Handle_Badge --
   ------------------

   procedure Handle_Badge
     (Parameters : in out Rose.Invocation.Invocation_Record)
   is
      Result : constant Rose.Capabilities.Capability :=
        Local_Badge (Parameters.Identifier);
   begin
      Rose.System_Calls.Initialize_Reply (Parameters, Parameters.Reply_Cap);
      Rose.System_Calls.Send_Cap (Parameters, Result);
   end Handle_Badge;

   --------------------------------
   -- Handle_Get_Named_Interface --
   --------------------------------

   procedure Handle_Get_Named_Interface
     (Parameters : in out Rose.Invocation.Invocation_Record)
   is
      use type Rose.Capabilities.Capability;
      Cap        : Rose.Capabilities.Capability;
      Identifier : constant Rose.Objects.Capability_Identifier :=
        Parameters.Identifier;
   begin
      Rose.System_Calls.Initialize_Reply (Parameters, Parameters.Reply_Cap);
      if Badge_Cap = Rose.Capabilities.Null_Capability then
         if not Rose.Server.Has_Instance
           (Server_Instance,
            Badge_Endpoint,
            Identifier)
         then
            Rose.Server.Set_Instance_Cap
              (Server_Instance,
               Badge_Endpoint,
               Identifier,
               Rose.Server.Create_Endpoint (Badge_Endpoint, Identifier));
         end if;
         Cap :=
           Rose.Server.Get_Instance_Cap
             (Server_Instance,
              Badge_Endpoint,
              Identifier);
      else
         Cap := Badge_Cap;
      end if;
      Rose.System_Calls.Send_Cap (Parameters, Cap);
   end Handle_Get_Named_Interface;

   -----------------------
   -- Publish_Interface --
   -----------------------

   procedure Publish_Interface
     (Server_Context : in out Rose.Server.Server_Context;
      Badge          : Badge_Handler)
   is
   begin
      Local_Badge := Badge;
      Badge_Cap := Rose.Server.Create_Endpoint (Badge_Endpoint);
      Published_Cap := Rose.Server.Create_Endpoint (Named_Interface);
      Rose.Server.Register_Handler
        (Server_Context,
         Named_Interface,
         Handle_Get_Named_Interface'Access);
      Rose.Server.Register_Handler
        (Server_Context,
         Badge_Endpoint,
         Handle_Badge'Access);
      Rose.Server.Publish_Interface (Published_Cap);
   end Publish_Interface;

end Rose.Interfaces.Named.Server;
