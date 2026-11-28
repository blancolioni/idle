with Rose.Objects;

package Rose.Interfaces.Meter is

   Meter_Interface  : constant Rose.Objects.Endpoint_Id :=
     16#23C6_FBC1_1D6A_1A2A#;

   Sample_Endpoint  : constant Rose.Objects.Endpoint_Id :=
     16#4E60_B8F2_1C12_C056#;

   Kind_Endpoint    : constant Rose.Objects.Endpoint_Id :=
     16#BDC8_E54A_BD42_106A#;

   Sample_Index     : constant := 0;

   Kind_Index       : constant := 1;

   Subprogram_Count : constant := 2;

end Rose.Interfaces.Meter;
