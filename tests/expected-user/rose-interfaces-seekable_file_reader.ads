with Rose.Capabilities;
with Rose.Interfaces.File_Reader;
with Rose.Interfaces.Seekable;
with Rose.Objects;

package Rose.Interfaces.Seekable_File_Reader is

   Stream_Reader_Interface        : constant Rose.Objects.Endpoint_Id :=
     16#51A3_D80D_A576_BBEA#;

   Resource_Interface             : constant Rose.Objects.Endpoint_Id :=
     16#F49B_1FE7_07D3_B4B5#;

   File_Reader_Interface          : constant Rose.Objects.Endpoint_Id :=
     16#B2E9_4013_771C_C77A#;

   Seekable_Interface             : constant Rose.Objects.Endpoint_Id :=
     16#6496_B9FE_93A9_D452#;

   Seekable_File_Reader_Interface : constant Rose.Objects.Endpoint_Id :=
     16#43CA_2B7A_E0AE_0188#;

   Read_Endpoint                  : constant Rose.Objects.Endpoint_Id :=
     16#9175_845E_31B1_857C#;

   Release_Endpoint               : constant Rose.Objects.Endpoint_Id :=
     16#7F24_9764_E75A_970F#;

   Seek_Endpoint                  : constant Rose.Objects.Endpoint_Id :=
     16#61A2_A8A5_DB58_B9E9#;

   Read_Index                     : constant := 0;

   Release_Index                  : constant := 1;

   Seek_Index                     : constant := 2;

   Subprogram_Count               : constant := 3;

   type Seekable_File_Reader_Object is limited interface
     and Rose.Interfaces.File_Reader.File_Reader_Object
     and Rose.Interfaces.Seekable.Seekable_Object;

   function Seekable_File_Reader_Cap
     (Item : in out Seekable_File_Reader_Object)
      return Rose.Capabilities.Capability is abstract;

end Rose.Interfaces.Seekable_File_Reader;
