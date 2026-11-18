with Rose.Objects;

package Rose.Interfaces.Exec is

   Launch_Interface             : constant Rose.Objects.Endpoint_Id :=
     16#8B8B_A324_FA51_3FD2#;

   Exec_Interface               : constant Rose.Objects.Endpoint_Id :=
     16#4279_2F9D_69F2_5EA9#;

   Launch_Endpoint              : constant Rose.Objects.Endpoint_Id :=
     16#1E89_E16B_EF48_3A33#;

   Launch_Command_Endpoint      : constant Rose.Objects.Endpoint_Id :=
     16#8329_BE24_AEF6_AF8F#;

   Metadata_Endpoint            : constant Rose.Objects.Endpoint_Id :=
     16#2B7A_157F_3FEB_540B#;

   Install_Endpoint             : constant Rose.Objects.Endpoint_Id :=
     16#8A1C_7544_62D5_0C26#;

   Set_Standard_Output_Endpoint : constant Rose.Objects.Endpoint_Id :=
     16#FDE0_0BDD_7A19_06B9#;

   Launch_Index                 : constant := 0;

   Launch_Command_Index         : constant := 1;

   Metadata_Index               : constant := 2;

   Install_Index                : constant := 3;

   Set_Standard_Output_Index    : constant := 4;

   Subprogram_Count             : constant := 5;

end Rose.Interfaces.Exec;
