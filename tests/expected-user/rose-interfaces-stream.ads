with Rose.Interfaces.Stream_Reader;
with Rose.Interfaces.Stream_Writer;
with Rose.Objects;

package Rose.Interfaces.Stream is

   Stream_Reader_Interface : constant Rose.Objects.Endpoint_Id :=
     16#51A3_D80D_A576_BBEA#;

   Stream_Writer_Interface : constant Rose.Objects.Endpoint_Id :=
     16#346F_D760_8A40_95B7#;

   Stream_Interface        : constant Rose.Objects.Endpoint_Id :=
     16#262_BF61_DEA8_A9FC#;

   Read_Endpoint           : constant Rose.Objects.Endpoint_Id :=
     16#9175_845E_31B1_857C#;

   Write_Endpoint          : constant Rose.Objects.Endpoint_Id :=
     16#C5CD_0953_4A8B_BC37#;

   Read_Index              : constant := 0;

   Write_Index             : constant := 1;

   Subprogram_Count        : constant := 2;

   type Stream_Object is limited interface
     and Rose.Interfaces.Stream_Reader.Stream_Reader_Object
     and Rose.Interfaces.Stream_Writer.Stream_Writer_Object;

end Rose.Interfaces.Stream;
