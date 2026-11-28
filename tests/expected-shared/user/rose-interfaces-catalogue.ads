with Ada.Strings.Unbounded;
with Rose.Capabilities;
with Rose.Interfaces.Core.Units;
with Rose.Objects;
with System.Storage_Elements;

package Rose.Interfaces.Catalogue is

   type Offset is new Rose.Interfaces.Core.Units.Bytes;

   type Entry_Info is record
      Name    : Ada.Strings.Unbounded.Unbounded_String;
      Size    : Rose.Interfaces.Core.Units.Bytes;
      Age     : Rose.Interfaces.Core.Units.Duration;
      Of_Kind : Rose.Interfaces.Core.Units.Unit_Kind;
      Start   : Offset;
   end record;

   Entry_Info_Type_Id  : constant Rose.Objects.Endpoint_Id :=
     16#E0B9_A6E7_A06D_2516#;

   function Entry_Info_Fields return System.Storage_Elements.Storage_Array;

   function Encoded_Length
     (Item : Entry_Info)
      return System.Storage_Elements.Storage_Count;

   procedure Encode
     (Item   : Entry_Info;
      Buffer : in out System.Storage_Elements.Storage_Array;
      Last   : in out System.Storage_Elements.Storage_Offset);

   function Encode
     (Item : Entry_Info)
      return System.Storage_Elements.Storage_Array;

   procedure Decode
     (Buffer : System.Storage_Elements.Storage_Array;
      Last   : in out System.Storage_Elements.Storage_Offset;
      Item   : out Entry_Info);

   function Decode
     (Buffer : System.Storage_Elements.Storage_Array)
      return Entry_Info;

   Catalogue_Interface : constant Rose.Objects.Endpoint_Id :=
     16#8A2D_EBB0_6967_D953#;

   Total_Endpoint      : constant Rose.Objects.Endpoint_Id :=
     16#F470_A423_5C60_2D97#;

   Resize_Endpoint     : constant Rose.Objects.Endpoint_Id :=
     16#880E_BAC0_D3EC_7F13#;

   Find_Endpoint       : constant Rose.Objects.Endpoint_Id :=
     16#4021_52ED_4F74_E72C#;

   Total_Index         : constant := 0;

   Resize_Index        : constant := 1;

   Find_Index          : constant := 2;

   Subprogram_Count    : constant := 3;

   type Catalogue_Object is limited interface;

   function Catalogue_Cap
     (Item : in out Catalogue_Object)
      return Rose.Capabilities.Capability is abstract;

   function Total
     (Item : in out Catalogue_Object)
      return Rose.Interfaces.Core.Units.Bytes is abstract;

   procedure Resize
     (Item : in out Catalogue_Object;
      Size : Rose.Interfaces.Core.Units.Bytes;
      Done : out Rose.Interfaces.Core.Units.Percent) is abstract;

   function Find
     (Item  : in out Catalogue_Object;
      Index : Natural)
      return Rose.Interfaces.Catalogue.Entry_Info is abstract;

end Rose.Interfaces.Catalogue;
