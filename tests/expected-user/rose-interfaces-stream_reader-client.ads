with Rose.Capabilities;
with System.Storage_Elements;

package Rose.Interfaces.Stream_Reader.Client is

   type Stream_Reader_Client is
     limited new Rose.Interfaces.Stream_Reader.Stream_Reader_Object
     with private;

   procedure Open_Cap_Set
     (Client : out Stream_Reader_Client;
      Read   : Rose.Capabilities.Capability);

   procedure Open
     (Client        : out Stream_Reader_Client;
      Interface_Cap : Rose.Capabilities.Capability);

   function From_Cap
     (Cap : Rose.Capabilities.Capability)
      return Stream_Reader_Client;

   procedure Close (Client : in out Stream_Reader_Client);

   overriding procedure Read
     (Item   : in out Stream_Reader_Client;
      Buffer : out System.Storage_Elements.Storage_Array;
      Last   : out System.Storage_Elements.Storage_Count);

   overriding function Stream_Reader_Cap
     (Item : in out Stream_Reader_Client)
      return Rose.Capabilities.Capability;

   function Get_Interface_Cap
     (Item : Stream_Reader_Client)
      return Rose.Capabilities.Capability;

   function Get_Read_Cap
     (Item : in out Stream_Reader_Client)
      return Rose.Capabilities.Capability;

private

   type Stream_Reader_Client is
     limited new Rose.Interfaces.Stream_Reader.Stream_Reader_Object
   with record
      Is_Open       : Boolean := False;
      Interface_Cap : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
      Read          : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
   end record;

end Rose.Interfaces.Stream_Reader.Client;
