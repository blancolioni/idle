with Rose.Capabilities;
with Rose.Interfaces.File;
with System.Storage_Elements;

package Rose.Interfaces.Directory.Client is

   type Directory_Client is
     limited new Rose.Interfaces.Directory.Directory_Object
     with private;

   procedure Open_Cap_Set
     (Client                : out Directory_Client;
      Directory_Entry_Count : Rose.Capabilities.Capability;
      Directory_Entry_Name  : Rose.Capabilities.Capability;
      Directory_Entry_Kind  : Rose.Capabilities.Capability;
      Directory_Entry_Size  : Rose.Capabilities.Capability;
      Find_Entry            : Rose.Capabilities.Capability;
      Get_Ordinary_File     : Rose.Capabilities.Capability;
      Get_Directory         : Rose.Capabilities.Capability);

   procedure Open
     (Client        : out Directory_Client;
      Interface_Cap : Rose.Capabilities.Capability);

   function From_Cap
     (Cap : Rose.Capabilities.Capability)
      return Directory_Client;

   procedure Close (Client : in out Directory_Client);

   overriding function Directory_Entry_Count
     (Item : in out Directory_Client)
      return Natural;

   overriding function Directory_Entry_Name
     (Item  : in out Directory_Client;
      Index : Positive)
      return String;

   overriding function Directory_Entry_Kind
     (Item  : in out Directory_Client;
      Index : Positive)
      return Rose.Interfaces.Directory.File_Kind;

   overriding function Directory_Entry_Size
     (Item  : in out Directory_Client;
      Index : Positive)
      return System.Storage_Elements.Storage_Count;

   overriding function Find_Entry
     (Item : in out Directory_Client;
      Name : String)
      return Natural;

   overriding function Get_Ordinary_File
     (Item  : in out Directory_Client;
      Index : Positive)
      return Rose.Interfaces.File.File_Object'Class;

   overriding function Get_Directory
     (Item  : in out Directory_Client;
      Index : Positive)
      return Rose.Interfaces.Directory.Directory_Object'Class;

   overriding function Directory_Cap
     (Item : in out Directory_Client)
      return Rose.Capabilities.Capability;

   function Get_Interface_Cap
     (Item : Directory_Client)
      return Rose.Capabilities.Capability;

   function Get_Directory_Entry_Count_Cap
     (Item : in out Directory_Client)
      return Rose.Capabilities.Capability;

   function Get_Directory_Entry_Name_Cap
     (Item : in out Directory_Client)
      return Rose.Capabilities.Capability;

   function Get_Directory_Entry_Kind_Cap
     (Item : in out Directory_Client)
      return Rose.Capabilities.Capability;

   function Get_Directory_Entry_Size_Cap
     (Item : in out Directory_Client)
      return Rose.Capabilities.Capability;

   function Get_Find_Entry_Cap
     (Item : in out Directory_Client)
      return Rose.Capabilities.Capability;

   function Get_Get_Ordinary_File_Cap
     (Item : in out Directory_Client)
      return Rose.Capabilities.Capability;

   function Get_Get_Directory_Cap
     (Item : in out Directory_Client)
      return Rose.Capabilities.Capability;

private

   type Directory_Client is
     limited new Rose.Interfaces.Directory.Directory_Object
   with record
      Is_Open               : Boolean := False;
      Interface_Cap         : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
      Directory_Entry_Count : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
      Directory_Entry_Name  : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
      Directory_Entry_Kind  : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
      Directory_Entry_Size  : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
      Find_Entry            : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
      Get_Ordinary_File     : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
      Get_Directory         : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
   end record;

end Rose.Interfaces.Directory.Client;
