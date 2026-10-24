with Rose.Capabilities;
with Rose.Invocation;

package Rose.Interfaces.Named.Client is

   type Named_Client is private;

   procedure Open_Cap_Set
     (Client : out Named_Client;
      Badge  : Rose.Capabilities.Capability);

   procedure Open
     (Client        : out Named_Client;
      Interface_Cap : Rose.Capabilities.Capability);

   procedure Close (Client : in out Named_Client);

   function Badge (Item : Named_Client) return Rose.Capabilities.Capability;

   function Get_Interface_Cap
     (Item : Named_Client)
      return Rose.Capabilities.Capability;

   function Get_Badge_Cap
     (Item : Named_Client)
      return Rose.Capabilities.Capability;

   function Has_Error return Boolean;

   function Get_Last_Error return Rose.Invocation.Invocation_Error;

private

   type Named_Client is record
      Is_Open       : Boolean := False;
      Interface_Cap : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
      Badge         : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
   end record;

end Rose.Interfaces.Named.Client;
