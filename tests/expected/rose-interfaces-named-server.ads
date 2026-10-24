with Rose.Capabilities;
with Rose.Server;

package Rose.Interfaces.Named.Server is

   type Badge_Handler is access function
     (Id : Rose.Objects.Capability_Identifier)
      return Rose.Capabilities.Capability;

   procedure Create_Server
     (Server_Context : in out Rose.Server.Server_Context;
      Badge          : Badge_Handler;
      Instanced      : Boolean := False);

   procedure Attach_Interface
     (Server_Context : in out Rose.Server.Server_Context;
      Badge          : Badge_Handler;
      Instanced      : Boolean := False);

   procedure Publish_Interface
     (Server_Context : in out Rose.Server.Server_Context;
      Badge          : Badge_Handler);

   function Get_Badge_Cap return Rose.Capabilities.Capability;

end Rose.Interfaces.Named.Server;
