with Rose.Capabilities;

package Rose.Interfaces.Editor.Client is

   type Editor_Client is
     limited new Rose.Interfaces.Editor.Editor_Object
     with private;

   procedure Open_Cap_Set
     (Client : out Editor_Client;
      Show   : Rose.Capabilities.Capability);

   procedure Open
     (Client        : out Editor_Client;
      Interface_Cap : Rose.Capabilities.Capability);

   function From_Cap (Cap : Rose.Capabilities.Capability) return Editor_Client;

   procedure Close (Client : in out Editor_Client);

   overriding procedure Show
     (Item  : in out Editor_Client;
      Place : Rose.Interfaces.Editor.Location);

   overriding function Editor_Cap
     (Item : in out Editor_Client)
      return Rose.Capabilities.Capability;

   function Get_Interface_Cap
     (Item : Editor_Client)
      return Rose.Capabilities.Capability;

   function Get_Show_Cap
     (Item : in out Editor_Client)
      return Rose.Capabilities.Capability;

private

   type Editor_Client is
     limited new Rose.Interfaces.Editor.Editor_Object
   with record
      Is_Open       : Boolean := False;
      Interface_Cap : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
      Show          : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
   end record;

end Rose.Interfaces.Editor.Client;
