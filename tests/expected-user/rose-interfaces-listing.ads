with Ada.Strings.Unbounded;
with Interfaces;
with Rose.Capabilities;
with Rose.Objects;
with Rose.Words;
with System.Storage_Elements;

package Rose.Interfaces.Listing is

   type Kind is (Plain, Directory, Link);

   type Block_Count is range 0 .. 1_000_000;

   type Stamp is record
      Seconds : Standard.Interfaces.Integer_64;
      Zone    : Standard.Interfaces.Integer_32;
   end record;

   type File_Info is record
      Name     : Ada.Strings.Unbounded.Unbounded_String;
      Size     : Natural;
      Blocks   : Block_Count;
      Of_Kind  : Kind;
      Hidden   : Boolean;
      Raw      : Rose.Words.Word;
      Id       : Rose.Objects.Object_Id;
      Modified : Stamp;
      Target   : Ada.Strings.Unbounded.Unbounded_String;
   end record;

   Stamp_Type_Id     : constant Rose.Objects.Endpoint_Id :=
     16#2842_2EDB_86B9_10F9#;

   function Encoded_Length
     (Item : Stamp)
      return System.Storage_Elements.Storage_Count;

   procedure Encode
     (Item   : Stamp;
      Buffer : in out System.Storage_Elements.Storage_Array;
      Last   : in out System.Storage_Elements.Storage_Offset);

   function Encode (Item : Stamp) return System.Storage_Elements.Storage_Array;

   procedure Decode
     (Buffer : System.Storage_Elements.Storage_Array;
      Last   : in out System.Storage_Elements.Storage_Offset;
      Item   : out Stamp);

   function Decode
     (Buffer : System.Storage_Elements.Storage_Array)
      return Stamp;

   File_Info_Type_Id : constant Rose.Objects.Endpoint_Id :=
     16#3582_BD20_3ADD_A47D#;

   function Encoded_Length
     (Item : File_Info)
      return System.Storage_Elements.Storage_Count;

   procedure Encode
     (Item   : File_Info;
      Buffer : in out System.Storage_Elements.Storage_Array;
      Last   : in out System.Storage_Elements.Storage_Offset);

   function Encode
     (Item : File_Info)
      return System.Storage_Elements.Storage_Array;

   procedure Decode
     (Buffer : System.Storage_Elements.Storage_Array;
      Last   : in out System.Storage_Elements.Storage_Offset;
      Item   : out File_Info);

   function Decode
     (Buffer : System.Storage_Elements.Storage_Array)
      return File_Info;

   Listing_Interface : constant Rose.Objects.Endpoint_Id :=
     16#8B38_45FE_68CC_450A#;

   Add_Endpoint      : constant Rose.Objects.Endpoint_Id :=
     16#71F9_F09A_31A8_DC4C#;

   Rename_Endpoint   : constant Rose.Objects.Endpoint_Id :=
     16#8E37_6F10_F983_2284#;

   Find_Endpoint     : constant Rose.Objects.Endpoint_Id :=
     16#8AC6_37CA_F00A_A681#;

   Get_Endpoint      : constant Rose.Objects.Endpoint_Id :=
     16#1716_F12A_40A2_F123#;

   Now_Endpoint      : constant Rose.Objects.Endpoint_Id :=
     16#DC59_92D3_EBA3_84D0#;

   Add_Index         : constant := 0;

   Rename_Index      : constant := 1;

   Find_Index        : constant := 2;

   Get_Index         : constant := 3;

   Now_Index         : constant := 4;

   Subprogram_Count  : constant := 5;

   type Listing_Object is limited interface;

   function Listing_Cap
     (Item : in out Listing_Object)
      return Rose.Capabilities.Capability is abstract;

   procedure Add
     (Item : in out Listing_Object;
      Info : Rose.Interfaces.Listing.File_Info) is abstract;

   procedure Rename
     (Item     : in out Listing_Object;
      Info     : Rose.Interfaces.Listing.File_Info;
      New_Name : String) is abstract;

   function Find
     (Item  : in out Listing_Object;
      Index : Natural)
      return Rose.Interfaces.Listing.File_Info is abstract;

   procedure Get
     (Item  : in out Listing_Object;
      Index : Natural;
      Info  : out Rose.Interfaces.Listing.File_Info;
      Count : out Natural) is abstract;

   function Now
     (Item : in out Listing_Object)
      return Rose.Interfaces.Listing.Stamp is abstract;

end Rose.Interfaces.Listing;
