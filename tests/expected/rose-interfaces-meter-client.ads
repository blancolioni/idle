with Rose.Capabilities;
with Rose.Invocation;
with Rose.Words;

package Rose.Interfaces.Meter.Client is

   type Meter_Client is private;

   procedure Open_Cap_Set
     (Client    : out Meter_Client;
      Badge     : Rose.Capabilities.Capability;
      Increment : Rose.Capabilities.Capability;
      Value     : Rose.Capabilities.Capability;
      Reset     : Rose.Capabilities.Capability);

   procedure Open
     (Client        : out Meter_Client;
      Interface_Cap : Rose.Capabilities.Capability);

   procedure Close (Client : in out Meter_Client);

   function Badge (Item : Meter_Client) return Rose.Capabilities.Capability;

   procedure Increment (Item : Meter_Client; By : Rose.Words.Word);

   function Value (Item : Meter_Client) return Rose.Words.Word;

   procedure Reset (Item : Meter_Client);

   function Get_Interface_Cap
     (Item : Meter_Client)
      return Rose.Capabilities.Capability;

   function Get_Badge_Cap
     (Item : Meter_Client)
      return Rose.Capabilities.Capability;

   function Get_Increment_Cap
     (Item : Meter_Client)
      return Rose.Capabilities.Capability;

   function Get_Value_Cap
     (Item : Meter_Client)
      return Rose.Capabilities.Capability;

   function Get_Reset_Cap
     (Item : Meter_Client)
      return Rose.Capabilities.Capability;

   function Has_Error return Boolean;

   function Get_Last_Error return Rose.Invocation.Invocation_Error;

private

   type Meter_Client is record
      Is_Open       : Boolean := False;
      Interface_Cap : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
      Badge         : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
      Increment     : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
      Value         : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
      Reset         : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
   end record;

end Rose.Interfaces.Meter.Client;
