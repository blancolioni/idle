with Rose.Capabilities;

package Rose.Interfaces.Listing.Client is

   type Listing_Client is
     limited new Rose.Interfaces.Listing.Listing_Object
     with private;

   procedure Open_Cap_Set
     (Client : out Listing_Client;
      Add    : Rose.Capabilities.Capability;
      Rename : Rose.Capabilities.Capability;
      Find   : Rose.Capabilities.Capability;
      Get    : Rose.Capabilities.Capability;
      Now    : Rose.Capabilities.Capability);

   procedure Open
     (Client        : out Listing_Client;
      Interface_Cap : Rose.Capabilities.Capability);

   function From_Cap
     (Cap : Rose.Capabilities.Capability)
      return Listing_Client;

   procedure Close (Client : in out Listing_Client);

   overriding procedure Add
     (Item : in out Listing_Client;
      Info : Rose.Interfaces.Listing.File_Info);

   overriding procedure Rename
     (Item     : in out Listing_Client;
      Info     : Rose.Interfaces.Listing.File_Info;
      New_Name : String);

   overriding function Find
     (Item  : in out Listing_Client;
      Index : Natural)
      return Rose.Interfaces.Listing.File_Info;

   overriding procedure Get
     (Item  : in out Listing_Client;
      Index : Natural;
      Info  : out Rose.Interfaces.Listing.File_Info;
      Count : out Natural);

   overriding function Now
     (Item : in out Listing_Client)
      return Rose.Interfaces.Listing.Stamp;

   overriding function Listing_Cap
     (Item : in out Listing_Client)
      return Rose.Capabilities.Capability;

   function Get_Interface_Cap
     (Item : Listing_Client)
      return Rose.Capabilities.Capability;

   function Get_Add_Cap
     (Item : in out Listing_Client)
      return Rose.Capabilities.Capability;

   function Get_Rename_Cap
     (Item : in out Listing_Client)
      return Rose.Capabilities.Capability;

   function Get_Find_Cap
     (Item : in out Listing_Client)
      return Rose.Capabilities.Capability;

   function Get_Get_Cap
     (Item : in out Listing_Client)
      return Rose.Capabilities.Capability;

   function Get_Now_Cap
     (Item : in out Listing_Client)
      return Rose.Capabilities.Capability;

private

   type Listing_Client is
     limited new Rose.Interfaces.Listing.Listing_Object
   with record
      Is_Open       : Boolean := False;
      Interface_Cap : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
      Add           : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
      Rename        : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
      Find          : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
      Get           : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
      Now           : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
   end record;

end Rose.Interfaces.Listing.Client;
