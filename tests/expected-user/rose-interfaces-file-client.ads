with Rose.Capabilities;
with Rose.Interfaces.File_Reader;
with Rose.Interfaces.Seekable_File_Reader;
with System.Storage_Elements;

package Rose.Interfaces.File.Client is

   type File_Client is
     limited new Rose.Interfaces.File.File_Object
     with private;

   procedure Open_Cap_Set
     (Client               : out File_Client;
      Size                 : Rose.Capabilities.Capability;
      Open_Reader          : Rose.Capabilities.Capability;
      Open_Seekable_Reader : Rose.Capabilities.Capability);

   procedure Open
     (Client        : out File_Client;
      Interface_Cap : Rose.Capabilities.Capability);

   function From_Cap (Cap : Rose.Capabilities.Capability) return File_Client;

   procedure Close (Client : in out File_Client);

   overriding function Size
     (Item : in out File_Client)
      return System.Storage_Elements.Storage_Count;

   overriding function Open_Reader
     (Item : in out File_Client)
      return Rose.Interfaces.File_Reader.File_Reader_Object'Class;

   overriding function Open_Seekable_Reader
     (Item : in out File_Client)
      return
        Rose.Interfaces.Seekable_File_Reader.Seekable_File_Reader_Object'Class;

   overriding function File_Cap
     (Item : in out File_Client)
      return Rose.Capabilities.Capability;

   function Get_Interface_Cap
     (Item : File_Client)
      return Rose.Capabilities.Capability;

   function Get_Size_Cap
     (Item : in out File_Client)
      return Rose.Capabilities.Capability;

   function Get_Open_Reader_Cap
     (Item : in out File_Client)
      return Rose.Capabilities.Capability;

   function Get_Open_Seekable_Reader_Cap
     (Item : in out File_Client)
      return Rose.Capabilities.Capability;

private

   type File_Client is limited new Rose.Interfaces.File.File_Object with record
      Is_Open              : Boolean := False;
      Interface_Cap        : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
      Size                 : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
      Open_Reader          : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
      Open_Seekable_Reader : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
   end record;

end Rose.Interfaces.File.Client;
