with Rose.Capabilities;
with Rose.Objects;
with Rose.Server;
with Rose.Words;

package Rose.Interfaces.Meter.Server is

   type Badge_Handler is access function
     (Id : Rose.Objects.Capability_Identifier)
      return Rose.Capabilities.Capability;

   type Increment_Handler is access procedure
     (Id : Rose.Objects.Capability_Identifier;
      By : Rose.Words.Word);

   type Value_Handler is access function
     (Id : Rose.Objects.Capability_Identifier)
      return Rose.Words.Word;

   type Reset_Handler is access procedure
     (Id : Rose.Objects.Capability_Identifier);

   procedure Create_Server
     (Server_Context : in out Rose.Server.Server_Context;
      Badge          : Badge_Handler;
      Increment      : Increment_Handler;
      Value          : Value_Handler;
      Reset          : Reset_Handler;
      Instanced      : Boolean := False);

   procedure Attach_Interface
     (Server_Context : in out Rose.Server.Server_Context;
      Badge          : Badge_Handler;
      Increment      : Increment_Handler;
      Value          : Value_Handler;
      Reset          : Reset_Handler;
      Instanced      : Boolean := False);

   procedure Publish_Interface
     (Server_Context : in out Rose.Server.Server_Context;
      Badge          : Badge_Handler;
      Increment      : Increment_Handler;
      Value          : Value_Handler;
      Reset          : Reset_Handler);

   function Get_Badge_Cap return Rose.Capabilities.Capability;

   function Get_Increment_Cap return Rose.Capabilities.Capability;

   function Get_Value_Cap return Rose.Capabilities.Capability;

   function Get_Reset_Cap return Rose.Capabilities.Capability;

   procedure Remove_Instance (Identifier : Rose.Objects.Capability_Identifier);

end Rose.Interfaces.Meter.Server;
