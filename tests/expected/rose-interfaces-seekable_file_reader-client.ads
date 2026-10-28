with Rose.Capabilities;
with Rose.Invocation;
with Rose.Words;
with System.Storage_Elements;

package Rose.Interfaces.Seekable_File_Reader.Client is

   type Seekable_File_Reader_Client is private;

   procedure Open_Cap_Set
     (Client  : out Seekable_File_Reader_Client;
      Read    : Rose.Capabilities.Capability;
      Release : Rose.Capabilities.Capability;
      Seek    : Rose.Capabilities.Capability);

   procedure Open
     (Client        : out Seekable_File_Reader_Client;
      Interface_Cap : Rose.Capabilities.Capability);

   procedure Close (Client : in out Seekable_File_Reader_Client);

   procedure Read
     (Item   : Seekable_File_Reader_Client;
      Buffer : out System.Storage_Elements.Storage_Array;
      Last   : out System.Storage_Elements.Storage_Count);

   procedure Release (Item : Seekable_File_Reader_Client);

   procedure Seek
     (Item              : Seekable_File_Reader_Client;
      Offset_From_Start : Rose.Words.Word_64);

   function Get_Interface_Cap
     (Item : Seekable_File_Reader_Client)
      return Rose.Capabilities.Capability;

   function Get_Read_Cap
     (Item : Seekable_File_Reader_Client)
      return Rose.Capabilities.Capability;

   function Get_Release_Cap
     (Item : Seekable_File_Reader_Client)
      return Rose.Capabilities.Capability;

   function Get_Seek_Cap
     (Item : Seekable_File_Reader_Client)
      return Rose.Capabilities.Capability;

   function Has_Error return Boolean;

   function Get_Last_Error return Rose.Invocation.Invocation_Error;

private

   type Seekable_File_Reader_Client is record
      Is_Open       : Boolean := False;
      Interface_Cap : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
      Read          : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
      Release       : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
      Seek          : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
   end record;

end Rose.Interfaces.Seekable_File_Reader.Client;
