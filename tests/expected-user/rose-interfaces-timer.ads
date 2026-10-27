with Rose.Capabilities;
with Rose.Objects;
with Rose.Words;
limited with Rose.Interfaces.Cap;

package Rose.Interfaces.Timer is

   Timer_Interface    : constant Rose.Objects.Endpoint_Id :=
     16#BCD2_3205_BCCE_A351#;

   Set_Timer_Endpoint : constant Rose.Objects.Endpoint_Id :=
     16#3493_02F3_85B8_1097#;

   Set_Timer_Index    : constant := 0;

   Subprogram_Count   : constant := 1;

   type Timer_Object is limited interface;

   function Timer_Cap
     (Item : in out Timer_Object)
      return Rose.Capabilities.Capability is abstract;

   function Set_Timer
     (Item         : in out Timer_Object;
      Milliseconds : Rose.Words.Word;
      Cap          : Rose.Capabilities.Capability)
      return Rose.Interfaces.Cap.Cap_Object'Class is abstract;

end Rose.Interfaces.Timer;
