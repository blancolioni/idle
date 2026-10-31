with Rose.Capabilities;
with Rose.Objects;
with Rose.Server;
with Rose.Words;

package Rose.Interfaces.Flags.Server is

   type Is_Set_Handler is access function
     (Id      : Rose.Objects.Capability_Identifier;
      Name    : String;
      Default : Boolean)
      return Boolean;

   type Query_Handler is access procedure
     (Id      : Rose.Objects.Capability_Identifier;
      Index   : Rose.Words.Word;
      Trusted : out Boolean;
      Count   : out Natural);

   type Toggle_Handler is access procedure
     (Id    : Rose.Objects.Capability_Identifier;
      Value : in out Boolean);

   procedure Create_Server
     (Server_Context : in out Rose.Server.Server_Context;
      Is_Set         : Is_Set_Handler;
      Query          : Query_Handler;
      Toggle         : Toggle_Handler;
      Instanced      : Boolean := False);

   procedure Attach_Interface
     (Server_Context : in out Rose.Server.Server_Context;
      Is_Set         : Is_Set_Handler;
      Query          : Query_Handler;
      Toggle         : Toggle_Handler;
      Instanced      : Boolean := False);

   procedure Publish_Interface
     (Server_Context : in out Rose.Server.Server_Context;
      Is_Set         : Is_Set_Handler;
      Query          : Query_Handler;
      Toggle         : Toggle_Handler);

   function Get_Is_Set_Cap return Rose.Capabilities.Capability;

   function Get_Query_Cap return Rose.Capabilities.Capability;

   function Get_Toggle_Cap return Rose.Capabilities.Capability;

   procedure Remove_Instance (Identifier : Rose.Objects.Capability_Identifier);

end Rose.Interfaces.Flags.Server;
