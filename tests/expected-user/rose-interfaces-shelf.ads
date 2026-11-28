with Ada.Strings.Unbounded;
with Interfaces;
with Rose.Capabilities;
with Rose.Objects;
with System.Storage_Elements;

package Rose.Interfaces.Shelf is

   type Kind is (Plain, Directory, Link);

   type Block_Count is range 0 .. 1_000_000;

   type Stamp is record
      Seconds : Standard.Interfaces.Integer_64 := 0;
      Zone    : Standard.Interfaces.Integer_32 := 0;
   end record;

   type File_Info is record
      Name     : Ada.Strings.Unbounded.Unbounded_String;
      Size     : Natural;
      Blocks   : Block_Count := 256;
      Of_Kind  : Kind := Plain;
      Hidden   : Boolean := False;
      Target   : Ada.Strings.Unbounded.Unbounded_String :=
        Ada.Strings.Unbounded.To_Unbounded_String ("none");
      Modified : Stamp;
   end record;

   Stamp_Type_Id     : constant Rose.Objects.Endpoint_Id :=
     16#6268_41B1_9634_E7B9#;

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
     16#E8F1_6F63_94D5_A723#;

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

   Shelf_Interface   : constant Rose.Objects.Endpoint_Id :=
     16#B145_2C46_7F41_7FD0#;

   Put_Endpoint      : constant Rose.Objects.Endpoint_Id :=
     16#CDB1_2E07_9732_70AC#;

   Get_Endpoint      : constant Rose.Objects.Endpoint_Id :=
     16#F601_A5BF_B527_8746#;

   Put_Index         : constant := 0;

   Get_Index         : constant := 1;

   Subprogram_Count  : constant := 2;

   type Shelf_Object is limited interface;

   function Shelf_Cap
     (Item : in out Shelf_Object)
      return Rose.Capabilities.Capability is abstract;

   procedure Put
     (Item : in out Shelf_Object;
      Info : Rose.Interfaces.Shelf.File_Info) is abstract;

   function Get
     (Item  : in out Shelf_Object;
      Index : Natural)
      return Rose.Interfaces.Shelf.File_Info is abstract;

end Rose.Interfaces.Shelf;
