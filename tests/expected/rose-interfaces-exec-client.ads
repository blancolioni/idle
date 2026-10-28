with Rose.Capabilities;
with Rose.Interfaces.Launch.Client;
with Rose.Interfaces.Process.Client;
with Rose.Interfaces.Stream_Reader.Client;
with Rose.Interfaces.Stream_Writer.Client;
with Rose.Invocation;
with System.Storage_Elements;

package Rose.Interfaces.Exec.Client is

   type Exec_Client is private;

   procedure Open_Cap_Set
     (Client              : out Exec_Client;
      Launch              : Rose.Capabilities.Capability;
      Launch_Command      : Rose.Capabilities.Capability;
      Metadata            : Rose.Capabilities.Capability;
      Install             : Rose.Capabilities.Capability;
      Set_Standard_Output : Rose.Capabilities.Capability);

   procedure Open
     (Client        : out Exec_Client;
      Interface_Cap : Rose.Capabilities.Capability);

   procedure Close (Client : in out Exec_Client);

   function Launch
     (Item        : Exec_Client;
      Caps        : Rose.Capabilities.Capability_Array;
      Environment : System.Storage_Elements.Storage_Array)
      return Rose.Interfaces.Process.Client.Process_Client;

   function Launch_Command
     (Item : Exec_Client;
      Caps : Rose.Capabilities.Capability_Array)
      return Rose.Capabilities.Capability;

   procedure Metadata
     (Item   : Exec_Client;
      Result : out String;
      Last   : out Natural);

   function Install
     (Item         : Exec_Client;
      Executable   : Rose.Interfaces.Stream_Reader.Client.Stream_Reader_Client;
      Name         : String;
      Install_Caps : Rose.Capabilities.Capability_Array)
      return Rose.Interfaces.Launch.Client.Launch_Client;

   procedure Set_Standard_Output
     (Item   : Exec_Client;
      Output : Rose.Interfaces.Stream_Writer.Client.Stream_Writer_Client);

   function Get_Interface_Cap
     (Item : Exec_Client)
      return Rose.Capabilities.Capability;

   function Get_Launch_Cap
     (Item : Exec_Client)
      return Rose.Capabilities.Capability;

   function Get_Launch_Command_Cap
     (Item : Exec_Client)
      return Rose.Capabilities.Capability;

   function Get_Metadata_Cap
     (Item : Exec_Client)
      return Rose.Capabilities.Capability;

   function Get_Install_Cap
     (Item : Exec_Client)
      return Rose.Capabilities.Capability;

   function Get_Set_Standard_Output_Cap
     (Item : Exec_Client)
      return Rose.Capabilities.Capability;

   function Has_Error return Boolean;

   function Get_Last_Error return Rose.Invocation.Invocation_Error;

private

   type Exec_Client is record
      Is_Open             : Boolean := False;
      Interface_Cap       : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
      Launch              : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
      Launch_Command      : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
      Metadata            : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
      Install             : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
      Set_Standard_Output : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
   end record;

end Rose.Interfaces.Exec.Client;
