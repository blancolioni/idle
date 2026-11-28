with Interfaces;

package body Rose.Interfaces.Catalogue is

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

   procedure Put_Word_64
     (Buffer : in out Storage_Array;
      Last   : in out Storage_Offset;
      Value  : Unsigned_64);

   function Get_Word_64
     (Buffer : Storage_Array;
      Last   : in out Storage_Offset)
      return Unsigned_64;

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
      Item   : out Entry_Info)
   is
      Start  : constant Storage_Offset := Last;
      Header : constant Unsigned_32 := Get_Word_32 (Buffer, Last);
      Finish : constant Storage_Offset :=
        Start + Storage_Offset (Header and 16#FF_FFFF#);
      Count  : constant Unsigned_32 := Shift_Right (Header, 24);
   begin
      if Count < 5 or else (Finish < Last or else Finish > Buffer'Last) then
         raise Constraint_Error;
      end if;
      Item.Name :=
        Ada.Strings.Unbounded.To_Unbounded_String (Get_String (Buffer, Last));
      Item.Size :=
        Rose.Interfaces.Core.Units.Bytes (Get_Word_64 (Buffer, Last));
      Item.Age :=
        Rose.Interfaces.Core.Units.Duration (Get_Word_64 (Buffer, Last));
      Item.Of_Kind :=
        Rose.Interfaces.Core.Units.Unit_Kind'Val (Get_Word_32 (Buffer, Last));
      Item.Start := Offset (Get_Word_64 (Buffer, Last));
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
      return Entry_Info
   is
      Last   : Storage_Offset := Buffer'First - 1;
      Result : Entry_Info;
   begin
      Decode (Buffer, Last, Result);
      return Result;
   end Decode;

   ------------
   -- Encode --
   ------------

   procedure Encode
     (Item   : Entry_Info;
      Buffer : in out System.Storage_Elements.Storage_Array;
      Last   : in out System.Storage_Elements.Storage_Offset)
   is
      Start : constant Storage_Offset := Last;
   begin
      Last := Last + 4;
      Put_String (Buffer, Last, Ada.Strings.Unbounded.To_String (Item.Name));
      Put_Word_64 (Buffer, Last, Unsigned_64 (Item.Size));
      Put_Word_64 (Buffer, Last, Unsigned_64 (Item.Age));
      Put_Word_32
        (Buffer,
         Last,
         Unsigned_32
           (Rose.Interfaces.Core.Units.Unit_Kind'Pos (Item.Of_Kind)));
      Put_Word_64 (Buffer, Last, Unsigned_64 (Item.Start));
      Put_Header (Buffer, Start, Last, 5);
   end Encode;

   ------------
   -- Encode --
   ------------

   function Encode
     (Item : Entry_Info)
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
     (Item : Entry_Info)
      return System.Storage_Elements.Storage_Count
   is
   begin
      return 36 + Padded
        (System.Storage_Elements.Storage_Count
           (Ada.Strings.Unbounded.Length (Item.Name)));
   end Encoded_Length;

   -----------------------
   -- Entry_Info_Fields --
   -----------------------

   function Entry_Info_Fields return System.Storage_Elements.Storage_Array is
      Result : Storage_Array (1 .. 268);
      Last   : Storage_Offset := 0;
   begin
      Put_Word_32 (Result, Last, 5);
      Put_String (Result, Last, "name");
      Put_String (Result, Last, "string");
      Put_Word_32 (Result, Last, 7);
      Put_String (Result, Last, "size");
      Put_String (Result, Last, "rose.interfaces.core.units.bytes");
      Put_Word_32 (Result, Last, 2);
      Put_String (Result, Last, "");
      Put_String (Result, Last, "age");
      Put_String (Result, Last, "rose.interfaces.core.units.duration");
      Put_Word_32 (Result, Last, 2);
      Put_String (Result, Last, "");
      Put_String (Result, Last, "of_kind");
      Put_String (Result, Last, "rose.interfaces.core.units.unit_kind");
      Put_Word_32 (Result, Last, 6);
      Put_Word_32 (Result, Last, 2);
      Put_String (Result, Last, "size");
      Put_String (Result, Last, "time");
      Put_String (Result, Last, "start");
      Put_String (Result, Last, "rose.interfaces.catalogue.offset");
      Put_Word_32 (Result, Last, 2);
      Put_String (Result, Last, "");
      return Result;
   end Entry_Info_Fields;

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

   -----------------
   -- Get_Word_64 --
   -----------------

   function Get_Word_64
     (Buffer : Storage_Array;
      Last   : in out Storage_Offset)
      return Unsigned_64
   is
      Low  : constant Unsigned_64 := Unsigned_64 (Get_Word_32 (Buffer, Last));
      High : constant Unsigned_64 := Unsigned_64 (Get_Word_32 (Buffer, Last));
   begin
      return Low or Shift_Left (High, 32);
   end Get_Word_64;

   ------------
   -- Padded --
   ------------

   function Padded (Length : Storage_Count) return Storage_Count is
   begin
      return (Length + 3) / 4 * 4;
   end Padded;

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

   -----------------
   -- Put_Word_64 --
   -----------------

   procedure Put_Word_64
     (Buffer : in out Storage_Array;
      Last   : in out Storage_Offset;
      Value  : Unsigned_64)
   is
   begin
      Put_Word_32 (Buffer, Last, Unsigned_32 (Value and 16#FFFF_FFFF#));
      Put_Word_32 (Buffer, Last, Unsigned_32 (Shift_Right (Value, 32)));
   end Put_Word_64;

end Rose.Interfaces.Catalogue;
