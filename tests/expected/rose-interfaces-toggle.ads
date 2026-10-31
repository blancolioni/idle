with Rose.Objects;

package Rose.Interfaces.Toggle is

   Toggle_Interface : constant Rose.Objects.Endpoint_Id :=
     16#8E9A_F4E1_E79B_0F7B#;

   Is_On_Endpoint   : constant Rose.Objects.Endpoint_Id :=
     16#45F2_8D95_97DD_4854#;

   Switch_Endpoint  : constant Rose.Objects.Endpoint_Id :=
     16#95E_8FAF_1EAE_0B31#;

   Is_On_Index      : constant := 0;

   Switch_Index     : constant := 1;

   Subprogram_Count : constant := 2;

end Rose.Interfaces.Toggle;
