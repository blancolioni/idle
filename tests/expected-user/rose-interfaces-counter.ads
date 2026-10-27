with Rose.Capabilities;
with Rose.Interfaces.Named;
with Rose.Objects;
with Rose.Words;

package Rose.Interfaces.Counter is

   type Badge_Number is range 1 .. Rose.Interfaces.Named.Max_Badges;

   Named_Interface    : constant Rose.Objects.Endpoint_Id :=
     16#9CD5_1A6E_BB6A_A8CE#;

   Counter_Interface  : constant Rose.Objects.Endpoint_Id :=
     16#441F_05D0_E4EE_DB9E#;

   Badge_Endpoint     : constant Rose.Objects.Endpoint_Id :=
     16#BAD6_E000_0000_0001#;

   Increment_Endpoint : constant Rose.Objects.Endpoint_Id :=
     16#79BA_20DD_DB05_2CAB#;

   Value_Endpoint     : constant Rose.Objects.Endpoint_Id :=
     16#6741_CC61_B9B9_CBB7#;

   Badge_Index        : constant := 0;

   Increment_Index    : constant := 1;

   Value_Index        : constant := 2;

   Subprogram_Count   : constant := 3;

   type Counter_Object is limited interface
     and Rose.Interfaces.Named.Named_Object;

   function Counter_Cap
     (Item : in out Counter_Object)
      return Rose.Capabilities.Capability is abstract;

   procedure Increment
     (Item : in out Counter_Object;
      By   : Rose.Words.Word) is abstract;

   function Value
     (Item : in out Counter_Object)
      return Rose.Words.Word is abstract;

end Rose.Interfaces.Counter;
