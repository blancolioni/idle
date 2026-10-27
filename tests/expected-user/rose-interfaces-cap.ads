with Rose.Capabilities;
with Rose.Objects;

package Rose.Interfaces.Cap is

   Cap_Interface          : constant Rose.Objects.Endpoint_Id :=
     16#9D5B_B72B_43AC_320F#;

   Destroy_Endpoint       : constant Rose.Objects.Endpoint_Id :=
     16#8F59_25F5_180F_80DA#;

   Get_Object_Id_Endpoint : constant Rose.Objects.Endpoint_Id :=
     16#E295_0B7C_E20F_9127#;

   Destroy_Index          : constant := 0;

   Get_Object_Id_Index    : constant := 1;

   Subprogram_Count       : constant := 2;

   type Cap_Object is limited interface;

   function Cap_Cap
     (Item : in out Cap_Object)
      return Rose.Capabilities.Capability is abstract;

   procedure Destroy (Item : in out Cap_Object) is abstract;

   function Get_Object_Id
     (Item : in out Cap_Object)
      return Rose.Objects.Object_Id is abstract;

end Rose.Interfaces.Cap;
