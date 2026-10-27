with Rose.Capabilities;

package Rose.Interfaces.Named.Client is

   type Named_Client is
     limited new Rose.Interfaces.Named.Named_Object
     with private;

   procedure Open_Cap_Set
     (Client : out Named_Client;
      Badge  : Rose.Capabilities.Capability);

   procedure Open
     (Client        : out Named_Client;
      Interface_Cap : Rose.Capabilities.Capability);

   procedure Close (Client : in out Named_Client);

   overriding function Badge
     (Item : Named_Client)
      return Rose.Capabilities.Capability;

   function Get_Interface_Cap
     (Item : Named_Client)
      return Rose.Capabilities.Capability;

   function Get_Badge_Cap
     (Item : Named_Client)
      return Rose.Capabilities.Capability;

private

   type Named_Client is
     limited new Rose.Interfaces.Named.Named_Object
   with record
      Is_Open       : Boolean := False;
      Interface_Cap : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
      Badge         : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
   end record;

end Rose.Interfaces.Named.Client;
