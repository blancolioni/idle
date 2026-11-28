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
     16#355D_C49B_DE80_C79B#;

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
     16#C42A_F897_3774_A5CB#;

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
     16#B9D3_C571_6E71_FD05#;

   Rename_Endpoint   : constant Rose.Objects.Endpoint_Id :=
     16#1D1F_9690_24FB_6A48#;

   Find_Endpoint     : constant Rose.Objects.Endpoint_Id :=
     16#4568_4C90_A561_D427#;

   Get_Endpoint      : constant Rose.Objects.Endpoint_Id :=
     16#E6C3_B9C1_253B_C444#;

   Now_Endpoint      : constant Rose.Objects.Endpoint_Id :=
     16#1DDC_CF9A_3C4E_F4AA#;

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
