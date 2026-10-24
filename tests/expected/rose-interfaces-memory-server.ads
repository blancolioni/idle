with Rose.Capabilities;
with Rose.Objects;
with Rose.Server;
with Rose.Words;
with System.Storage_Elements;

package Rose.Interfaces.Memory.Server is

   type New_Process_Handler is access function
     (Id      : Rose.Objects.Capability_Identifier;
      Process : Rose.Capabilities.Capability)
      return Rose.Capabilities.Capability;

   type Register_Process_Handler is access procedure
     (Id          : Rose.Objects.Capability_Identifier;
      Process     : Rose.Capabilities.Capability;
      Exec_Base   : Rose.Words.Word;
      Exec_Bound  : Rose.Words.Word;
      Text_Base   : Rose.Words.Word;
      Text_Bound  : Rose.Words.Word;
      Data_Base   : Rose.Words.Word;
      Data_Bound  : Rose.Words.Word;
      Stack_Base  : Rose.Words.Word;
      Stack_Bound : Rose.Words.Word;
      Environment : System.Storage_Elements.Storage_Array);

   type Page_Fault_Handler is access procedure
     (Id              : Rose.Objects.Capability_Identifier;
      Faulting_Object : Rose.Objects.Object_Id;
      Virtual_Page    : Rose.Words.Word;
      Physical_Page   : Rose.Words.Word;
      Action          : Rose.Interfaces.Memory.Page_Access_Type);

   type Take_Physical_Memory_Handler is access procedure
     (Id     : Rose.Objects.Capability_Identifier;
      Size   : Rose.Words.Word;
      Start  : out Rose.Words.Word;
      Amount : out Rose.Words.Word);

   type Checkpoint_Handler is access procedure
     (Id          : Rose.Objects.Capability_Identifier;
      Append_Page : Rose.Capabilities.Capability);

   procedure Create_Server
     (Server_Context       : in out Rose.Server.Server_Context;
      New_Process          : New_Process_Handler;
      Register_Process     : Register_Process_Handler;
      Page_Fault           : Page_Fault_Handler;
      Take_Physical_Memory : Take_Physical_Memory_Handler;
      Checkpoint           : Checkpoint_Handler;
      Instanced            : Boolean := False);

   procedure Attach_Interface
     (Server_Context       : in out Rose.Server.Server_Context;
      New_Process          : New_Process_Handler;
      Register_Process     : Register_Process_Handler;
      Page_Fault           : Page_Fault_Handler;
      Take_Physical_Memory : Take_Physical_Memory_Handler;
      Checkpoint           : Checkpoint_Handler;
      Instanced            : Boolean := False);

   procedure Publish_Interface
     (Server_Context       : in out Rose.Server.Server_Context;
      New_Process          : New_Process_Handler;
      Register_Process     : Register_Process_Handler;
      Page_Fault           : Page_Fault_Handler;
      Take_Physical_Memory : Take_Physical_Memory_Handler;
      Checkpoint           : Checkpoint_Handler);

   function Get_New_Process_Cap return Rose.Capabilities.Capability;

   function Get_Register_Process_Cap return Rose.Capabilities.Capability;

   function Get_Page_Fault_Cap return Rose.Capabilities.Capability;

   function Get_Take_Physical_Memory_Cap return Rose.Capabilities.Capability;

   function Get_Checkpoint_Cap return Rose.Capabilities.Capability;

   procedure Remove_Instance (Identifier : Rose.Objects.Capability_Identifier);

end Rose.Interfaces.Memory.Server;
