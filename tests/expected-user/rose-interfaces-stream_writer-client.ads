with Rose.Capabilities;
with System.Storage_Elements;

package Rose.Interfaces.Stream_Writer.Client is

   type Stream_Writer_Client is
     limited new Rose.Interfaces.Stream_Writer.Stream_Writer_Object
     with private;

   procedure Open_Cap_Set
     (Client : out Stream_Writer_Client;
      Write  : Rose.Capabilities.Capability);

   procedure Open
     (Client        : out Stream_Writer_Client;
      Interface_Cap : Rose.Capabilities.Capability);

   function From_Cap
     (Cap : Rose.Capabilities.Capability)
      return Stream_Writer_Client;

   procedure Close (Client : in out Stream_Writer_Client);

   overriding procedure Write
     (Item   : in out Stream_Writer_Client;
      Buffer : System.Storage_Elements.Storage_Array);

   overriding function Stream_Writer_Cap
     (Item : in out Stream_Writer_Client)
      return Rose.Capabilities.Capability;

   function Get_Interface_Cap
     (Item : Stream_Writer_Client)
      return Rose.Capabilities.Capability;

   function Get_Write_Cap
     (Item : in out Stream_Writer_Client)
      return Rose.Capabilities.Capability;

private

   type Stream_Writer_Client is
     limited new Rose.Interfaces.Stream_Writer.Stream_Writer_Object
   with record
      Is_Open       : Boolean := False;
      Interface_Cap : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
      Write         : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
   end record;

end Rose.Interfaces.Stream_Writer.Client;
