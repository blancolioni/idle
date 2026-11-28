with Interfaces;

package body Rose.Interfaces.Search is

   use Standard.Interfaces;

   use System.Storage_Elements;

   procedure Put_Word_32
     (Buffer : in out Storage_Array;
      Last   : in out Storage_Offset;
      Value  : Unsigned_32);

   function Get_Word_32
     (Buffer : Storage_Array;
      Last   : in out Storage_Offset)
      return Unsigned_32;

   procedure Put_Header
     (Buffer : in out Storage_Array;
      Start  : Storage_Offset;
      Finish : Storage_Offset;
      Count  : Unsigned_32);

   function Padded (Length : Storage_Count) return Storage_Count;

   procedure Put_String
     (Buffer : in out Storage_Array;
      Last   : in out Storage_Offset;
      Value  : String);

   function Get_String
     (Buffer : Storage_Array;
      Last   : in out Storage_Offset)
      return String;

   ------------
   -- Decode --
   ------------

   procedure Decode
     (Buffer : System.Storage_Elements.Storage_Array;
      Last   : in out System.Storage_Elements.Storage_Offset;
      Item   : out Place)
   is
      Start  : constant Storage_Offset := Last;
      Header : constant Unsigned_32 := Get_Word_32 (Buffer, Last);
      Finish : constant Storage_Offset :=
        Start + Storage_Offset (Header and 16#FF_FFFF#);
      Count  : constant Unsigned_32 := Shift_Right (Header, 24);
   begin
      if Count < 2 or else (Finish < Last or else Finish > Buffer'Last) then
         raise Constraint_Error;
      end if;
      Item.File :=
        Ada.Strings.Unbounded.To_Unbounded_String (Get_String (Buffer, Last));
      Item.Line := Natural (Get_Word_32 (Buffer, Last));
      if Last > Finish then
         raise Constraint_Error;
      end if;
      Last := Finish;
   end Decode;

   ------------
   -- Decode --
   ------------

   function Decode
     (Buffer : System.Storage_Elements.Storage_Array)
      return Place
   is
      Last   : Storage_Offset := Buffer'First - 1;
      Result : Place;
   begin
      Decode (Buffer, Last, Result);
      return Result;
   end Decode;

   ------------
   -- Decode --
   ------------

   procedure Decode
     (Buffer : System.Storage_Elements.Storage_Array;
      Last   : in out System.Storage_Elements.Storage_Offset;
      Item   : out Grep_Match)
   is
      Start  : constant Storage_Offset := Last;
      Header : constant Unsigned_32 := Get_Word_32 (Buffer, Last);
      Finish : constant Storage_Offset :=
        Start + Storage_Offset (Header and 16#FF_FFFF#);
      Count  : constant Unsigned_32 := Shift_Right (Header, 24);
   begin
      if Count < 2 or else (Finish < Last or else Finish > Buffer'Last) then
         raise Constraint_Error;
      end if;
      Decode (Buffer, Last, Item.Where);
      Item.Text :=
        Ada.Strings.Unbounded.To_Unbounded_String (Get_String (Buffer, Last));
      if Last > Finish then
         raise Constraint_Error;
      end if;
      Last := Finish;
   end Decode;

   ------------
   -- Decode --
   ------------

   function Decode
     (Buffer : System.Storage_Elements.Storage_Array)
      return Grep_Match
   is
      Last   : Storage_Offset := Buffer'First - 1;
      Result : Grep_Match;
   begin
      Decode (Buffer, Last, Result);
      return Result;
   end Decode;

   ------------
   -- Encode --
   ------------

   procedure Encode
     (Item   : Place;
      Buffer : in out System.Storage_Elements.Storage_Array;
      Last   : in out System.Storage_Elements.Storage_Offset)
   is
      Start : constant Storage_Offset := Last;
   begin
      Last := Last + 4;
      Put_String (Buffer, Last, Ada.Strings.Unbounded.To_String (Item.File));
      Put_Word_32 (Buffer, Last, Unsigned_32 (Item.Line));
      Put_Header (Buffer, Start, Last, 2);
   end Encode;

   ------------
   -- Encode --
   ------------

   function Encode
     (Item : Place)
      return System.Storage_Elements.Storage_Array
   is
      Result : Storage_Array (1 .. Encoded_Length (Item));
      Last   : Storage_Offset := 0;
   begin
      Encode (Item, Result, Last);
      return Result;
   end Encode;

   ------------
   -- Encode --
   ------------

   procedure Encode
     (Item   : Grep_Match;
      Buffer : in out System.Storage_Elements.Storage_Array;
      Last   : in out System.Storage_Elements.Storage_Offset)
   is
      Start : constant Storage_Offset := Last;
   begin
      Last := Last + 4;
      Encode (Item.Where, Buffer, Last);
      Put_String (Buffer, Last, Ada.Strings.Unbounded.To_String (Item.Text));
      Put_Header (Buffer, Start, Last, 2);
   end Encode;

   ------------
   -- Encode --
   ------------

   function Encode
     (Item : Grep_Match)
      return System.Storage_Elements.Storage_Array
   is
      Result : Storage_Array (1 .. Encoded_Length (Item));
      Last   : Storage_Offset := 0;
   begin
      Encode (Item, Result, Last);
      return Result;
   end Encode;

   --------------------
   -- Encoded_Length --
   --------------------

   function Encoded_Length
     (Item : Place)
      return System.Storage_Elements.Storage_Count
   is
   begin
      return 12 + Padded
        (System.Storage_Elements.Storage_Count
           (Ada.Strings.Unbounded.Length (Item.File)));
   end Encoded_Length;

   --------------------
   -- Encoded_Length --
   --------------------

   function Encoded_Length
     (Item : Grep_Match)
      return System.Storage_Elements.Storage_Count
   is
   begin
      return 8 + Encoded_Length (Item.Where) + Padded
        (System.Storage_Elements.Storage_Count
           (Ada.Strings.Unbounded.Length (Item.Text)));
   end Encoded_Length;

   ----------------
   -- Get_String --
   ----------------

   function Get_String
     (Buffer : Storage_Array;
      Last   : in out Storage_Offset)
      return String
   is
      Length : constant Storage_Count :=
        Storage_Count (Get_Word_32 (Buffer, Last));
      Bytes  : constant Storage_Array :=
        Buffer ((Last + 1) .. (Last + Length));
      Result : String (1 .. Natural (Length));
      Index  : Natural := 0;
   begin
      for Element of Bytes loop
         Index := Index + 1;
         Result (Index) := Character'Val (Element);
      end loop;
      Last := Last + Padded (Length);
      return Result;
   end Get_String;

   -----------------
   -- Get_Word_32 --
   -----------------

   function Get_Word_32
     (Buffer : Storage_Array;
      Last   : in out Storage_Offset)
      return Unsigned_32
   is
      Result : constant Unsigned_32 :=
        Unsigned_32 (Buffer (Last + 1))
          or Shift_Left (Unsigned_32 (Buffer (Last + 2)), 8)
          or Shift_Left (Unsigned_32 (Buffer (Last + 3)), 16)
          or Shift_Left (Unsigned_32 (Buffer (Last + 4)), 24);
   begin
      Last := Last + 4;
      return Result;
   end Get_Word_32;

   -----------------------
   -- Grep_Match_Fields --
   -----------------------

   function Grep_Match_Fields return System.Storage_Elements.Storage_Array is
      Result : Storage_Array (1 .. 132);
      Last   : Storage_Offset := 0;
   begin
      Put_Word_32 (Result, Last, 2);
      Put_String (Result, Last, "where");
      Put_String (Result, Last, "rose.interfaces.search.place");
      Put_Word_32 (Result, Last, 8);
      Put_Word_32 (Result, Last, 2);
      Put_String (Result, Last, "file");
      Put_String (Result, Last, "string");
      Put_Word_32 (Result, Last, 7);
      Put_String (Result, Last, "line");
      Put_String (Result, Last, "natural");
      Put_Word_32 (Result, Last, 1);
      Put_String (Result, Last, "");
      Put_String (Result, Last, "text");
      Put_String (Result, Last, "string");
      Put_Word_32 (Result, Last, 7);
      return Result;
   end Grep_Match_Fields;

   ------------
   -- Padded --
   ------------

   function Padded (Length : Storage_Count) return Storage_Count is
   begin
      return (Length + 3) / 4 * 4;
   end Padded;

   ------------------
   -- Place_Fields --
   ------------------

   function Place_Fields return System.Storage_Elements.Storage_Array is
      Result : Storage_Array (1 .. 56);
      Last   : Storage_Offset := 0;
   begin
      Put_Word_32 (Result, Last, 2);
      Put_String (Result, Last, "file");
      Put_String (Result, Last, "string");
      Put_Word_32 (Result, Last, 7);
      Put_String (Result, Last, "line");
      Put_String (Result, Last, "natural");
      Put_Word_32 (Result, Last, 1);
      Put_String (Result, Last, "");
      return Result;
   end Place_Fields;

   ----------------
   -- Put_Header --
   ----------------

   procedure Put_Header
     (Buffer : in out Storage_Array;
      Start  : Storage_Offset;
      Finish : Storage_Offset;
      Count  : Unsigned_32)
   is
      Position : Storage_Offset := Start;
   begin
      if Finish - Start > 16#FF_FFFF# then
         raise Constraint_Error;
      end if;
      Put_Word_32
        (Buffer,
         Position,
         Unsigned_32 (Finish - Start) or Shift_Left (Count, 24));
   end Put_Header;

   ----------------
   -- Put_String --
   ----------------

   procedure Put_String
     (Buffer : in out Storage_Array;
      Last   : in out Storage_Offset;
      Value  : String)
   is
      Length  : constant Storage_Count := Storage_Count (Value'Length);
      Padding : constant Storage_Count := Padded (Length) - Length;
   begin
      Put_Word_32 (Buffer, Last, Unsigned_32 (Length));
      for Ch of Value loop
         Last := Last + 1;
         Buffer (Last) := Character'Pos (Ch);
      end loop;
      for Element of Buffer ((Last + 1) .. (Last + Padding)) loop
         Element := 0;
      end loop;
      Last := Last + Padding;
   end Put_String;

   -----------------
   -- Put_Word_32 --
   -----------------

   procedure Put_Word_32
     (Buffer : in out Storage_Array;
      Last   : in out Storage_Offset;
      Value  : Unsigned_32)
   is
   begin
      Buffer (Last + 1) := Storage_Element (Value and 16#FF#);
      Buffer (Last + 2) := Storage_Element (Shift_Right (Value, 8) and 16#FF#);
      Buffer (Last + 3) :=
        Storage_Element (Shift_Right (Value, 16) and 16#FF#);
      Buffer (Last + 4) := Storage_Element (Shift_Right (Value, 24));
      Last := Last + 4;
   end Put_Word_32;

end Rose.Interfaces.Search;
