with Interfaces;

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
      Item   : out File_Info_V1)
   is
   begin
      Item.Name :=
        Ada.Strings.Unbounded.To_Unbounded_String (Get_String (Buffer, Last));
   end Decode;

   ------------
   -- Decode --
   ------------

   function Decode
     (Buffer : System.Storage_Elements.Storage_Array)
      return File_Info_V1
   is
      Last   : Storage_Offset := Buffer'First - 1;
      Result : File_Info_V1;
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
   begin
      Item.Name :=
        Ada.Strings.Unbounded.To_Unbounded_String (Get_String (Buffer, Last));
      Item.Size := Natural (Get_Word_32 (Buffer, Last));
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
   -- Decode --
   ------------

   procedure Decode
     (Buffer : System.Storage_Elements.Storage_Array;
      Last   : in out System.Storage_Elements.Storage_Offset;
      Item   : out Bundle)
   is
   begin
      Decode (Buffer, Last, Item.Old);
      Decode (Buffer, Last, Item.Current);
   end Decode;

   ------------
   -- Decode --
   ------------

   function Decode
     (Buffer : System.Storage_Elements.Storage_Array)
      return Bundle
   is
      Last   : Storage_Offset := Buffer'First - 1;
      Result : Bundle;
   begin
      Decode (Buffer, Last, Result);
      return Result;
   end Decode;

   ------------
   -- Encode --
   ------------

   procedure Encode
     (Item   : File_Info_V1;
      Buffer : in out System.Storage_Elements.Storage_Array;
      Last   : in out System.Storage_Elements.Storage_Offset)
   is
   begin
      Put_String (Buffer, Last, Ada.Strings.Unbounded.To_String (Item.Name));
   end Encode;

   ------------
   -- Encode --
   ------------

   function Encode
     (Item : File_Info_V1)
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
   begin
      Put_String (Buffer, Last, Ada.Strings.Unbounded.To_String (Item.Name));
      Put_Word_32 (Buffer, Last, Unsigned_32 (Item.Size));
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

   ------------
   -- Encode --
   ------------

   procedure Encode
     (Item   : Bundle;
      Buffer : in out System.Storage_Elements.Storage_Array;
      Last   : in out System.Storage_Elements.Storage_Offset)
   is
   begin
      Encode (Item.Old, Buffer, Last);
      Encode (Item.Current, Buffer, Last);
   end Encode;

   ------------
   -- Encode --
   ------------

   function Encode
     (Item : Bundle)
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
     (Item : File_Info_V1)
      return System.Storage_Elements.Storage_Count
   is
   begin
      return 4 + Padded
        (System.Storage_Elements.Storage_Count
           (Ada.Strings.Unbounded.Length (Item.Name)));
   end Encoded_Length;

   --------------------
   -- Encoded_Length --
   --------------------

   function Encoded_Length
     (Item : File_Info)
      return System.Storage_Elements.Storage_Count
   is
   begin
      return 8 + Padded
        (System.Storage_Elements.Storage_Count
           (Ada.Strings.Unbounded.Length (Item.Name)));
   end Encoded_Length;

   --------------------
   -- Encoded_Length --
   --------------------

   function Encoded_Length
     (Item : Bundle)
      return System.Storage_Elements.Storage_Count
   is
   begin
      return Encoded_Length (Item.Old) + Encoded_Length (Item.Current);
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

   ------------
   -- Padded --
   ------------

   function Padded (Length : Storage_Count) return Storage_Count is
   begin
      return (Length + 3) / 4 * 4;
   end Padded;

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

end Rose.Interfaces.Shelf;
