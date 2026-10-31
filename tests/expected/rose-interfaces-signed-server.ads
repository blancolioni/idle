with Rose.Capabilities;
with Rose.Objects;
with Rose.Server;
with Rose.Words;

package Rose.Interfaces.Signed.Server is

   type Clamp_Handler is access function
     (Id    : Rose.Objects.Capability_Identifier;
      Value : Integer;
      Low   : Integer)
      return Integer;

   type Position_Handler is access procedure
     (Id    : Rose.Objects.Capability_Identifier;
      Index : Rose.Words.Word;
      X     : out Integer;
      Y     : out Integer;
      Count : out Natural);

   type Offset_Handler is access procedure
     (Id      : Rose.Objects.Capability_Identifier;
      Delta_X : in out Integer);

   type Difference_Handler is access function
     (Id    : Rose.Objects.Capability_Identifier;
      Left  : Long_Long_Integer;
      Right : Long_Long_Integer)
      return Long_Long_Integer;

   type Bounds_Handler is access procedure
     (Id   : Rose.Objects.Capability_Identifier;
      Low  : out Long_Long_Integer;
      High : out Long_Long_Integer);

   procedure Create_Server
     (Server_Context : in out Rose.Server.Server_Context;
      Clamp          : Clamp_Handler;
      Position       : Position_Handler;
      Offset         : Offset_Handler;
      Difference     : Difference_Handler;
      Bounds         : Bounds_Handler;
      Instanced      : Boolean := False);

   procedure Attach_Interface
     (Server_Context : in out Rose.Server.Server_Context;
      Clamp          : Clamp_Handler;
      Position       : Position_Handler;
      Offset         : Offset_Handler;
      Difference     : Difference_Handler;
      Bounds         : Bounds_Handler;
      Instanced      : Boolean := False);

   procedure Publish_Interface
     (Server_Context : in out Rose.Server.Server_Context;
      Clamp          : Clamp_Handler;
      Position       : Position_Handler;
      Offset         : Offset_Handler;
      Difference     : Difference_Handler;
      Bounds         : Bounds_Handler);

   function Get_Clamp_Cap return Rose.Capabilities.Capability;

   function Get_Position_Cap return Rose.Capabilities.Capability;

   function Get_Offset_Cap return Rose.Capabilities.Capability;

   function Get_Difference_Cap return Rose.Capabilities.Capability;

   function Get_Bounds_Cap return Rose.Capabilities.Capability;

   procedure Remove_Instance (Identifier : Rose.Objects.Capability_Identifier);

end Rose.Interfaces.Signed.Server;
