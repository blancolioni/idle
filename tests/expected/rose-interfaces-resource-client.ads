with Rose.Capabilities;
with Rose.Invocation;

package Rose.Interfaces.Resource.Client is

   type Resource_Client is private;

   procedure Open_Cap_Set
     (Client  : out Resource_Client;
      Release : Rose.Capabilities.Capability);

   procedure Open
     (Client        : out Resource_Client;
      Interface_Cap : Rose.Capabilities.Capability);

   procedure Close (Client : in out Resource_Client);

   procedure Release (Item : Resource_Client);

   function Get_Interface_Cap
     (Item : Resource_Client)
      return Rose.Capabilities.Capability;

   function Get_Release_Cap
     (Item : Resource_Client)
      return Rose.Capabilities.Capability;

   function Has_Error return Boolean;

   function Get_Last_Error return Rose.Invocation.Invocation_Error;

private

   type Resource_Client is record
      Is_Open       : Boolean := False;
      Interface_Cap : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
      Release       : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
   end record;

end Rose.Interfaces.Resource.Client;
