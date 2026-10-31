with Rose.Capabilities;
with Rose.Objects;

package Rose.Interfaces.Boolean_In is

   Boolean_In_Interface : constant Rose.Objects.Endpoint_Id :=
     16#3BEB_89BB_2EED_4FDB#;

   Set_Endpoint         : constant Rose.Objects.Endpoint_Id :=
     16#E007_2F4E_FF8A_76DE#;

   Set_Index            : constant := 0;

   Subprogram_Count     : constant := 1;

   type Boolean_In_Object is limited interface;

   function Boolean_In_Cap
     (Item : in out Boolean_In_Object)
      return Rose.Capabilities.Capability is abstract;

   procedure Set (Item : in out Boolean_In_Object; On : Boolean) is abstract;

end Rose.Interfaces.Boolean_In;
