with Rose.Objects;
with Rose.Words;

package Rose.Interfaces.Block_Device is

   Max_Block_Size          : constant := 4096;

   type Block_Size_Type is range 0 .. Max_Block_Size;

   type Block_Address_Type is new Rose.Words.Word_64;

   type Device_Size_Type is new Rose.Words.Word_64;

   Block_Device_Interface  : constant Rose.Objects.Endpoint_Id :=
     16#BF4_E8D8_2E3F_6917#;

   Get_Parameters_Endpoint : constant Rose.Objects.Endpoint_Id :=
     16#4431_2F67_3CD7_F8A0#;

   Read_Blocks_Endpoint    : constant Rose.Objects.Endpoint_Id :=
     16#9B9A_57E4_0082_DE86#;

   Write_Blocks_Endpoint   : constant Rose.Objects.Endpoint_Id :=
     16#3918_D336_1295_3AA5#;

   Get_Parameters_Index    : constant := 0;

   Read_Blocks_Index       : constant := 1;

   Write_Blocks_Index      : constant := 2;

   Subprogram_Count        : constant := 3;

end Rose.Interfaces.Block_Device;
