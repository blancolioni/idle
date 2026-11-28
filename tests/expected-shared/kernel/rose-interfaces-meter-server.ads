with Rose.Capabilities;
with Rose.Interfaces.Core.Units;
with Rose.Objects;
with Rose.Server;

package Rose.Interfaces.Meter.Server is

   type Sample_Handler is access procedure
     (Id    : Rose.Objects.Capability_Identifier;
      Every : Rose.Interfaces.Core.Units.Duration;
      Used  : out Rose.Interfaces.Core.Units.Bytes);

   type Kind_Handler is access function
     (Id : Rose.Objects.Capability_Identifier)
      return Rose.Interfaces.Core.Units.Unit_Kind;

   procedure Create_Server
     (Server_Context : in out Rose.Server.Server_Context;
      Sample         : Sample_Handler;
      Kind           : Kind_Handler;
      Instanced      : Boolean := False);

   procedure Attach_Interface
     (Server_Context : in out Rose.Server.Server_Context;
      Sample         : Sample_Handler;
      Kind           : Kind_Handler;
      Instanced      : Boolean := False);

   procedure Publish_Interface
     (Server_Context : in out Rose.Server.Server_Context;
      Sample         : Sample_Handler;
      Kind           : Kind_Handler);

   function Get_Sample_Cap return Rose.Capabilities.Capability;

   function Get_Kind_Cap return Rose.Capabilities.Capability;

   type Owns_Function is access function
     (Identifier : Rose.Objects.Capability_Identifier)
      return Boolean;

   procedure Set_Owns (Owns : Owns_Function);

   procedure Remove_Instance (Identifier : Rose.Objects.Capability_Identifier);

end Rose.Interfaces.Meter.Server;
