with Rose.Capabilities;
with Rose.Interfaces.Seekable;
with Rose.Interfaces.Stream;
with Rose.Objects;

package Rose.Interfaces.File is

   Stream_Reader_Interface : constant Rose.Objects.Endpoint_Id :=
     16#51A3_D80D_A576_BBEA#;

   Stream_Writer_Interface : constant Rose.Objects.Endpoint_Id :=
     16#346F_D760_8A40_95B7#;

   Stream_Interface        : constant Rose.Objects.Endpoint_Id :=
     16#262_BF61_DEA8_A9FC#;

   Seekable_Interface      : constant Rose.Objects.Endpoint_Id :=
     16#6496_B9FE_93A9_D452#;

   File_Interface          : constant Rose.Objects.Endpoint_Id :=
     16#7D9D_DE97_9C08_C7C9#;

   Read_Endpoint           : constant Rose.Objects.Endpoint_Id :=
     16#9175_845E_31B1_857C#;

   Write_Endpoint          : constant Rose.Objects.Endpoint_Id :=
     16#C5CD_0953_4A8B_BC37#;

   Seek_Endpoint           : constant Rose.Objects.Endpoint_Id :=
     16#61A2_A8A5_DB58_B9E9#;

   Read_Index              : constant := 0;

   Write_Index             : constant := 1;

   Seek_Index              : constant := 2;

   Subprogram_Count        : constant := 3;

   type File_Object is limited interface
     and Rose.Interfaces.Stream.Stream_Object
     and Rose.Interfaces.Seekable.Seekable_Object;

   function File_Cap
     (Item : in out File_Object)
      return Rose.Capabilities.Capability is abstract;

end Rose.Interfaces.File;
