with Rose.Capabilities;
with Rose.Interfaces.File.Client;
with Rose.Invocation;
with System.Storage_Elements;

package Rose.Interfaces.Directory.Client is

   type Directory_Client is private;

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

   procedure Close (Client : in out Directory_Client);

   function Directory_Entry_Count (Item : Directory_Client) return Natural;

   procedure Directory_Entry_Name
     (Item   : Directory_Client;
      Index  : Positive;
      Result : out String;
      Last   : out Natural);

   function Directory_Entry_Kind
     (Item  : Directory_Client;
      Index : Positive)
      return Rose.Interfaces.Directory.File_Kind;

   function Directory_Entry_Size
     (Item  : Directory_Client;
      Index : Positive)
      return System.Storage_Elements.Storage_Count;

   function Find_Entry (Item : Directory_Client; Name : String) return Natural;

   function Get_Ordinary_File
     (Item  : Directory_Client;
      Index : Positive)
      return Rose.Interfaces.File.Client.File_Client;

   function Get_Directory
     (Item  : Directory_Client;
      Index : Positive)
      return Directory_Client;

   function Get_Interface_Cap
     (Item : Directory_Client)
      return Rose.Capabilities.Capability;

   function Get_Directory_Entry_Count_Cap
     (Item : Directory_Client)
      return Rose.Capabilities.Capability;

   function Get_Directory_Entry_Name_Cap
     (Item : Directory_Client)
      return Rose.Capabilities.Capability;

   function Get_Directory_Entry_Kind_Cap
     (Item : Directory_Client)
      return Rose.Capabilities.Capability;

   function Get_Directory_Entry_Size_Cap
     (Item : Directory_Client)
      return Rose.Capabilities.Capability;

   function Get_Find_Entry_Cap
     (Item : Directory_Client)
      return Rose.Capabilities.Capability;

   function Get_Get_Ordinary_File_Cap
     (Item : Directory_Client)
      return Rose.Capabilities.Capability;

   function Get_Get_Directory_Cap
     (Item : Directory_Client)
      return Rose.Capabilities.Capability;

   function Has_Error return Boolean;

   function Get_Last_Error return Rose.Invocation.Invocation_Error;

private

   type Directory_Client is record
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
