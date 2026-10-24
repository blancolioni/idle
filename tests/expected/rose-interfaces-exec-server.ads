with Rose.Capabilities;
with Rose.Objects;
with Rose.Server;
with System.Storage_Elements;

package Rose.Interfaces.Exec.Server is

   type Launch_Handler is access function
     (Id          : Rose.Objects.Capability_Identifier;
      Caps        : Rose.Capabilities.Capability_Array;
      Environment : System.Storage_Elements.Storage_Array)
      return Rose.Capabilities.Capability;

   type Install_Handler is access function
     (Id           : Rose.Objects.Capability_Identifier;
      Executable   : Rose.Capabilities.Capability;
      Name         : String;
      Install_Caps : Rose.Capabilities.Capability_Array)
      return Rose.Capabilities.Capability;

   procedure Create_Server
     (Server_Context : in out Rose.Server.Server_Context;
      Launch         : Launch_Handler;
      Install        : Install_Handler;
      Instanced      : Boolean := False);

   procedure Attach_Interface
     (Server_Context : in out Rose.Server.Server_Context;
      Launch         : Launch_Handler;
      Install        : Install_Handler;
      Instanced      : Boolean := False);

   procedure Publish_Interface
     (Server_Context : in out Rose.Server.Server_Context;
      Launch         : Launch_Handler;
      Install        : Install_Handler);

   function Get_Launch_Cap return Rose.Capabilities.Capability;

   function Get_Install_Cap return Rose.Capabilities.Capability;

   procedure Remove_Instance (Identifier : Rose.Objects.Capability_Identifier);

end Rose.Interfaces.Exec.Server;
