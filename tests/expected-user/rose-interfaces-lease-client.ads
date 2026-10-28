with Rose.Capabilities;
with Rose.Words;

package Rose.Interfaces.Lease.Client is

   type Lease_Client is
     limited new Rose.Interfaces.Lease.Lease_Object
     with private;

   procedure Open_Cap_Set
     (Client    : out Lease_Client;
      Badge     : Rose.Capabilities.Capability;
      Increment : Rose.Capabilities.Capability;
      Value     : Rose.Capabilities.Capability;
      Release   : Rose.Capabilities.Capability;
      Remaining : Rose.Capabilities.Capability);

   procedure Open
     (Client        : out Lease_Client;
      Interface_Cap : Rose.Capabilities.Capability);

   function From_Cap (Cap : Rose.Capabilities.Capability) return Lease_Client;

   procedure Close (Client : in out Lease_Client);

   overriding function Badge
     (Item : in out Lease_Client)
      return Rose.Capabilities.Capability;

   overriding procedure Increment
     (Item : in out Lease_Client;
      By   : Rose.Words.Word);

   overriding function Value
     (Item : in out Lease_Client)
      return Rose.Words.Word;

   overriding procedure Release (Item : in out Lease_Client);

   overriding function Remaining
     (Item : in out Lease_Client)
      return Rose.Words.Word;

   overriding function Lease_Cap
     (Item : in out Lease_Client)
      return Rose.Capabilities.Capability;

   overriding function Named_Cap
     (Item : in out Lease_Client)
      return Rose.Capabilities.Capability;

   overriding function Counter_Cap
     (Item : in out Lease_Client)
      return Rose.Capabilities.Capability;

   overriding function Resource_Cap
     (Item : in out Lease_Client)
      return Rose.Capabilities.Capability;

   function Get_Interface_Cap
     (Item : Lease_Client)
      return Rose.Capabilities.Capability;

   function Get_Badge_Cap
     (Item : in out Lease_Client)
      return Rose.Capabilities.Capability;

   function Get_Increment_Cap
     (Item : in out Lease_Client)
      return Rose.Capabilities.Capability;

   function Get_Value_Cap
     (Item : in out Lease_Client)
      return Rose.Capabilities.Capability;

   function Get_Release_Cap
     (Item : in out Lease_Client)
      return Rose.Capabilities.Capability;

   function Get_Remaining_Cap
     (Item : in out Lease_Client)
      return Rose.Capabilities.Capability;

private

   type Lease_Client is
     limited new Rose.Interfaces.Lease.Lease_Object
   with record
      Is_Open                : Boolean := False;
      Interface_Cap          : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
      Named_Interface_Cap    : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
      Counter_Interface_Cap  : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
      Resource_Interface_Cap : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
      Badge                  : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
      Increment              : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
      Value                  : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
      Release                : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
      Remaining              : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
   end record;

end Rose.Interfaces.Lease.Client;
