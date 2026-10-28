with Rose.Capabilities;

package Rose.Interfaces.Resource.Client is

   type Resource_Client is
     limited new Rose.Interfaces.Resource.Resource_Object
     with private;

   procedure Open_Cap_Set
     (Client  : out Resource_Client;
      Release : Rose.Capabilities.Capability);

   procedure Open
     (Client        : out Resource_Client;
      Interface_Cap : Rose.Capabilities.Capability);

   function From_Cap
     (Cap : Rose.Capabilities.Capability)
      return Resource_Client;

   procedure Close (Client : in out Resource_Client);

   overriding procedure Release (Item : in out Resource_Client);

   overriding function Resource_Cap
     (Item : in out Resource_Client)
      return Rose.Capabilities.Capability;

   function Get_Interface_Cap
     (Item : Resource_Client)
      return Rose.Capabilities.Capability;

   function Get_Release_Cap
     (Item : in out Resource_Client)
      return Rose.Capabilities.Capability;

private

   type Resource_Client is
     limited new Rose.Interfaces.Resource.Resource_Object
   with record
      Is_Open       : Boolean := False;
      Interface_Cap : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
      Release       : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
   end record;

end Rose.Interfaces.Resource.Client;
