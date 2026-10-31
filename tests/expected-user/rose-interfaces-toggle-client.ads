with Rose.Capabilities;

package Rose.Interfaces.Toggle.Client is

   type Toggle_Client is
     limited new Rose.Interfaces.Toggle.Toggle_Object
     with private;

   procedure Open_Cap_Set
     (Client : out Toggle_Client;
      Is_On  : Rose.Capabilities.Capability;
      Switch : Rose.Capabilities.Capability);

   procedure Open
     (Client        : out Toggle_Client;
      Interface_Cap : Rose.Capabilities.Capability);

   function From_Cap (Cap : Rose.Capabilities.Capability) return Toggle_Client;

   procedure Close (Client : in out Toggle_Client);

   overriding function Is_On (Item : in out Toggle_Client) return Boolean;

   overriding procedure Switch (Item : in out Toggle_Client; On : Boolean);

   overriding function Toggle_Cap
     (Item : in out Toggle_Client)
      return Rose.Capabilities.Capability;

   function Get_Interface_Cap
     (Item : Toggle_Client)
      return Rose.Capabilities.Capability;

   function Get_Is_On_Cap
     (Item : in out Toggle_Client)
      return Rose.Capabilities.Capability;

   function Get_Switch_Cap
     (Item : in out Toggle_Client)
      return Rose.Capabilities.Capability;

private

   type Toggle_Client is
     limited new Rose.Interfaces.Toggle.Toggle_Object
   with record
      Is_Open       : Boolean := False;
      Interface_Cap : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
      Is_On         : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
      Switch        : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
   end record;

end Rose.Interfaces.Toggle.Client;
