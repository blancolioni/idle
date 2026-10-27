with Rose.Capabilities;
with Rose.Words;

package Rose.Interfaces.Seekable.Client is

   type Seekable_Client is
     limited new Rose.Interfaces.Seekable.Seekable_Object
     with private;

   procedure Open_Cap_Set
     (Client : out Seekable_Client;
      Seek   : Rose.Capabilities.Capability);

   procedure Open
     (Client        : out Seekable_Client;
      Interface_Cap : Rose.Capabilities.Capability);

   function From_Cap
     (Cap : Rose.Capabilities.Capability)
      return Seekable_Client;

   procedure Close (Client : in out Seekable_Client);

   overriding procedure Seek
     (Item              : in out Seekable_Client;
      Offset_From_Start : Rose.Words.Word_64);

   overriding function Seekable_Cap
     (Item : in out Seekable_Client)
      return Rose.Capabilities.Capability;

   function Get_Interface_Cap
     (Item : Seekable_Client)
      return Rose.Capabilities.Capability;

   function Get_Seek_Cap
     (Item : in out Seekable_Client)
      return Rose.Capabilities.Capability;

private

   type Seekable_Client is
     limited new Rose.Interfaces.Seekable.Seekable_Object
   with record
      Is_Open       : Boolean := False;
      Interface_Cap : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
      Seek          : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
   end record;

end Rose.Interfaces.Seekable.Client;
