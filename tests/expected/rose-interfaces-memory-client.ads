with Rose.Capabilities;
with Rose.Interfaces.Kernel_Process.Client;
with Rose.Interfaces.Process.Client;
with Rose.Invocation;
with Rose.Objects;
with Rose.Words;
with System.Storage_Elements;

package Rose.Interfaces.Memory.Client is

   type Memory_Client is private;

   procedure Open_Cap_Set
     (Client               : out Memory_Client;
      New_Process          : Rose.Capabilities.Capability;
      Register_Process     : Rose.Capabilities.Capability;
      Page_Fault           : Rose.Capabilities.Capability;
      Take_Physical_Memory : Rose.Capabilities.Capability;
      Checkpoint           : Rose.Capabilities.Capability);

   procedure Open
     (Client        : out Memory_Client;
      Interface_Cap : Rose.Capabilities.Capability);

   procedure Close (Client : in out Memory_Client);

   function New_Process
     (Item    : Memory_Client;
      Process : Rose.Interfaces.Kernel_Process.Client.Kernel_Process_Client)
      return Rose.Interfaces.Process.Client.Process_Client;

   procedure Register_Process
     (Item        : Memory_Client;
      Process     : Rose.Interfaces.Process.Client.Process_Client;
      Exec_Base   : Rose.Words.Word;
      Exec_Bound  : Rose.Words.Word;
      Text_Base   : Rose.Words.Word;
      Text_Bound  : Rose.Words.Word;
      Data_Base   : Rose.Words.Word;
      Data_Bound  : Rose.Words.Word;
      Stack_Base  : Rose.Words.Word;
      Stack_Bound : Rose.Words.Word;
      Environment : System.Storage_Elements.Storage_Array);

   procedure Page_Fault
     (Item            : Memory_Client;
      Faulting_Object : Rose.Objects.Object_Id;
      Virtual_Page    : Rose.Words.Word;
      Physical_Page   : Rose.Words.Word;
      Action          : Rose.Interfaces.Memory.Page_Access_Type);

   procedure Take_Physical_Memory
     (Item   : Memory_Client;
      Size   : Rose.Words.Word;
      Start  : out Rose.Words.Word;
      Amount : out Rose.Words.Word);

   procedure Checkpoint
     (Item        : Memory_Client;
      Append_Page : Rose.Capabilities.Capability);

   function Get_Interface_Cap
     (Item : Memory_Client)
      return Rose.Capabilities.Capability;

   function Get_New_Process_Cap
     (Item : Memory_Client)
      return Rose.Capabilities.Capability;

   function Get_Register_Process_Cap
     (Item : Memory_Client)
      return Rose.Capabilities.Capability;

   function Get_Page_Fault_Cap
     (Item : Memory_Client)
      return Rose.Capabilities.Capability;

   function Get_Take_Physical_Memory_Cap
     (Item : Memory_Client)
      return Rose.Capabilities.Capability;

   function Get_Checkpoint_Cap
     (Item : Memory_Client)
      return Rose.Capabilities.Capability;

   function Has_Error return Boolean;

   function Get_Last_Error return Rose.Invocation.Invocation_Error;

private

   type Memory_Client is record
      Is_Open              : Boolean := False;
      Interface_Cap        : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
      New_Process          : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
      Register_Process     : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
      Page_Fault           : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
      Take_Physical_Memory : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
      Checkpoint           : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
   end record;

end Rose.Interfaces.Memory.Client;
