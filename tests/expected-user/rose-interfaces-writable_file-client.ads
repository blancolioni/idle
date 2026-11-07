with Ada.Streams;
with Rose.Capabilities;
with Rose.Interfaces.File_Reader;
with Rose.Interfaces.Seekable_File_Reader;
with Rose.Interfaces.Transactional_Writable_File;
with System.Storage_Elements;

package Rose.Interfaces.Writable_File.Client is

   type Writable_File_Client is
     limited new Rose.Interfaces.Writable_File.Writable_File_Object
     with private;

   procedure Open_Cap_Set
     (Client               : out Writable_File_Client;
      Size                 : Rose.Capabilities.Capability;
      Open_Reader          : Rose.Capabilities.Capability;
      Open_Seekable_Reader : Rose.Capabilities.Capability;
      Write                : Rose.Capabilities.Capability;
      Truncate             : Rose.Capabilities.Capability;
      New_Version          : Rose.Capabilities.Capability);

   procedure Open
     (Client        : out Writable_File_Client;
      Interface_Cap : Rose.Capabilities.Capability);

   function From_Cap
     (Cap : Rose.Capabilities.Capability)
      return Writable_File_Client;

   procedure Close (Client : in out Writable_File_Client);

   overriding function Size
     (Item : in out Writable_File_Client)
      return System.Storage_Elements.Storage_Count;

   overriding function Open_Reader
     (Item : in out Writable_File_Client)
      return Rose.Interfaces.File_Reader.File_Reader_Object'Class;

   overriding function Open_Seekable_Reader
     (Item : in out Writable_File_Client)
      return
        Rose.Interfaces.Seekable_File_Reader.Seekable_File_Reader_Object'Class;

   overriding procedure Write
     (Item   : in out Writable_File_Client;
      Buffer : Ada.Streams.Stream_Element_Array);

   overriding procedure Truncate
     (Item : in out Writable_File_Client;
      Size : System.Storage_Elements.Storage_Count);

   overriding function New_Version
     (Item : in out Writable_File_Client)
      return
        Rose.Interfaces.Transactional_Writable_File
          .Transactional_Writable_File_Object'Class;

   overriding function Writable_File_Cap
     (Item : in out Writable_File_Client)
      return Rose.Capabilities.Capability;

   overriding function File_Cap
     (Item : in out Writable_File_Client)
      return Rose.Capabilities.Capability;

   overriding function Stream_Writer_Cap
     (Item : in out Writable_File_Client)
      return Rose.Capabilities.Capability;

   function Get_Interface_Cap
     (Item : Writable_File_Client)
      return Rose.Capabilities.Capability;

   function Get_Size_Cap
     (Item : in out Writable_File_Client)
      return Rose.Capabilities.Capability;

   function Get_Open_Reader_Cap
     (Item : in out Writable_File_Client)
      return Rose.Capabilities.Capability;

   function Get_Open_Seekable_Reader_Cap
     (Item : in out Writable_File_Client)
      return Rose.Capabilities.Capability;

   function Get_Write_Cap
     (Item : in out Writable_File_Client)
      return Rose.Capabilities.Capability;

   function Get_Truncate_Cap
     (Item : in out Writable_File_Client)
      return Rose.Capabilities.Capability;

   function Get_New_Version_Cap
     (Item : in out Writable_File_Client)
      return Rose.Capabilities.Capability;

private

   type Writable_File_Client is
     limited new Rose.Interfaces.Writable_File.Writable_File_Object
   with record
      Is_Open                     : Boolean := False;
      Interface_Cap               : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
      File_Interface_Cap          : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
      Stream_Writer_Interface_Cap : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
      Size                        : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
      Open_Reader                 : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
      Open_Seekable_Reader        : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
      Write                       : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
      Truncate                    : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
      New_Version                 : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
   end record;

end Rose.Interfaces.Writable_File.Client;
