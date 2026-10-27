with Rose.Capabilities;
with Rose.Objects;

package Rose.Interfaces.Cap_Set is

   Cap_Set_Interface : constant Rose.Objects.Endpoint_Id :=
     16#720D_CF10_0839_5218#;

   Append_Endpoint   : constant Rose.Objects.Endpoint_Id :=
     16#86FD_BC71_1664_1081#;

   Get_Cap_Endpoint  : constant Rose.Objects.Endpoint_Id :=
     16#F010_4D9A_C273_39E9#;

   Length_Endpoint   : constant Rose.Objects.Endpoint_Id :=
     16#6F04_E1C2_AE1F_4170#;

   Append_Index      : constant := 0;

   Get_Cap_Index     : constant := 1;

   Length_Index      : constant := 2;

   Subprogram_Count  : constant := 3;

   type Cap_Set_Object is limited interface;

   procedure Append
     (Item : in out Cap_Set_Object;
      Caps : Rose.Capabilities.Capability_Array) is abstract;

   function Get_Cap
     (Item  : Cap_Set_Object;
      Index : Positive)
      return Rose.Capabilities.Capability is abstract;

   function Length (Item : Cap_Set_Object) return Natural is abstract;

end Rose.Interfaces.Cap_Set;
