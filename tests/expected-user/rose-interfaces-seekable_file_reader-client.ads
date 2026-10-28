with Rose.Capabilities;
with Rose.Words;
with System.Storage_Elements;

package Rose.Interfaces.Seekable_File_Reader.Client is

   type Seekable_File_Reader_Client is
     limited new Rose.Interfaces.Seekable_File_Reader
       .Seekable_File_Reader_Object
     with private;

   procedure Open_Cap_Set
     (Client  : out Seekable_File_Reader_Client;
      Read    : Rose.Capabilities.Capability;
      Release : Rose.Capabilities.Capability;
      Seek    : Rose.Capabilities.Capability);

   procedure Open
     (Client        : out Seekable_File_Reader_Client;
      Interface_Cap : Rose.Capabilities.Capability);

   function From_Cap
     (Cap : Rose.Capabilities.Capability)
      return Seekable_File_Reader_Client;

   procedure Close (Client : in out Seekable_File_Reader_Client);

   overriding procedure Read
     (Item   : in out Seekable_File_Reader_Client;
      Buffer : out System.Storage_Elements.Storage_Array;
      Last   : out System.Storage_Elements.Storage_Count);

   overriding procedure Release (Item : in out Seekable_File_Reader_Client);

   overriding procedure Seek
     (Item              : in out Seekable_File_Reader_Client;
      Offset_From_Start : Rose.Words.Word_64);

   overriding function Seekable_File_Reader_Cap
     (Item : in out Seekable_File_Reader_Client)
      return Rose.Capabilities.Capability;

   overriding function Stream_Reader_Cap
     (Item : in out Seekable_File_Reader_Client)
      return Rose.Capabilities.Capability;

   overriding function Resource_Cap
     (Item : in out Seekable_File_Reader_Client)
      return Rose.Capabilities.Capability;

   overriding function File_Reader_Cap
     (Item : in out Seekable_File_Reader_Client)
      return Rose.Capabilities.Capability;

   overriding function Seekable_Cap
     (Item : in out Seekable_File_Reader_Client)
      return Rose.Capabilities.Capability;

   function Get_Interface_Cap
     (Item : Seekable_File_Reader_Client)
      return Rose.Capabilities.Capability;

   function Get_Read_Cap
     (Item : in out Seekable_File_Reader_Client)
      return Rose.Capabilities.Capability;

   function Get_Release_Cap
     (Item : in out Seekable_File_Reader_Client)
      return Rose.Capabilities.Capability;

   function Get_Seek_Cap
     (Item : in out Seekable_File_Reader_Client)
      return Rose.Capabilities.Capability;

private

   type Seekable_File_Reader_Client is
     limited new Rose.Interfaces.Seekable_File_Reader
       .Seekable_File_Reader_Object
   with record
      Is_Open                     : Boolean := False;
      Interface_Cap               : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
      Stream_Reader_Interface_Cap : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
      Resource_Interface_Cap      : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
      File_Reader_Interface_Cap   : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
      Seekable_Interface_Cap      : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
      Read                        : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
      Release                     : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
      Seek                        : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
   end record;

end Rose.Interfaces.Seekable_File_Reader.Client;
