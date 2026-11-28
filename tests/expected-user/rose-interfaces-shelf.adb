package body Rose.Interfaces.Shelf is

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

   function To_Integer_32 (Value : Unsigned_32) return Integer_32;

   function To_Integer_64 (Value : Unsigned_64) return Integer_64;

   ------------
   -- Decode --
   ------------

   procedure Decode
     (Buffer : System.Storage_Elements.Storage_Array;
      Last   : in out System.Storage_Elements.Storage_Offset;
      Item   : out Stamp)
   is
      Start  : constant Storage_Offset := Last;
      Header : constant Unsigned_32 := Get_Word_32 (Buffer, Last);
      Finish : constant Storage_Offset :=
        Start + Storage_Offset (Header and 16#FF_FFFF#);
      Count  : constant Unsigned_32 := Shift_Right (Header, 24);
   begin
      if Finish < Last or else Finish > Buffer'Last then
         raise Constraint_Error;
      end if;
      if Count >= 1 then
         Item.Seconds := To_Integer_64 (Get_Word_64 (Buffer, Last));
      else
         Item.Seconds := 0;
      end if;
      if Count >= 2 then
         Item.Zone := To_Integer_32 (Get_Word_32 (Buffer, Last));
      else
         Item.Zone := 0;
      end if;
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
      return Stamp
   is
      Last   : Storage_Offset := Buffer'First - 1;
      Result : Stamp;
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
      Item   : out File_Info)
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
      Item.Name :=
        Ada.Strings.Unbounded.To_Unbounded_String (Get_String (Buffer, Last));
      Item.Size := Natural (Get_Word_32 (Buffer, Last));
      if Count >= 3 then
         Item.Blocks := Block_Count (Get_Word_32 (Buffer, Last));
      else
         Item.Blocks := 256;
      end if;
      if Count >= 4 then
         Item.Of_Kind := Kind'Val (Get_Word_32 (Buffer, Last));
      else
         Item.Of_Kind := Plain;
      end if;
      if Count >= 5 then
         Item.Hidden := Get_Word_32 (Buffer, Last) /= 0;
      else
         Item.Hidden := False;
      end if;
      if Count >= 6 then
         Item.Target :=
           Ada.Strings.Unbounded.To_Unbounded_String
             (Get_String (Buffer, Last));
      else
         Item.Target := Ada.Strings.Unbounded.To_Unbounded_String ("none");
      end if;
      if Count >= 7 then
         Decode (Buffer, Last, Item.Modified);
      else
         Item.Modified := (others => <>);
      end if;
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
      return File_Info
   is
      Last   : Storage_Offset := Buffer'First - 1;
      Result : File_Info;
   begin
      Decode (Buffer, Last, Result);
      return Result;
   end Decode;

   ------------
   -- Encode --
   ------------

   procedure Encode
     (Item   : Stamp;
      Buffer : in out System.Storage_Elements.Storage_Array;
      Last   : in out System.Storage_Elements.Storage_Offset)
   is
      Start : constant Storage_Offset := Last;
   begin
      Last := Last + 4;
      Put_Word_64 (Buffer, Last, Unsigned_64'Mod (Item.Seconds));
      Put_Word_32 (Buffer, Last, Unsigned_32'Mod (Item.Zone));
      Put_Header (Buffer, Start, Last, 2);
   end Encode;

   ------------
   -- Encode --
   ------------

   function Encode
     (Item : Stamp)
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
     (Item   : File_Info;
      Buffer : in out System.Storage_Elements.Storage_Array;
      Last   : in out System.Storage_Elements.Storage_Offset)
   is
      Start : constant Storage_Offset := Last;
   begin
      Last := Last + 4;
      Put_String (Buffer, Last, Ada.Strings.Unbounded.To_String (Item.Name));
      Put_Word_32 (Buffer, Last, Unsigned_32 (Item.Size));
      Put_Word_32 (Buffer, Last, Unsigned_32 (Item.Blocks));
      Put_Word_32 (Buffer, Last, Unsigned_32 (Kind'Pos (Item.Of_Kind)));
      Put_Word_32 (Buffer, Last, Unsigned_32 (Boolean'Pos (Item.Hidden)));
      Put_String (Buffer, Last, Ada.Strings.Unbounded.To_String (Item.Target));
      Encode (Item.Modified, Buffer, Last);
      Put_Header (Buffer, Start, Last, 7);
   end Encode;

   ------------
   -- Encode --
   ------------

   function Encode
     (Item : File_Info)
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
     (Item : Stamp)
      return System.Storage_Elements.Storage_Count
   is
      pragma Unreferenced (Item);
   begin
      return 16;
   end Encoded_Length;

   --------------------
   -- Encoded_Length --
   --------------------

   function Encoded_Length
     (Item : File_Info)
      return System.Storage_Elements.Storage_Count
   is
   begin
      return 28 + Padded
        (System.Storage_Elements.Storage_Count
           (Ada.Strings.Unbounded.Length (Item.Name))) + Padded
        (System.Storage_Elements.Storage_Count
           (Ada.Strings.Unbounded.Length (Item.Target))) + Encoded_Length
        (Item.Modified);
   end Encoded_Length;

   ----------------------
   -- File_Info_Fields --
   ----------------------

   function File_Info_Fields return System.Storage_Elements.Storage_Array is
      Result : Storage_Array (1 .. 380);
      Last   : Storage_Offset := 0;
   begin
      Put_Word_32 (Result, Last, 7);
      Put_String (Result, Last, "name");
      Put_String (Result, Last, "string");
      Put_Word_32 (Result, Last, 7);
      Put_String (Result, Last, "size");
      Put_String (Result, Last, "natural");
      Put_Word_32 (Result, Last, 1);
      Put_String (Result, Last, "");
      Put_String (Result, Last, "blocks");
      Put_String (Result, Last, "rose.interfaces.shelf.block_count");
      Put_Word_32 (Result, Last, 1);
      Put_String (Result, Last, "");
      Put_String (Result, Last, "of_kind");
      Put_String (Result, Last, "rose.interfaces.shelf.kind");
      Put_Word_32 (Result, Last, 6);
      Put_Word_32 (Result, Last, 3);
      Put_String (Result, Last, "plain");
      Put_String (Result, Last, "directory");
      Put_String (Result, Last, "link");
      Put_String (Result, Last, "hidden");
      Put_String (Result, Last, "boolean");
      Put_Word_32 (Result, Last, 5);
      Put_String (Result, Last, "target");
      Put_String (Result, Last, "string");
      Put_Word_32 (Result, Last, 7);
      Put_String (Result, Last, "modified");
      Put_String (Result, Last, "rose.interfaces.shelf.stamp");
      Put_Word_32 (Result, Last, 8);
      Put_Word_32 (Result, Last, 2);
      Put_String (Result, Last, "seconds");
      Put_String (Result, Last, "integer_64");
      Put_Word_32 (Result, Last, 4);
      Put_String (Result, Last, "");
      Put_String (Result, Last, "zone");
      Put_String (Result, Last, "integer_32");
      Put_Word_32 (Result, Last, 3);
      Put_String (Result, Last, "");
      return Result;
   end File_Info_Fields;

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

   ------------------
   -- Stamp_Fields --
   ------------------

   function Stamp_Fields return System.Storage_Elements.Storage_Array is
      Result : Storage_Array (1 .. 72);
      Last   : Storage_Offset := 0;
   begin
      Put_Word_32 (Result, Last, 2);
      Put_String (Result, Last, "seconds");
      Put_String (Result, Last, "integer_64");
      Put_Word_32 (Result, Last, 4);
      Put_String (Result, Last, "");
      Put_String (Result, Last, "zone");
      Put_String (Result, Last, "integer_32");
      Put_Word_32 (Result, Last, 3);
      Put_String (Result, Last, "");
      return Result;
   end Stamp_Fields;

   -------------------
   -- To_Integer_32 --
   -------------------

   function To_Integer_32 (Value : Unsigned_32) return Integer_32 is
   begin
      if Value <= 16#7FFF_FFFF# then
         return Integer_32 (Value);
      else
         return -Integer_32 (not Value) - 1;
      end if;
   end To_Integer_32;

   -------------------
   -- To_Integer_64 --
   -------------------

   function To_Integer_64 (Value : Unsigned_64) return Integer_64 is
   begin
      if Value <= 16#7FFF_FFFF_FFFF_FFFF# then
         return Integer_64 (Value);
      else
         return -Integer_64 (not Value) - 1;
      end if;
   end To_Integer_64;

end Rose.Interfaces.Shelf;
