with Rose.Objects;

package Rose.Interfaces.Measures.Counter is

   Named_Interface    : constant Rose.Objects.Endpoint_Id :=
     16#9208_2F83_E925_52F0#;

   Counter_Interface  : constant Rose.Objects.Endpoint_Id :=
     16#2179_AD35_6D1A_C026#;

   Badge_Endpoint     : constant Rose.Objects.Endpoint_Id :=
     16#C9B6_319C_F3D5_7B5C#;

   Increment_Endpoint : constant Rose.Objects.Endpoint_Id :=
     16#D5C3_E5A8_9102_3957#;

   Value_Endpoint     : constant Rose.Objects.Endpoint_Id :=
     16#ADFD_7087_FD78_E21D#;

   Label_Endpoint     : constant Rose.Objects.Endpoint_Id :=
     16#3294_FB8D_8CB1_211D#;

   Twin_Endpoint      : constant Rose.Objects.Endpoint_Id :=
     16#B4D9_EB4C_A436_16C6#;

   Badge_Index        : constant := 0;

   Increment_Index    : constant := 1;

   Value_Index        : constant := 2;

   Label_Index        : constant := 3;

   Twin_Index         : constant := 4;

   Subprogram_Count   : constant := 5;

end Rose.Interfaces.Measures.Counter;
