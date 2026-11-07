with Ada.Streams;
with Rose.Capabilities;

package Rose.Interfaces.Reader.Client is

   type Reader_Client is
     limited new Rose.Interfaces.Reader.Reader_Object
     with private;

   procedure Open_Cap_Set
     (Client : out Reader_Client;
      Read   : Rose.Capabilities.Capability);

   procedure Open
     (Client        : out Reader_Client;
      Interface_Cap : Rose.Capabilities.Capability);

   function From_Cap (Cap : Rose.Capabilities.Capability) return Reader_Client;

   procedure Close (Client : in out Reader_Client);

   overriding procedure Read
     (Item   : in out Reader_Client;
      Buffer : out Ada.Streams.Stream_Element_Array;
      Last   : out Ada.Streams.Stream_Element_Offset);

   overriding function Reader_Cap
     (Item : in out Reader_Client)
      return Rose.Capabilities.Capability;

   function Get_Interface_Cap
     (Item : Reader_Client)
      return Rose.Capabilities.Capability;

   function Get_Read_Cap
     (Item : in out Reader_Client)
      return Rose.Capabilities.Capability;

private

   type Reader_Client is
     limited new Rose.Interfaces.Reader.Reader_Object
   with record
      Is_Open       : Boolean := False;
      Interface_Cap : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
      Read          : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
   end record;

end Rose.Interfaces.Reader.Client;
