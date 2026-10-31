with Rose.Capabilities;
with Rose.Invocation;

package Rose.Interfaces.Toggle.Client is

   type Toggle_Client is private;

   procedure Open_Cap_Set
     (Client : out Toggle_Client;
      Is_On  : Rose.Capabilities.Capability;
      Switch : Rose.Capabilities.Capability);

   procedure Open
     (Client        : out Toggle_Client;
      Interface_Cap : Rose.Capabilities.Capability);

   procedure Close (Client : in out Toggle_Client);

   function Is_On (Item : Toggle_Client) return Boolean;

   procedure Switch (Item : Toggle_Client; On : Boolean);

   function Get_Interface_Cap
     (Item : Toggle_Client)
      return Rose.Capabilities.Capability;

   function Get_Is_On_Cap
     (Item : Toggle_Client)
      return Rose.Capabilities.Capability;

   function Get_Switch_Cap
     (Item : Toggle_Client)
      return Rose.Capabilities.Capability;

   function Has_Error return Boolean;

   function Get_Last_Error return Rose.Invocation.Invocation_Error;

private

   type Toggle_Client is record
      Is_Open       : Boolean := False;
      Interface_Cap : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
      Is_On         : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
      Switch        : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
   end record;

end Rose.Interfaces.Toggle.Client;
