with Rose.Capabilities;

package Rose.Interfaces.Partner.Client is

   type Partner_Client is
     limited new Rose.Interfaces.Partner.Partner_Object
     with private;

   procedure Open_Cap_Set
     (Client : out Partner_Client;
      Pair   : Rose.Capabilities.Capability;
      Next   : Rose.Capabilities.Capability);

   procedure Open
     (Client        : out Partner_Client;
      Interface_Cap : Rose.Capabilities.Capability);

   function From_Cap
     (Cap : Rose.Capabilities.Capability)
      return Partner_Client;

   procedure Close (Client : in out Partner_Client);

   overriding procedure Pair
     (Item  : in out Partner_Client;
      Other : in out Partner_Client;
      Peer  : in out Rose.Interfaces.Partner.Partner_Object'Class);

   overriding function Next
     (Item : in out Partner_Client)
      return Rose.Interfaces.Partner.Partner_Object'Class;

   overriding function Partner_Cap
     (Item : in out Partner_Client)
      return Rose.Capabilities.Capability;

   function Get_Interface_Cap
     (Item : Partner_Client)
      return Rose.Capabilities.Capability;

   function Get_Pair_Cap
     (Item : in out Partner_Client)
      return Rose.Capabilities.Capability;

   function Get_Next_Cap
     (Item : in out Partner_Client)
      return Rose.Capabilities.Capability;

private

   type Partner_Client is
     limited new Rose.Interfaces.Partner.Partner_Object
   with record
      Is_Open       : Boolean := False;
      Interface_Cap : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
      Pair          : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
      Next          : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
   end record;

end Rose.Interfaces.Partner.Client;
