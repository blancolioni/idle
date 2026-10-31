with Rose.Capabilities;

package Rose.Interfaces.Boolean_Result.Client is

   type Boolean_Result_Client is
     limited new Rose.Interfaces.Boolean_Result.Boolean_Result_Object
     with private;

   procedure Open_Cap_Set
     (Client   : out Boolean_Result_Client;
      Is_Ready : Rose.Capabilities.Capability);

   procedure Open
     (Client        : out Boolean_Result_Client;
      Interface_Cap : Rose.Capabilities.Capability);

   function From_Cap
     (Cap : Rose.Capabilities.Capability)
      return Boolean_Result_Client;

   procedure Close (Client : in out Boolean_Result_Client);

   overriding function Is_Ready
     (Item : in out Boolean_Result_Client)
      return Boolean;

   overriding function Boolean_Result_Cap
     (Item : in out Boolean_Result_Client)
      return Rose.Capabilities.Capability;

   function Get_Interface_Cap
     (Item : Boolean_Result_Client)
      return Rose.Capabilities.Capability;

   function Get_Is_Ready_Cap
     (Item : in out Boolean_Result_Client)
      return Rose.Capabilities.Capability;

private

   type Boolean_Result_Client is
     limited new Rose.Interfaces.Boolean_Result.Boolean_Result_Object
   with record
      Is_Open       : Boolean := False;
      Interface_Cap : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
      Is_Ready      : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
   end record;

end Rose.Interfaces.Boolean_Result.Client;
