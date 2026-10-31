with Rose.Capabilities;
with Rose.Objects;

package Rose.Interfaces.Boolean_Out is

   Boolean_Out_Interface : constant Rose.Objects.Endpoint_Id :=
     16#A7C9_D101_A222_7948#;

   Get_Endpoint          : constant Rose.Objects.Endpoint_Id :=
     16#2C63_96E7_8E8C_237E#;

   Get_Index             : constant := 0;

   Subprogram_Count      : constant := 1;

   type Boolean_Out_Object is limited interface;

   function Boolean_Out_Cap
     (Item : in out Boolean_Out_Object)
      return Rose.Capabilities.Capability is abstract;

   procedure Get
     (Item : in out Boolean_Out_Object;
      On   : out Boolean) is abstract;

end Rose.Interfaces.Boolean_Out;
