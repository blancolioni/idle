with Rose.Capabilities;
with Rose.Objects;
with Rose.Server;
with Rose.Words;

package Rose.Interfaces.Lease.Server is

   type Badge_Handler is access function
     (Id : Rose.Objects.Capability_Identifier)
      return Rose.Capabilities.Capability;

   type Increment_Handler is access procedure
     (Id : Rose.Objects.Capability_Identifier;
      By : Rose.Words.Word);

   type Value_Handler is access function
     (Id : Rose.Objects.Capability_Identifier)
      return Rose.Words.Word;

   type Release_Handler is access procedure
     (Id : Rose.Objects.Capability_Identifier);

   type Remaining_Handler is access function
     (Id : Rose.Objects.Capability_Identifier)
      return Rose.Words.Word;

   procedure Create_Server
     (Server_Context : in out Rose.Server.Server_Context;
      Badge          : Badge_Handler;
      Increment      : Increment_Handler;
      Value          : Value_Handler;
      Release        : Release_Handler;
      Remaining      : Remaining_Handler;
      Instanced      : Boolean := False);

   procedure Attach_Interface
     (Server_Context : in out Rose.Server.Server_Context;
      Badge          : Badge_Handler;
      Increment      : Increment_Handler;
      Value          : Value_Handler;
      Release        : Release_Handler;
      Remaining      : Remaining_Handler;
      Instanced      : Boolean := False);

   procedure Publish_Interface
     (Server_Context : in out Rose.Server.Server_Context;
      Badge          : Badge_Handler;
      Increment      : Increment_Handler;
      Value          : Value_Handler;
      Release        : Release_Handler;
      Remaining      : Remaining_Handler);

   function Get_Badge_Cap return Rose.Capabilities.Capability;

   function Get_Increment_Cap return Rose.Capabilities.Capability;

   function Get_Value_Cap return Rose.Capabilities.Capability;

   function Get_Release_Cap return Rose.Capabilities.Capability;

   function Get_Remaining_Cap return Rose.Capabilities.Capability;

   procedure Remove_Instance (Identifier : Rose.Objects.Capability_Identifier);

end Rose.Interfaces.Lease.Server;
