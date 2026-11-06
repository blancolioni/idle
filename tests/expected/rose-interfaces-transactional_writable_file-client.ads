with Rose.Capabilities;
with Rose.Interfaces.File_Reader.Client;
with Rose.Interfaces.Seekable_File_Reader.Client;
with Rose.Invocation;
with System.Storage_Elements;

package Rose.Interfaces.Transactional_Writable_File.Client is

   type Transactional_Writable_File_Client is private;

   procedure Open_Cap_Set
     (Client               : out Transactional_Writable_File_Client;
      Size                 : Rose.Capabilities.Capability;
      Open_Reader          : Rose.Capabilities.Capability;
      Open_Seekable_Reader : Rose.Capabilities.Capability;
      Write                : Rose.Capabilities.Capability;
      Truncate             : Rose.Capabilities.Capability;
      New_Version          : Rose.Capabilities.Capability;
      Commit               : Rose.Capabilities.Capability;
      Rollback             : Rose.Capabilities.Capability;
      Release              : Rose.Capabilities.Capability);

   procedure Open
     (Client        : out Transactional_Writable_File_Client;
      Interface_Cap : Rose.Capabilities.Capability);

   procedure Close (Client : in out Transactional_Writable_File_Client);

   function Size
     (Item : Transactional_Writable_File_Client)
      return System.Storage_Elements.Storage_Count;

   function Open_Reader
     (Item : Transactional_Writable_File_Client)
      return Rose.Interfaces.File_Reader.Client.File_Reader_Client;

   function Open_Seekable_Reader
     (Item : Transactional_Writable_File_Client)
      return
        Rose.Interfaces.Seekable_File_Reader.Client
          .Seekable_File_Reader_Client;

   procedure Write
     (Item   : Transactional_Writable_File_Client;
      Buffer : System.Storage_Elements.Storage_Array);

   procedure Truncate
     (Item : Transactional_Writable_File_Client;
      Size : System.Storage_Elements.Storage_Count);

   function New_Version
     (Item : Transactional_Writable_File_Client)
      return Transactional_Writable_File_Client;

   procedure Commit (Item : Transactional_Writable_File_Client);

   procedure Rollback (Item : Transactional_Writable_File_Client);

   procedure Release (Item : Transactional_Writable_File_Client);

   function Get_Interface_Cap
     (Item : Transactional_Writable_File_Client)
      return Rose.Capabilities.Capability;

   function Get_Size_Cap
     (Item : Transactional_Writable_File_Client)
      return Rose.Capabilities.Capability;

   function Get_Open_Reader_Cap
     (Item : Transactional_Writable_File_Client)
      return Rose.Capabilities.Capability;

   function Get_Open_Seekable_Reader_Cap
     (Item : Transactional_Writable_File_Client)
      return Rose.Capabilities.Capability;

   function Get_Write_Cap
     (Item : Transactional_Writable_File_Client)
      return Rose.Capabilities.Capability;

   function Get_Truncate_Cap
     (Item : Transactional_Writable_File_Client)
      return Rose.Capabilities.Capability;

   function Get_New_Version_Cap
     (Item : Transactional_Writable_File_Client)
      return Rose.Capabilities.Capability;

   function Get_Commit_Cap
     (Item : Transactional_Writable_File_Client)
      return Rose.Capabilities.Capability;

   function Get_Rollback_Cap
     (Item : Transactional_Writable_File_Client)
      return Rose.Capabilities.Capability;

   function Get_Release_Cap
     (Item : Transactional_Writable_File_Client)
      return Rose.Capabilities.Capability;

   function Has_Error return Boolean;

   function Get_Last_Error return Rose.Invocation.Invocation_Error;

private

   type Transactional_Writable_File_Client is record
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
      Commit               : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
      Rollback             : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
      Release              : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
   end record;

end Rose.Interfaces.Transactional_Writable_File.Client;
