with Rose.Objects;

package Rose.Interfaces.Meter is

   Named_Interface    : constant Rose.Objects.Endpoint_Id :=
     16#1111_0000_0001#;

   Counter_Interface  : constant Rose.Objects.Endpoint_Id :=
     16#1111_0000_0002#;

   Meter_Interface    : constant Rose.Objects.Endpoint_Id :=
     16#1111_0000_0003#;

   Badge_Endpoint     : constant Rose.Objects.Endpoint_Id :=
     16#2222_0000_0001#;

   Increment_Endpoint : constant Rose.Objects.Endpoint_Id :=
     16#2222_0000_0002#;

   Value_Endpoint     : constant Rose.Objects.Endpoint_Id :=
     16#2222_0000_0003#;

   Reset_Endpoint     : constant Rose.Objects.Endpoint_Id :=
     16#2222_0000_0004#;

   Badge_Index        : constant := 0;

   Increment_Index    : constant := 1;

   Value_Index        : constant := 2;

   Reset_Index        : constant := 3;

   Subprogram_Count   : constant := 4;

end Rose.Interfaces.Meter;
