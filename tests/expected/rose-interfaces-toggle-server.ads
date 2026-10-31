with Rose.Capabilities;
with Rose.Objects;
with Rose.Server;

package Rose.Interfaces.Toggle.Server is

   type Is_On_Handler is access function
     (Id : Rose.Objects.Capability_Identifier)
      return Boolean;

   type Switch_Handler is access procedure
     (Id : Rose.Objects.Capability_Identifier;
      On : Boolean);

   procedure Create_Server
     (Server_Context : in out Rose.Server.Server_Context;
      Is_On          : Is_On_Handler;
      Switch         : Switch_Handler;
      Instanced      : Boolean := False);

   procedure Attach_Interface
     (Server_Context : in out Rose.Server.Server_Context;
      Is_On          : Is_On_Handler;
      Switch         : Switch_Handler;
      Instanced      : Boolean := False);

   procedure Publish_Interface
     (Server_Context : in out Rose.Server.Server_Context;
      Is_On          : Is_On_Handler;
      Switch         : Switch_Handler);

   function Get_Is_On_Cap return Rose.Capabilities.Capability;

   function Get_Switch_Cap return Rose.Capabilities.Capability;

   procedure Remove_Instance (Identifier : Rose.Objects.Capability_Identifier);

end Rose.Interfaces.Toggle.Server;
