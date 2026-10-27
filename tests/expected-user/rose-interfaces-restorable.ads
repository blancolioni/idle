with Rose.Capabilities;
with Rose.Objects;

package Rose.Interfaces.Restorable is

   Restorable_Interface : constant Rose.Objects.Endpoint_Id :=
     16#28F5_3FA7_7891_7414#;

   Restored_Endpoint    : constant Rose.Objects.Endpoint_Id :=
     16#B2B_9978_619A_E499#;

   Restored_Index       : constant := 0;

   Subprogram_Count     : constant := 1;

   type Restorable_Object is limited interface;

   function Restorable_Cap
     (Item : in out Restorable_Object)
      return Rose.Capabilities.Capability is abstract;

   procedure Restored (Item : in out Restorable_Object) is abstract;

end Rose.Interfaces.Restorable;
