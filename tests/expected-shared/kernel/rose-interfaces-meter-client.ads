with Rose.Capabilities;
with Rose.Interfaces.Core.Units;
with Rose.Invocation;

package Rose.Interfaces.Meter.Client is

   type Meter_Client is private;

   procedure Open_Cap_Set
     (Client : out Meter_Client;
      Sample : Rose.Capabilities.Capability;
      Kind   : Rose.Capabilities.Capability);

   procedure Open
     (Client        : out Meter_Client;
      Interface_Cap : Rose.Capabilities.Capability);

   procedure Close (Client : in out Meter_Client);

   procedure Sample
     (Item  : Meter_Client;
      Every : Rose.Interfaces.Core.Units.Duration;
      Used  : out Rose.Interfaces.Core.Units.Bytes);

   function Kind
     (Item : Meter_Client)
      return Rose.Interfaces.Core.Units.Unit_Kind;

   function Get_Interface_Cap
     (Item : Meter_Client)
      return Rose.Capabilities.Capability;

   function Get_Sample_Cap
     (Item : Meter_Client)
      return Rose.Capabilities.Capability;

   function Get_Kind_Cap
     (Item : Meter_Client)
      return Rose.Capabilities.Capability;

   function Has_Error return Boolean;

   function Get_Last_Error return Rose.Invocation.Invocation_Error;

private

   type Meter_Client is record
      Is_Open       : Boolean := False;
      Interface_Cap : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
      Sample        : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
      Kind          : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
   end record;

end Rose.Interfaces.Meter.Client;
