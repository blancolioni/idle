with Rose.Capabilities;
with Rose.Invocation;

package Rose.Interfaces.Boolean_Result.Client is

   type Boolean_Result_Client is private;

   procedure Open_Cap_Set
     (Client   : out Boolean_Result_Client;
      Is_Ready : Rose.Capabilities.Capability);

   procedure Open
     (Client        : out Boolean_Result_Client;
      Interface_Cap : Rose.Capabilities.Capability);

   procedure Close (Client : in out Boolean_Result_Client);

   function Is_Ready (Item : Boolean_Result_Client) return Boolean;

   function Get_Interface_Cap
     (Item : Boolean_Result_Client)
      return Rose.Capabilities.Capability;

   function Get_Is_Ready_Cap
     (Item : Boolean_Result_Client)
      return Rose.Capabilities.Capability;

   function Has_Error return Boolean;

   function Get_Last_Error return Rose.Invocation.Invocation_Error;

private

   type Boolean_Result_Client is record
      Is_Open       : Boolean := False;
      Interface_Cap : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
      Is_Ready      : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
   end record;

end Rose.Interfaces.Boolean_Result.Client;
