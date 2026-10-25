with Rose.Capabilities;
with Rose.Invocation;
with Rose.Words;

package Rose.Interfaces.Gauge.Client is

   type Gauge_Client is private;

   procedure Open_Cap_Set
     (Client    : out Gauge_Client;
      Badge     : Rose.Capabilities.Capability;
      Increment : Rose.Capabilities.Capability;
      Value     : Rose.Capabilities.Capability;
      Set_Label : Rose.Capabilities.Capability;
      Reset     : Rose.Capabilities.Capability);

   procedure Open
     (Client        : out Gauge_Client;
      Interface_Cap : Rose.Capabilities.Capability);

   procedure Close (Client : in out Gauge_Client);

   function Badge (Item : Gauge_Client) return Rose.Capabilities.Capability;

   procedure Increment (Item : Gauge_Client; By : Rose.Words.Word);

   function Value (Item : Gauge_Client) return Rose.Words.Word;

   procedure Set_Label (Item : Gauge_Client; Label : Rose.Words.Word);

   procedure Reset (Item : Gauge_Client);

   function Get_Interface_Cap
     (Item : Gauge_Client)
      return Rose.Capabilities.Capability;

   function Get_Badge_Cap
     (Item : Gauge_Client)
      return Rose.Capabilities.Capability;

   function Get_Increment_Cap
     (Item : Gauge_Client)
      return Rose.Capabilities.Capability;

   function Get_Value_Cap
     (Item : Gauge_Client)
      return Rose.Capabilities.Capability;

   function Get_Set_Label_Cap
     (Item : Gauge_Client)
      return Rose.Capabilities.Capability;

   function Get_Reset_Cap
     (Item : Gauge_Client)
      return Rose.Capabilities.Capability;

   function Has_Error return Boolean;

   function Get_Last_Error return Rose.Invocation.Invocation_Error;

private

   type Gauge_Client is record
      Is_Open       : Boolean := False;
      Interface_Cap : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
      Badge         : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
      Increment     : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
      Value         : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
      Set_Label     : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
      Reset         : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
   end record;

end Rose.Interfaces.Gauge.Client;
