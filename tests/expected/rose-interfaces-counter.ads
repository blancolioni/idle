with Rose.Objects;

package Rose.Interfaces.Counter is

   Named_Interface    : constant Rose.Objects.Endpoint_Id :=
     16#1111_0000_0001#;

   Counter_Interface  : constant Rose.Objects.Endpoint_Id :=
     16#1111_0000_0002#;

   Badge_Endpoint     : constant Rose.Objects.Endpoint_Id :=
     16#2222_0000_0001#;

   Increment_Endpoint : constant Rose.Objects.Endpoint_Id :=
     16#2222_0000_0002#;

   Value_Endpoint     : constant Rose.Objects.Endpoint_Id :=
     16#2222_0000_0003#;

   Badge_Index        : constant := 0;

   Increment_Index    : constant := 1;

   Value_Index        : constant := 2;

   Subprogram_Count   : constant := 3;

end Rose.Interfaces.Counter;
