with Rose.Capabilities;
with Rose.Interfaces.Counter;
with Rose.Interfaces.Resource;
with Rose.Objects;
with Rose.Words;

package Rose.Interfaces.Lease is

   Named_Interface    : constant Rose.Objects.Endpoint_Id :=
     16#9CD5_1A6E_BB6A_A8CE#;

   Counter_Interface  : constant Rose.Objects.Endpoint_Id :=
     16#441F_05D0_E4EE_DB9E#;

   Resource_Interface : constant Rose.Objects.Endpoint_Id :=
     16#F49B_1FE7_07D3_B4B5#;

   Lease_Interface    : constant Rose.Objects.Endpoint_Id :=
     16#4570_BAF4_B5E9_06CA#;

   Badge_Endpoint     : constant Rose.Objects.Endpoint_Id :=
     16#BAD6_E000_0000_0001#;

   Increment_Endpoint : constant Rose.Objects.Endpoint_Id :=
     16#79BA_20DD_DB05_2CAB#;

   Value_Endpoint     : constant Rose.Objects.Endpoint_Id :=
     16#6741_CC61_B9B9_CBB7#;

   Release_Endpoint   : constant Rose.Objects.Endpoint_Id :=
     16#7F24_9764_E75A_970F#;

   Remaining_Endpoint : constant Rose.Objects.Endpoint_Id :=
     16#311A_C15A_93ED_806A#;

   Badge_Index        : constant := 0;

   Increment_Index    : constant := 1;

   Value_Index        : constant := 2;

   Release_Index      : constant := 3;

   Remaining_Index    : constant := 4;

   Subprogram_Count   : constant := 5;

   type Lease_Object is limited interface
     and Rose.Interfaces.Counter.Counter_Object
     and Rose.Interfaces.Resource.Resource_Object;

   function Lease_Cap
     (Item : in out Lease_Object)
      return Rose.Capabilities.Capability is abstract;

   function Remaining
     (Item : in out Lease_Object)
      return Rose.Words.Word is abstract;

end Rose.Interfaces.Lease;
