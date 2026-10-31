with Rose.Capabilities;
with Rose.Objects;

package Rose.Interfaces.Boolean_Result is

   Boolean_Result_Interface : constant Rose.Objects.Endpoint_Id :=
     16#BE2E_7A5E_835A_26BA#;

   Is_Ready_Endpoint        : constant Rose.Objects.Endpoint_Id :=
     16#950B_4CF4_255F_AE93#;

   Is_Ready_Index           : constant := 0;

   Subprogram_Count         : constant := 1;

   type Boolean_Result_Object is limited interface;

   function Boolean_Result_Cap
     (Item : in out Boolean_Result_Object)
      return Rose.Capabilities.Capability is abstract;

   function Is_Ready
     (Item : in out Boolean_Result_Object)
      return Boolean is abstract;

end Rose.Interfaces.Boolean_Result;
