with Rose.Capabilities;
with Rose.Objects;

package Rose.Interfaces.Toggle is

   Toggle_Interface : constant Rose.Objects.Endpoint_Id :=
     16#8E9A_F4E1_E79B_0F7B#;

   Is_On_Endpoint   : constant Rose.Objects.Endpoint_Id :=
     16#45F2_8D95_97DD_4854#;

   Switch_Endpoint  : constant Rose.Objects.Endpoint_Id :=
     16#95E_8FAF_1EAE_0B31#;

   Is_On_Index      : constant := 0;

   Switch_Index     : constant := 1;

   Subprogram_Count : constant := 2;

   type Toggle_Object is limited interface;

   function Toggle_Cap
     (Item : in out Toggle_Object)
      return Rose.Capabilities.Capability is abstract;

   function Is_On (Item : in out Toggle_Object) return Boolean is abstract;

   procedure Switch (Item : in out Toggle_Object; On : Boolean) is abstract;

end Rose.Interfaces.Toggle;
