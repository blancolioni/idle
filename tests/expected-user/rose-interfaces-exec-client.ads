with Rose.Capabilities;
with Rose.Interfaces.Launch;
with Rose.Interfaces.Process;
with Rose.Interfaces.Stream_Reader;
with System.Storage_Elements;

package Rose.Interfaces.Exec.Client is

   type Exec_Client is
     limited new Rose.Interfaces.Exec.Exec_Object
     with private;

   procedure Open_Cap_Set
     (Client  : out Exec_Client;
      Launch  : Rose.Capabilities.Capability;
      Install : Rose.Capabilities.Capability);

   procedure Open
     (Client        : out Exec_Client;
      Interface_Cap : Rose.Capabilities.Capability);

   function From_Cap (Cap : Rose.Capabilities.Capability) return Exec_Client;

   procedure Close (Client : in out Exec_Client);

   overriding function Launch
     (Item        : in out Exec_Client;
      Caps        : Rose.Capabilities.Capability_Array;
      Environment : System.Storage_Elements.Storage_Array)
      return Rose.Interfaces.Process.Process_Object'Class;

   overriding function Install
     (Item         : in out Exec_Client;
      Executable   : in out
        Rose.Interfaces.Stream_Reader.Stream_Reader_Object'Class;
      Name         : String;
      Install_Caps : Rose.Capabilities.Capability_Array)
      return Rose.Interfaces.Launch.Launch_Object'Class;

   overriding function Exec_Cap
     (Item : in out Exec_Client)
      return Rose.Capabilities.Capability;

   overriding function Launch_Cap
     (Item : in out Exec_Client)
      return Rose.Capabilities.Capability;

   function Get_Interface_Cap
     (Item : Exec_Client)
      return Rose.Capabilities.Capability;

   function Get_Launch_Cap
     (Item : in out Exec_Client)
      return Rose.Capabilities.Capability;

   function Get_Install_Cap
     (Item : in out Exec_Client)
      return Rose.Capabilities.Capability;

private

   type Exec_Client is limited new Rose.Interfaces.Exec.Exec_Object with record
      Is_Open              : Boolean := False;
      Interface_Cap        : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
      Launch_Interface_Cap : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
      Launch               : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
      Install              : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
   end record;

end Rose.Interfaces.Exec.Client;
