with Rose.Capabilities;
with Rose.Words;
with System.Storage_Elements;

package Rose.Interfaces.File.Client is

   type File_Client is
     limited new Rose.Interfaces.File.File_Object
     with private;

   procedure Open_Cap_Set
     (Client : out File_Client;
      Read   : Rose.Capabilities.Capability;
      Write  : Rose.Capabilities.Capability;
      Seek   : Rose.Capabilities.Capability);

   procedure Open
     (Client        : out File_Client;
      Interface_Cap : Rose.Capabilities.Capability);

   function From_Cap (Cap : Rose.Capabilities.Capability) return File_Client;

   procedure Close (Client : in out File_Client);

   overriding procedure Read
     (Item   : in out File_Client;
      Buffer : out System.Storage_Elements.Storage_Array;
      Last   : out System.Storage_Elements.Storage_Count);

   overriding procedure Write
     (Item   : in out File_Client;
      Buffer : System.Storage_Elements.Storage_Array);

   overriding procedure Seek
     (Item              : in out File_Client;
      Offset_From_Start : Rose.Words.Word_64);

   overriding function File_Cap
     (Item : in out File_Client)
      return Rose.Capabilities.Capability;

   overriding function Stream_Reader_Cap
     (Item : in out File_Client)
      return Rose.Capabilities.Capability;

   overriding function Stream_Writer_Cap
     (Item : in out File_Client)
      return Rose.Capabilities.Capability;

   overriding function Stream_Cap
     (Item : in out File_Client)
      return Rose.Capabilities.Capability;

   overriding function Seekable_Cap
     (Item : in out File_Client)
      return Rose.Capabilities.Capability;

   function Get_Interface_Cap
     (Item : File_Client)
      return Rose.Capabilities.Capability;

   function Get_Read_Cap
     (Item : in out File_Client)
      return Rose.Capabilities.Capability;

   function Get_Write_Cap
     (Item : in out File_Client)
      return Rose.Capabilities.Capability;

   function Get_Seek_Cap
     (Item : in out File_Client)
      return Rose.Capabilities.Capability;

private

   type File_Client is limited new Rose.Interfaces.File.File_Object with record
      Is_Open                     : Boolean := False;
      Interface_Cap               : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
      Stream_Reader_Interface_Cap : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
      Stream_Writer_Interface_Cap : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
      Stream_Interface_Cap        : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
      Seekable_Interface_Cap      : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
      Read                        : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
      Write                       : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
      Seek                        : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
   end record;

end Rose.Interfaces.File.Client;
