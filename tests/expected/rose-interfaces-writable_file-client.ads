with Rose.Capabilities;
with Rose.Interfaces.File_Reader.Client;
with Rose.Interfaces.Seekable_File_Reader.Client;
with Rose.Interfaces.Transactional_Writable_File.Client;
with Rose.Invocation;
with System.Storage_Elements;

package Rose.Interfaces.Writable_File.Client is

   type Writable_File_Client is private;

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

   procedure Close (Client : in out Writable_File_Client);

   function Size
     (Item : Writable_File_Client)
      return System.Storage_Elements.Storage_Count;

   function Open_Reader
     (Item : Writable_File_Client)
      return Rose.Interfaces.File_Reader.Client.File_Reader_Client;

   function Open_Seekable_Reader
     (Item : Writable_File_Client)
      return
        Rose.Interfaces.Seekable_File_Reader.Client
          .Seekable_File_Reader_Client;

   procedure Write
     (Item   : Writable_File_Client;
      Buffer : System.Storage_Elements.Storage_Array);

   procedure Truncate
     (Item : Writable_File_Client;
      Size : System.Storage_Elements.Storage_Count);

   function New_Version
     (Item : Writable_File_Client)
      return
        Rose.Interfaces.Transactional_Writable_File.Client
          .Transactional_Writable_File_Client;

   function Get_Interface_Cap
     (Item : Writable_File_Client)
      return Rose.Capabilities.Capability;

   function Get_Size_Cap
     (Item : Writable_File_Client)
      return Rose.Capabilities.Capability;

   function Get_Open_Reader_Cap
     (Item : Writable_File_Client)
      return Rose.Capabilities.Capability;

   function Get_Open_Seekable_Reader_Cap
     (Item : Writable_File_Client)
      return Rose.Capabilities.Capability;

   function Get_Write_Cap
     (Item : Writable_File_Client)
      return Rose.Capabilities.Capability;

   function Get_Truncate_Cap
     (Item : Writable_File_Client)
      return Rose.Capabilities.Capability;

   function Get_New_Version_Cap
     (Item : Writable_File_Client)
      return Rose.Capabilities.Capability;

   function Has_Error return Boolean;

   function Get_Last_Error return Rose.Invocation.Invocation_Error;

private

   type Writable_File_Client is record
      Is_Open              : Boolean := False;
      Interface_Cap        : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
      Size                 : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
      Open_Reader          : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
      Open_Seekable_Reader : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
      Write                : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
      Truncate             : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
      New_Version          : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
   end record;

end Rose.Interfaces.Writable_File.Client;
