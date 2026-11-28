with Ada.Strings.Unbounded;
with Rose.Capabilities;
with Rose.Objects;
with System.Storage_Elements;

package Rose.Interfaces.Search is

   type Place is record
      File : Ada.Strings.Unbounded.Unbounded_String;
      Line : Natural;
   end record;

   type Grep_Match is record
      Where : Place;
      Text  : Ada.Strings.Unbounded.Unbounded_String;
   end record;

   Place_Type_Id      : constant Rose.Objects.Endpoint_Id :=
     16#752B_29A8_ACBD_8061#;

   function Encoded_Length
     (Item : Place)
      return System.Storage_Elements.Storage_Count;

   procedure Encode
     (Item   : Place;
      Buffer : in out System.Storage_Elements.Storage_Array;
      Last   : in out System.Storage_Elements.Storage_Offset);

   function Encode (Item : Place) return System.Storage_Elements.Storage_Array;

   procedure Decode
     (Buffer : System.Storage_Elements.Storage_Array;
      Last   : in out System.Storage_Elements.Storage_Offset;
      Item   : out Place);

   function Decode
     (Buffer : System.Storage_Elements.Storage_Array)
      return Place;

   Grep_Match_Type_Id : constant Rose.Objects.Endpoint_Id :=
     16#92ED_442D_6CCC_3F0F#;

   function Encoded_Length
     (Item : Grep_Match)
      return System.Storage_Elements.Storage_Count;

   procedure Encode
     (Item   : Grep_Match;
      Buffer : in out System.Storage_Elements.Storage_Array;
      Last   : in out System.Storage_Elements.Storage_Offset);

   function Encode
     (Item : Grep_Match)
      return System.Storage_Elements.Storage_Array;

   procedure Decode
     (Buffer : System.Storage_Elements.Storage_Array;
      Last   : in out System.Storage_Elements.Storage_Offset;
      Item   : out Grep_Match);

   function Decode
     (Buffer : System.Storage_Elements.Storage_Array)
      return Grep_Match;

   Search_Interface   : constant Rose.Objects.Endpoint_Id :=
     16#A91F_5E26_EC23_FD87#;

   Get_Endpoint       : constant Rose.Objects.Endpoint_Id :=
     16#53A5_1412_2EC3_74FA#;

   Get_Index          : constant := 0;

   Subprogram_Count   : constant := 1;

   type Search_Object is limited interface;

   function Search_Cap
     (Item : in out Search_Object)
      return Rose.Capabilities.Capability is abstract;

   function Get
     (Item  : in out Search_Object;
      Index : Natural)
      return Rose.Interfaces.Search.Grep_Match is abstract;

end Rose.Interfaces.Search;
