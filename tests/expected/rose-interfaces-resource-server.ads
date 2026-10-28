with Rose.Capabilities;
with Rose.Objects;
with Rose.Server;

package Rose.Interfaces.Resource.Server is

   type Release_Handler is access procedure
     (Id : Rose.Objects.Capability_Identifier);

   procedure Create_Server
     (Server_Context : in out Rose.Server.Server_Context;
      Release        : Release_Handler;
      Instanced      : Boolean := False);

   procedure Attach_Interface
     (Server_Context : in out Rose.Server.Server_Context;
      Release        : Release_Handler;
      Instanced      : Boolean := False);

   procedure Publish_Interface
     (Server_Context : in out Rose.Server.Server_Context;
      Release        : Release_Handler);

   function Get_Release_Cap return Rose.Capabilities.Capability;

   procedure Remove_Instance (Identifier : Rose.Objects.Capability_Identifier);

end Rose.Interfaces.Resource.Server;
