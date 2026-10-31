with Rose.Capabilities;
with Rose.Objects;
with Rose.Server;

package Rose.Interfaces.Boolean_Out.Server is

   type Get_Handler is access procedure
     (Id : Rose.Objects.Capability_Identifier;
      On : out Boolean);

   procedure Create_Server
     (Server_Context : in out Rose.Server.Server_Context;
      Get            : Get_Handler;
      Instanced      : Boolean := False);

   procedure Attach_Interface
     (Server_Context : in out Rose.Server.Server_Context;
      Get            : Get_Handler;
      Instanced      : Boolean := False);

   procedure Publish_Interface
     (Server_Context : in out Rose.Server.Server_Context;
      Get            : Get_Handler);

   function Get_Get_Cap return Rose.Capabilities.Capability;

   procedure Remove_Instance (Identifier : Rose.Objects.Capability_Identifier);

end Rose.Interfaces.Boolean_Out.Server;
