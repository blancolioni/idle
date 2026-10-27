with Rose.Capabilities;

package Rose.Interfaces.Restorable.Client is

   type Restorable_Client is
     limited new Rose.Interfaces.Restorable.Restorable_Object
     with private;

   procedure Open_Cap_Set
     (Client   : out Restorable_Client;
      Restored : Rose.Capabilities.Capability);

   procedure Open
     (Client        : out Restorable_Client;
      Interface_Cap : Rose.Capabilities.Capability);

   procedure Close (Client : in out Restorable_Client);

   overriding procedure Restored (Item : in out Restorable_Client);

   function Get_Interface_Cap
     (Item : Restorable_Client)
      return Rose.Capabilities.Capability;

   function Get_Restored_Cap
     (Item : Restorable_Client)
      return Rose.Capabilities.Capability;

private

   type Restorable_Client is
     limited new Rose.Interfaces.Restorable.Restorable_Object
   with record
      Is_Open       : Boolean := False;
      Interface_Cap : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
      Restored      : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
   end record;

end Rose.Interfaces.Restorable.Client;
