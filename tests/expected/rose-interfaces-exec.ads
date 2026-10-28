with Rose.Objects;

package Rose.Interfaces.Exec is

   Launch_Interface             : constant Rose.Objects.Endpoint_Id :=
     16#8B8B_A324_FA51_3FD2#;

   Exec_Interface               : constant Rose.Objects.Endpoint_Id :=
     16#4279_2F9D_69F2_5EA9#;

   Launch_Endpoint              : constant Rose.Objects.Endpoint_Id :=
     16#FC1_B77F_4AA3_E406#;

   Launch_Command_Endpoint      : constant Rose.Objects.Endpoint_Id :=
     16#D74B_62A6_3FD9_8B4F#;

   Metadata_Endpoint            : constant Rose.Objects.Endpoint_Id :=
     16#2B7A_157F_3FEB_540B#;

   Install_Endpoint             : constant Rose.Objects.Endpoint_Id :=
     16#9B08_144B_8994_B97B#;

   Set_Standard_Output_Endpoint : constant Rose.Objects.Endpoint_Id :=
     16#FDE0_0BDD_7A19_06B9#;

   Launch_Index                 : constant := 0;

   Launch_Command_Index         : constant := 1;

   Metadata_Index               : constant := 2;

   Install_Index                : constant := 3;

   Set_Standard_Output_Index    : constant := 4;

   Subprogram_Count             : constant := 5;

end Rose.Interfaces.Exec;
