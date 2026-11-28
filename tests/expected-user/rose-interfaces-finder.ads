with Ada.Strings.Unbounded;
with Interfaces;
with Rose.Capabilities;
with Rose.Objects;
with System.Storage_Elements;

package Rose.Interfaces.Finder is

   type File_Info is record
      Name     : Ada.Strings.Unbounded.Unbounded_String;
      Size     : Natural;
      Created  : Standard.Interfaces.Integer_64;
      Modified : Standard.Interfaces.Integer_64;
   end record;

   File_Info_Type_Id : constant Rose.Objects.Endpoint_Id :=
     16#2FCD_0DB2_952B_D641#;

   function File_Info_Fields return System.Storage_Elements.Storage_Array;

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

   Finder_Interface  : constant Rose.Objects.Endpoint_Id :=
     16#AE30_4A44_1E9C_3CC1#;

   Get_Endpoint      : constant Rose.Objects.Endpoint_Id :=
     16#6271_ADE3_63EE_F24C#;

   Get_Index         : constant := 0;

   Subprogram_Count  : constant := 1;

   type Finder_Object is limited interface;

   function Finder_Cap
     (Item : in out Finder_Object)
      return Rose.Capabilities.Capability is abstract;

   function Get
     (Item  : in out Finder_Object;
      Index : Natural)
      return Rose.Interfaces.Finder.File_Info is abstract;

end Rose.Interfaces.Finder;
