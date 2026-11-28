with Ada.Strings.Unbounded;
with Interfaces;
with Rose.Capabilities;
with Rose.Interfaces.Finder;
with Rose.Interfaces.Search;
with Rose.Objects;
with System.Storage_Elements;

package Rose.Interfaces.Editor is

   type Mode is (Read_Only, Writable);

   type Location is record
      Path   : Ada.Strings.Unbounded.Unbounded_String;
      Line   : Natural := 0;
      Opened : Mode := Read_Only;
   end record;

   type Dated is record
      Moment : Standard.Interfaces.Integer_64;
   end record;

   type Note is record
      Path : Ada.Strings.Unbounded.Unbounded_String;
      Line : Natural;
      Text : Ada.Strings.Unbounded.Unbounded_String;
   end record;

   Location_Type_Id : constant Rose.Objects.Endpoint_Id :=
     16#9B5C_ED1E_520D_3B6F#;

   function Encoded_Length
     (Item : Location)
      return System.Storage_Elements.Storage_Count;

   procedure Encode
     (Item   : Location;
      Buffer : in out System.Storage_Elements.Storage_Array;
      Last   : in out System.Storage_Elements.Storage_Offset);

   function Encode
     (Item : Location)
      return System.Storage_Elements.Storage_Array;

   procedure Decode
     (Buffer : System.Storage_Elements.Storage_Array;
      Last   : in out System.Storage_Elements.Storage_Offset;
      Item   : out Location);

   function Decode
     (Buffer : System.Storage_Elements.Storage_Array)
      return Location;

   Dated_Type_Id    : constant Rose.Objects.Endpoint_Id :=
     16#AC36_8ACB_A075_B158#;

   function Encoded_Length
     (Item : Dated)
      return System.Storage_Elements.Storage_Count;

   procedure Encode
     (Item   : Dated;
      Buffer : in out System.Storage_Elements.Storage_Array;
      Last   : in out System.Storage_Elements.Storage_Offset);

   function Encode (Item : Dated) return System.Storage_Elements.Storage_Array;

   procedure Decode
     (Buffer : System.Storage_Elements.Storage_Array;
      Last   : in out System.Storage_Elements.Storage_Offset;
      Item   : out Dated);

   function Decode
     (Buffer : System.Storage_Elements.Storage_Array)
      return Dated;

   Note_Type_Id     : constant Rose.Objects.Endpoint_Id :=
     16#2D95_3C03_FFCA_B8F1#;

   function Encoded_Length
     (Item : Note)
      return System.Storage_Elements.Storage_Count;

   procedure Encode
     (Item   : Note;
      Buffer : in out System.Storage_Elements.Storage_Array;
      Last   : in out System.Storage_Elements.Storage_Offset);

   function Encode (Item : Note) return System.Storage_Elements.Storage_Array;

   procedure Decode
     (Buffer : System.Storage_Elements.Storage_Array;
      Last   : in out System.Storage_Elements.Storage_Offset;
      Item   : out Note);

   function Decode
     (Buffer : System.Storage_Elements.Storage_Array)
      return Note;

   function To_Location
     (Item : Rose.Interfaces.Search.Grep_Match)
      return Location;

   function To_Location
     (Item : Rose.Interfaces.Finder.File_Info)
      return Location;

   function To_Dated (Item : Rose.Interfaces.Finder.File_Info) return Dated;

   function To_Dated_Created
     (Item : Rose.Interfaces.Finder.File_Info)
      return Dated;

   function To_Dated (Item : Rose.Interfaces.Search.Grep_Match) return Dated;

   function To_Location (Item : Note) return Location;

   Editor_Interface : constant Rose.Objects.Endpoint_Id :=
     16#13CC_F98F_8BFD_8B2F#;

   Show_Endpoint    : constant Rose.Objects.Endpoint_Id :=
     16#FE0C_DB7C_01F3_04B0#;

   Show_Index       : constant := 0;

   Subprogram_Count : constant := 1;

   type Editor_Object is limited interface;

   function Editor_Cap
     (Item : in out Editor_Object)
      return Rose.Capabilities.Capability is abstract;

   procedure Show
     (Item  : in out Editor_Object;
      Place : Rose.Interfaces.Editor.Location) is abstract;

end Rose.Interfaces.Editor;
