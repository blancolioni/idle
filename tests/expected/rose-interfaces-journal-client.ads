with Rose.Capabilities;
with Rose.Interfaces.File_Reader.Client;
with Rose.Interfaces.Seekable_File_Reader.Client;
with Rose.Interfaces.Transactional_Writable_File.Client;
with Rose.Invocation;
with System.Storage_Elements;

package Rose.Interfaces.Journal.Client is

   type Journal_Client is private;

   procedure Open_Cap_Set
     (Client               : out Journal_Client;
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
     (Client        : out Journal_Client;
      Interface_Cap : Rose.Capabilities.Capability);

   procedure Close (Client : in out Journal_Client);

   function Size
     (Item : Journal_Client)
      return System.Storage_Elements.Storage_Count;

   function Open_Reader
     (Item : Journal_Client)
      return Rose.Interfaces.File_Reader.Client.File_Reader_Client;

   function Open_Seekable_Reader
     (Item : Journal_Client)
      return
        Rose.Interfaces.Seekable_File_Reader.Client
          .Seekable_File_Reader_Client;

   procedure Write
     (Item   : Journal_Client;
      Buffer : System.Storage_Elements.Storage_Array);

   procedure Truncate
     (Item : Journal_Client;
      Size : System.Storage_Elements.Storage_Count);

   function New_Version
     (Item : Journal_Client)
      return
        Rose.Interfaces.Transactional_Writable_File.Client
          .Transactional_Writable_File_Client;

   procedure Commit (Item : Journal_Client);

   procedure Rollback (Item : Journal_Client);

   procedure Release (Item : Journal_Client);

   function Get_Interface_Cap
     (Item : Journal_Client)
      return Rose.Capabilities.Capability;

   function Get_Size_Cap
     (Item : Journal_Client)
      return Rose.Capabilities.Capability;

   function Get_Open_Reader_Cap
     (Item : Journal_Client)
      return Rose.Capabilities.Capability;

   function Get_Open_Seekable_Reader_Cap
     (Item : Journal_Client)
      return Rose.Capabilities.Capability;

   function Get_Write_Cap
     (Item : Journal_Client)
      return Rose.Capabilities.Capability;

   function Get_Truncate_Cap
     (Item : Journal_Client)
      return Rose.Capabilities.Capability;

   function Get_New_Version_Cap
     (Item : Journal_Client)
      return Rose.Capabilities.Capability;

   function Get_Commit_Cap
     (Item : Journal_Client)
      return Rose.Capabilities.Capability;

   function Get_Rollback_Cap
     (Item : Journal_Client)
      return Rose.Capabilities.Capability;

   function Get_Release_Cap
     (Item : Journal_Client)
      return Rose.Capabilities.Capability;

   function Has_Error return Boolean;

   function Get_Last_Error return Rose.Invocation.Invocation_Error;

private

   type Journal_Client is record
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

end Rose.Interfaces.Journal.Client;
