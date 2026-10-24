with Rose.Objects;

package Rose.Interfaces.Process is

   Segment_Interface                  : constant Rose.Objects.Endpoint_Id :=
     16#E658_FB44_EA88_42D4#;

   Server_Interface                   : constant Rose.Objects.Endpoint_Id :=
     16#66F5_2E57_D81B_9C41#;

   Cap_Interface                      : constant Rose.Objects.Endpoint_Id :=
     16#9D5B_B72B_43AC_320F#;

   Process_Interface                  : constant Rose.Objects.Endpoint_Id :=
     16#F4F1_4934_3371_44AC#;

   Add_Segment_Endpoint               : constant Rose.Objects.Endpoint_Id :=
     16#1CB8_EAFA_1105_77AB#;

   Add_Nonpersistent_Segment_Endpoint : constant Rose.Objects.Endpoint_Id :=
     16#631A_4413_3C78_6014#;

   Published_Interface_Endpoint       : constant Rose.Objects.Endpoint_Id :=
     16#48B0_AA25_A13A_1536#;

   Destroy_Endpoint                   : constant Rose.Objects.Endpoint_Id :=
     16#8F59_25F5_180F_80DA#;

   Get_Object_Id_Endpoint             : constant Rose.Objects.Endpoint_Id :=
     16#E295_0B7C_E20F_9127#;

   Heap_Interface_Endpoint            : constant Rose.Objects.Endpoint_Id :=
     16#84E9_2BC1_73C0_9EF0#;

   Exit_Process_Endpoint              : constant Rose.Objects.Endpoint_Id :=
     16#AEEE_DB40_0E56_F441#;

   Publish_Interface_Endpoint         : constant Rose.Objects.Endpoint_Id :=
     16#E48D_1336_1015_9C78#;

   Add_Segment_Index                  : constant := 0;

   Add_Nonpersistent_Segment_Index    : constant := 1;

   Published_Interface_Index          : constant := 2;

   Destroy_Index                      : constant := 3;

   Get_Object_Id_Index                : constant := 4;

   Heap_Interface_Index               : constant := 5;

   Exit_Process_Index                 : constant := 6;

   Publish_Interface_Index            : constant := 7;

   Subprogram_Count                   : constant := 8;

end Rose.Interfaces.Process;
