with Rose.Capabilities;
with Rose.Invocation;

package Rose.Interfaces.Boolean_In.Client is

   type Boolean_In_Client is private;

   procedure Open_Cap_Set
     (Client : out Boolean_In_Client;
      Set    : Rose.Capabilities.Capability);

   procedure Open
     (Client        : out Boolean_In_Client;
      Interface_Cap : Rose.Capabilities.Capability);

   procedure Close (Client : in out Boolean_In_Client);

   procedure Set (Item : Boolean_In_Client; On : Boolean);

   function Get_Interface_Cap
     (Item : Boolean_In_Client)
      return Rose.Capabilities.Capability;

   function Get_Set_Cap
     (Item : Boolean_In_Client)
      return Rose.Capabilities.Capability;

   function Has_Error return Boolean;

   function Get_Last_Error return Rose.Invocation.Invocation_Error;

private

   type Boolean_In_Client is record
      Is_Open       : Boolean := False;
      Interface_Cap : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
      Set           : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
   end record;

end Rose.Interfaces.Boolean_In.Client;
