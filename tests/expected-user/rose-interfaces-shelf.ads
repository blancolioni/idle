with Ada.Strings.Unbounded;
with Rose.Capabilities;
with Rose.Objects;
with System.Storage_Elements;

package Rose.Interfaces.Shelf is

   type File_Info_V1 is record
      Name : Ada.Strings.Unbounded.Unbounded_String;
   end record;

   type File_Info is record
      Name : Ada.Strings.Unbounded.Unbounded_String;
      Size : Natural;
   end record;

   type Bundle is record
      Old     : File_Info_V1;
      Current : File_Info;
   end record;

   File_Info_V1_Type_Id : constant Rose.Objects.Endpoint_Id :=
     16#EEFD_44ED_2F67_A837#;

   function Encoded_Length
     (Item : File_Info_V1)
      return System.Storage_Elements.Storage_Count;

   procedure Encode
     (Item   : File_Info_V1;
      Buffer : in out System.Storage_Elements.Storage_Array;
      Last   : in out System.Storage_Elements.Storage_Offset);

   function Encode
     (Item : File_Info_V1)
      return System.Storage_Elements.Storage_Array;

   procedure Decode
     (Buffer : System.Storage_Elements.Storage_Array;
      Last   : in out System.Storage_Elements.Storage_Offset;
      Item   : out File_Info_V1);

   function Decode
     (Buffer : System.Storage_Elements.Storage_Array)
      return File_Info_V1;

   File_Info_Type_Id    : constant Rose.Objects.Endpoint_Id :=
     16#6550_025F_FA21_47E2#;

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

   Bundle_Type_Id       : constant Rose.Objects.Endpoint_Id :=
     16#F029_DC04_0A0C_5035#;

   function Encoded_Length
     (Item : Bundle)
      return System.Storage_Elements.Storage_Count;

   procedure Encode
     (Item   : Bundle;
      Buffer : in out System.Storage_Elements.Storage_Array;
      Last   : in out System.Storage_Elements.Storage_Offset);

   function Encode
     (Item : Bundle)
      return System.Storage_Elements.Storage_Array;

   procedure Decode
     (Buffer : System.Storage_Elements.Storage_Array;
      Last   : in out System.Storage_Elements.Storage_Offset;
      Item   : out Bundle);

   function Decode
     (Buffer : System.Storage_Elements.Storage_Array)
      return Bundle;

   Shelf_Interface      : constant Rose.Objects.Endpoint_Id :=
     16#B145_2C46_7F41_7FD0#;

   Put_Endpoint         : constant Rose.Objects.Endpoint_Id :=
     16#85EF_6C14_BE0A_90D2#;

   Get_Endpoint         : constant Rose.Objects.Endpoint_Id :=
     16#6AF7_1BFD_134A_366D#;

   Get_Old_Endpoint     : constant Rose.Objects.Endpoint_Id :=
     16#2DB2_C14F_8CEA_9DD4#;

   Pack_Endpoint        : constant Rose.Objects.Endpoint_Id :=
     16#A35C_4142_1773_1E80#;

   Put_Index            : constant := 0;

   Get_Index            : constant := 1;

   Get_Old_Index        : constant := 2;

   Pack_Index           : constant := 3;

   Subprogram_Count     : constant := 4;

   type Shelf_Object is limited interface;

   function Shelf_Cap
     (Item : in out Shelf_Object)
      return Rose.Capabilities.Capability is abstract;

   procedure Put
     (Item : in out Shelf_Object;
      Info : Rose.Interfaces.Shelf.File_Info_V1) is abstract;

   function Get
     (Item  : in out Shelf_Object;
      Index : Natural)
      return Rose.Interfaces.Shelf.File_Info is abstract;

   function Get_Old
     (Item  : in out Shelf_Object;
      Index : Natural)
      return Rose.Interfaces.Shelf.File_Info_V1 is abstract;

   function Pack
     (Item : in out Shelf_Object)
      return Rose.Interfaces.Shelf.Bundle is abstract;

end Rose.Interfaces.Shelf;
