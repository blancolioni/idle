with Rose.Objects;

package Rose.Interfaces.Exec is

   Launch_Interface : constant Rose.Objects.Endpoint_Id :=
     16#8B8B_A324_FA51_3FD2#;

   Exec_Interface   : constant Rose.Objects.Endpoint_Id :=
     16#4279_2F9D_69F2_5EA9#;

   Launch_Endpoint  : constant Rose.Objects.Endpoint_Id :=
     16#FC1_B77F_4AA3_E406#;

   Install_Endpoint : constant Rose.Objects.Endpoint_Id :=
     16#9B08_144B_8994_B97B#;

   Launch_Index     : constant := 0;

   Install_Index    : constant := 1;

   Subprogram_Count : constant := 2;

end Rose.Interfaces.Exec;
