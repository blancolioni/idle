with Rose.Capabilities;
with Rose.Objects;
with Rose.Server;
with Rose.Words;

package Rose.Interfaces.Labelled.Server is

   type Badge_Handler is access function
     (Id : Rose.Objects.Capability_Identifier)
      return Rose.Capabilities.Capability;

   type Set_Label_Handler is access procedure
     (Id    : Rose.Objects.Capability_Identifier;
      Label : Rose.Words.Word);

   procedure Create_Server
     (Server_Context : in out Rose.Server.Server_Context;
      Badge          : Badge_Handler;
      Set_Label      : Set_Label_Handler;
      Instanced      : Boolean := False);

   procedure Attach_Interface
     (Server_Context : in out Rose.Server.Server_Context;
      Badge          : Badge_Handler;
      Set_Label      : Set_Label_Handler;
      Instanced      : Boolean := False);

   procedure Publish_Interface
     (Server_Context : in out Rose.Server.Server_Context;
      Badge          : Badge_Handler;
      Set_Label      : Set_Label_Handler);

   function Get_Badge_Cap return Rose.Capabilities.Capability;

   function Get_Set_Label_Cap return Rose.Capabilities.Capability;

   procedure Remove_Instance (Identifier : Rose.Objects.Capability_Identifier);

end Rose.Interfaces.Labelled.Server;
