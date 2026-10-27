with Rose.Capabilities;
with System.Storage_Elements;

package Rose.Interfaces.Stream.Client is

   type Stream_Client is
     limited new Rose.Interfaces.Stream.Stream_Object
     with private;

   procedure Open_Cap_Set
     (Client : out Stream_Client;
      Read   : Rose.Capabilities.Capability;
      Write  : Rose.Capabilities.Capability);

   procedure Open
     (Client        : out Stream_Client;
      Interface_Cap : Rose.Capabilities.Capability);

   procedure Close (Client : in out Stream_Client);

   overriding procedure Read
     (Item   : in out Stream_Client;
      Buffer : out System.Storage_Elements.Storage_Array;
      Last   : out System.Storage_Elements.Storage_Count);

   overriding procedure Write
     (Item   : in out Stream_Client;
      Buffer : System.Storage_Elements.Storage_Array);

   function Get_Interface_Cap
     (Item : Stream_Client)
      return Rose.Capabilities.Capability;

   function Get_Read_Cap
     (Item : Stream_Client)
      return Rose.Capabilities.Capability;

   function Get_Write_Cap
     (Item : Stream_Client)
      return Rose.Capabilities.Capability;

private

   type Stream_Client is
     limited new Rose.Interfaces.Stream.Stream_Object
   with record
      Is_Open       : Boolean := False;
      Interface_Cap : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
      Read          : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
      Write         : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
   end record;

end Rose.Interfaces.Stream.Client;
