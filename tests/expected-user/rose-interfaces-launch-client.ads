with Rose.Capabilities;
with Rose.Interfaces.Process;
with System.Storage_Elements;

package Rose.Interfaces.Launch.Client is

   type Launch_Client is
     limited new Rose.Interfaces.Launch.Launch_Object
     with private;

   procedure Open_Cap_Set
     (Client         : out Launch_Client;
      Launch         : Rose.Capabilities.Capability;
      Launch_Command : Rose.Capabilities.Capability;
      Metadata       : Rose.Capabilities.Capability);

   procedure Open
     (Client        : out Launch_Client;
      Interface_Cap : Rose.Capabilities.Capability);

   function From_Cap (Cap : Rose.Capabilities.Capability) return Launch_Client;

   procedure Close (Client : in out Launch_Client);

   overriding function Launch
     (Item        : in out Launch_Client;
      Caps        : Rose.Capabilities.Capability_Array;
      Environment : System.Storage_Elements.Storage_Array)
      return Rose.Interfaces.Process.Process_Object'Class;

   overriding function Launch_Command
     (Item : in out Launch_Client;
      Caps : Rose.Capabilities.Capability_Array)
      return Rose.Capabilities.Capability;

   overriding function Metadata (Item : in out Launch_Client) return String;

   overriding function Launch_Cap
     (Item : in out Launch_Client)
      return Rose.Capabilities.Capability;

   function Get_Interface_Cap
     (Item : Launch_Client)
      return Rose.Capabilities.Capability;

   function Get_Launch_Cap
     (Item : in out Launch_Client)
      return Rose.Capabilities.Capability;

   function Get_Launch_Command_Cap
     (Item : in out Launch_Client)
      return Rose.Capabilities.Capability;

   function Get_Metadata_Cap
     (Item : in out Launch_Client)
      return Rose.Capabilities.Capability;

private

   type Launch_Client is
     limited new Rose.Interfaces.Launch.Launch_Object
   with record
      Is_Open        : Boolean := False;
      Interface_Cap  : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
      Launch         : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
      Launch_Command : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
      Metadata       : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
   end record;

end Rose.Interfaces.Launch.Client;
