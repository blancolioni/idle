with Rose.Objects;

package Rose.Interfaces.Meter is

   Named_Interface    : constant Rose.Objects.Endpoint_Id :=
     16#9CD5_1A6E_BB6A_A8CE#;

   Counter_Interface  : constant Rose.Objects.Endpoint_Id :=
     16#441F_05D0_E4EE_DB9E#;

   Meter_Interface    : constant Rose.Objects.Endpoint_Id :=
     16#23C6_FBC1_1D6A_1A2A#;

   Badge_Endpoint     : constant Rose.Objects.Endpoint_Id :=
     16#BAD6_E000_0000_0001#;

   Increment_Endpoint : constant Rose.Objects.Endpoint_Id :=
     16#79BA_20DD_DB05_2CAB#;

   Value_Endpoint     : constant Rose.Objects.Endpoint_Id :=
     16#6741_CC61_B9B9_CBB7#;

   Reset_Endpoint     : constant Rose.Objects.Endpoint_Id :=
     16#1303_0A7B_9549_6127#;

   Badge_Index        : constant := 0;

   Increment_Index    : constant := 1;

   Value_Index        : constant := 2;

   Reset_Index        : constant := 3;

   Subprogram_Count   : constant := 4;

end Rose.Interfaces.Meter;
