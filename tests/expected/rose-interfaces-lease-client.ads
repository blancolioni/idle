with Rose.Capabilities;
with Rose.Invocation;
with Rose.Words;

package Rose.Interfaces.Lease.Client is

   type Lease_Client is private;

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

   procedure Close (Client : in out Lease_Client);

   function Badge (Item : Lease_Client) return Rose.Capabilities.Capability;

   procedure Increment (Item : Lease_Client; By : Rose.Words.Word);

   function Value (Item : Lease_Client) return Rose.Words.Word;

   procedure Release (Item : Lease_Client);

   function Remaining (Item : Lease_Client) return Rose.Words.Word;

   function Get_Interface_Cap
     (Item : Lease_Client)
      return Rose.Capabilities.Capability;

   function Get_Badge_Cap
     (Item : Lease_Client)
      return Rose.Capabilities.Capability;

   function Get_Increment_Cap
     (Item : Lease_Client)
      return Rose.Capabilities.Capability;

   function Get_Value_Cap
     (Item : Lease_Client)
      return Rose.Capabilities.Capability;

   function Get_Release_Cap
     (Item : Lease_Client)
      return Rose.Capabilities.Capability;

   function Get_Remaining_Cap
     (Item : Lease_Client)
      return Rose.Capabilities.Capability;

   function Has_Error return Boolean;

   function Get_Last_Error return Rose.Invocation.Invocation_Error;

private

   type Lease_Client is record
      Is_Open       : Boolean := False;
      Interface_Cap : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
      Badge         : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
      Increment     : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
      Value         : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
      Release       : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
      Remaining     : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
   end record;

end Rose.Interfaces.Lease.Client;
