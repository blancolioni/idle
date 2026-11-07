with Rose.Capabilities;
with Rose.Invocation;
with System.Storage_Elements;

package Rose.Interfaces.Reader.Client is

   type Reader_Client is private;

   procedure Open_Cap_Set
     (Client : out Reader_Client;
      Read   : Rose.Capabilities.Capability);

   procedure Open
     (Client        : out Reader_Client;
      Interface_Cap : Rose.Capabilities.Capability);

   procedure Close (Client : in out Reader_Client);

   procedure Read
     (Item   : Reader_Client;
      Buffer : out System.Storage_Elements.Storage_Array;
      Last   : out System.Storage_Elements.Storage_Offset);

   function Get_Interface_Cap
     (Item : Reader_Client)
      return Rose.Capabilities.Capability;

   function Get_Read_Cap
     (Item : Reader_Client)
      return Rose.Capabilities.Capability;

   function Has_Error return Boolean;

   function Get_Last_Error return Rose.Invocation.Invocation_Error;

private

   type Reader_Client is record
      Is_Open       : Boolean := False;
      Interface_Cap : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
      Read          : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
   end record;

end Rose.Interfaces.Reader.Client;
