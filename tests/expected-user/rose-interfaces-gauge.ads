with Rose.Interfaces.Counter;
with Rose.Interfaces.Labelled;
with Rose.Objects;

package Rose.Interfaces.Gauge is

   Named_Interface    : constant Rose.Objects.Endpoint_Id :=
     16#9CD5_1A6E_BB6A_A8CE#;

   Counter_Interface  : constant Rose.Objects.Endpoint_Id :=
     16#441F_05D0_E4EE_DB9E#;

   Labelled_Interface : constant Rose.Objects.Endpoint_Id :=
     16#11FE_D019_CE22_9B98#;

   Gauge_Interface    : constant Rose.Objects.Endpoint_Id :=
     16#5DC_4A72_DF8B_125B#;

   Badge_Endpoint     : constant Rose.Objects.Endpoint_Id :=
     16#BAD6_E000_0000_0001#;

   Increment_Endpoint : constant Rose.Objects.Endpoint_Id :=
     16#79BA_20DD_DB05_2CAB#;

   Value_Endpoint     : constant Rose.Objects.Endpoint_Id :=
     16#6741_CC61_B9B9_CBB7#;

   Set_Label_Endpoint : constant Rose.Objects.Endpoint_Id :=
     16#FE9E_9999_9FF9_2D7A#;

   Reset_Endpoint     : constant Rose.Objects.Endpoint_Id :=
     16#BD09_4A52_5DB9_650D#;

   Badge_Index        : constant := 0;

   Increment_Index    : constant := 1;

   Value_Index        : constant := 2;

   Set_Label_Index    : constant := 3;

   Reset_Index        : constant := 4;

   Subprogram_Count   : constant := 5;

   type Gauge_Object is limited interface
     and Rose.Interfaces.Counter.Counter_Object
     and Rose.Interfaces.Labelled.Labelled_Object;

   procedure Reset (Item : in out Gauge_Object) is abstract;

end Rose.Interfaces.Gauge;
