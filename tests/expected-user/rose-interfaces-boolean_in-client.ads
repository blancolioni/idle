with Rose.Capabilities;

package Rose.Interfaces.Boolean_In.Client is

   type Boolean_In_Client is
     limited new Rose.Interfaces.Boolean_In.Boolean_In_Object
     with private;

   procedure Open_Cap_Set
     (Client : out Boolean_In_Client;
      Set    : Rose.Capabilities.Capability);

   procedure Open
     (Client        : out Boolean_In_Client;
      Interface_Cap : Rose.Capabilities.Capability);

   function From_Cap
     (Cap : Rose.Capabilities.Capability)
      return Boolean_In_Client;

   procedure Close (Client : in out Boolean_In_Client);

   overriding procedure Set (Item : in out Boolean_In_Client; On : Boolean);

   overriding function Boolean_In_Cap
     (Item : in out Boolean_In_Client)
      return Rose.Capabilities.Capability;

   function Get_Interface_Cap
     (Item : Boolean_In_Client)
      return Rose.Capabilities.Capability;

   function Get_Set_Cap
     (Item : in out Boolean_In_Client)
      return Rose.Capabilities.Capability;

private

   type Boolean_In_Client is
     limited new Rose.Interfaces.Boolean_In.Boolean_In_Object
   with record
      Is_Open       : Boolean := False;
      Interface_Cap : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
      Set           : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
   end record;

end Rose.Interfaces.Boolean_In.Client;
