with Rose.Capabilities;

package Rose.Interfaces.Boolean_Out.Client is

   type Boolean_Out_Client is
     limited new Rose.Interfaces.Boolean_Out.Boolean_Out_Object
     with private;

   procedure Open_Cap_Set
     (Client : out Boolean_Out_Client;
      Get    : Rose.Capabilities.Capability);

   procedure Open
     (Client        : out Boolean_Out_Client;
      Interface_Cap : Rose.Capabilities.Capability);

   function From_Cap
     (Cap : Rose.Capabilities.Capability)
      return Boolean_Out_Client;

   procedure Close (Client : in out Boolean_Out_Client);

   overriding procedure Get
     (Item : in out Boolean_Out_Client;
      On   : out Boolean);

   overriding function Boolean_Out_Cap
     (Item : in out Boolean_Out_Client)
      return Rose.Capabilities.Capability;

   function Get_Interface_Cap
     (Item : Boolean_Out_Client)
      return Rose.Capabilities.Capability;

   function Get_Get_Cap
     (Item : in out Boolean_Out_Client)
      return Rose.Capabilities.Capability;

private

   type Boolean_Out_Client is
     limited new Rose.Interfaces.Boolean_Out.Boolean_Out_Object
   with record
      Is_Open       : Boolean := False;
      Interface_Cap : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
      Get           : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
   end record;

end Rose.Interfaces.Boolean_Out.Client;
