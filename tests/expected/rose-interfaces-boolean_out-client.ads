with Rose.Capabilities;
with Rose.Invocation;

package Rose.Interfaces.Boolean_Out.Client is

   type Boolean_Out_Client is private;

   procedure Open_Cap_Set
     (Client : out Boolean_Out_Client;
      Get    : Rose.Capabilities.Capability);

   procedure Open
     (Client        : out Boolean_Out_Client;
      Interface_Cap : Rose.Capabilities.Capability);

   procedure Close (Client : in out Boolean_Out_Client);

   procedure Get (Item : Boolean_Out_Client; On : out Boolean);

   function Get_Interface_Cap
     (Item : Boolean_Out_Client)
      return Rose.Capabilities.Capability;

   function Get_Get_Cap
     (Item : Boolean_Out_Client)
      return Rose.Capabilities.Capability;

   function Has_Error return Boolean;

   function Get_Last_Error return Rose.Invocation.Invocation_Error;

private

   type Boolean_Out_Client is record
      Is_Open       : Boolean := False;
      Interface_Cap : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
      Get           : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
   end record;

end Rose.Interfaces.Boolean_Out.Client;
