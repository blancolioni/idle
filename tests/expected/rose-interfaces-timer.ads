with Rose.Objects;

package Rose.Interfaces.Timer is

   Timer_Interface    : constant Rose.Objects.Endpoint_Id :=
     16#BCD2_3205_BCCE_A351#;

   Set_Timer_Endpoint : constant Rose.Objects.Endpoint_Id :=
     16#3493_02F3_85B8_1097#;

   Set_Timer_Index    : constant := 0;

   Subprogram_Count   : constant := 1;

end Rose.Interfaces.Timer;
