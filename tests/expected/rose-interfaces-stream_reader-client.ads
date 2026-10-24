with Rose.Capabilities;
with Rose.Invocation;
with System.Storage_Elements;

package Rose.Interfaces.Stream_Reader.Client is

   type Stream_Reader_Client is private;

   procedure Open_Cap_Set
     (Client : out Stream_Reader_Client;
      Read   : Rose.Capabilities.Capability);

   procedure Open
     (Client        : out Stream_Reader_Client;
      Interface_Cap : Rose.Capabilities.Capability);

   procedure Close (Client : in out Stream_Reader_Client);

   procedure Read
     (Item   : Stream_Reader_Client;
      Buffer : out System.Storage_Elements.Storage_Array;
      Last   : out System.Storage_Elements.Storage_Count);

   function Get_Interface_Cap
     (Item : Stream_Reader_Client)
      return Rose.Capabilities.Capability;

   function Get_Read_Cap
     (Item : Stream_Reader_Client)
      return Rose.Capabilities.Capability;

   function Has_Error return Boolean;

   function Get_Last_Error return Rose.Invocation.Invocation_Error;

private

   type Stream_Reader_Client is record
      Is_Open       : Boolean := False;
      Interface_Cap : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
      Read          : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
   end record;

end Rose.Interfaces.Stream_Reader.Client;
