with Rose.Capabilities;
with Rose.Words;

package Rose.Interfaces.Gauge.Client is

   type Gauge_Client is
     limited new Rose.Interfaces.Gauge.Gauge_Object
     with private;

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

   function From_Cap (Cap : Rose.Capabilities.Capability) return Gauge_Client;

   procedure Close (Client : in out Gauge_Client);

   overriding function Badge
     (Item : in out Gauge_Client)
      return Rose.Capabilities.Capability;

   overriding procedure Increment
     (Item : in out Gauge_Client;
      By   : Rose.Words.Word);

   overriding function Value
     (Item : in out Gauge_Client)
      return Rose.Words.Word;

   overriding procedure Set_Label
     (Item  : in out Gauge_Client;
      Label : Rose.Words.Word);

   overriding procedure Reset (Item : in out Gauge_Client);

   overriding function Gauge_Cap
     (Item : in out Gauge_Client)
      return Rose.Capabilities.Capability;

   overriding function Named_Cap
     (Item : in out Gauge_Client)
      return Rose.Capabilities.Capability;

   overriding function Counter_Cap
     (Item : in out Gauge_Client)
      return Rose.Capabilities.Capability;

   overriding function Labelled_Cap
     (Item : in out Gauge_Client)
      return Rose.Capabilities.Capability;

   function Get_Interface_Cap
     (Item : Gauge_Client)
      return Rose.Capabilities.Capability;

   function Get_Badge_Cap
     (Item : in out Gauge_Client)
      return Rose.Capabilities.Capability;

   function Get_Increment_Cap
     (Item : in out Gauge_Client)
      return Rose.Capabilities.Capability;

   function Get_Value_Cap
     (Item : in out Gauge_Client)
      return Rose.Capabilities.Capability;

   function Get_Set_Label_Cap
     (Item : in out Gauge_Client)
      return Rose.Capabilities.Capability;

   function Get_Reset_Cap
     (Item : in out Gauge_Client)
      return Rose.Capabilities.Capability;

private

   type Gauge_Client is
     limited new Rose.Interfaces.Gauge.Gauge_Object
   with record
      Is_Open                : Boolean := False;
      Interface_Cap          : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
      Named_Interface_Cap    : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
      Counter_Interface_Cap  : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
      Labelled_Interface_Cap : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
      Badge                  : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
      Increment              : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
      Value                  : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
      Set_Label              : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
      Reset                  : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
   end record;

end Rose.Interfaces.Gauge.Client;
