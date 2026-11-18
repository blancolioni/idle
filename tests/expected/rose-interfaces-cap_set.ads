with Rose.Objects;

package Rose.Interfaces.Cap_Set is

   Cap_Set_Interface : constant Rose.Objects.Endpoint_Id :=
     16#720D_CF10_0839_5218#;

   Append_Endpoint   : constant Rose.Objects.Endpoint_Id :=
     16#5DC3_6B4F_732B_EB8F#;

   Get_Cap_Endpoint  : constant Rose.Objects.Endpoint_Id :=
     16#F010_4D9A_C273_39E9#;

   Length_Endpoint   : constant Rose.Objects.Endpoint_Id :=
     16#6F04_E1C2_AE1F_4170#;

   Append_Index      : constant := 0;

   Get_Cap_Index     : constant := 1;

   Length_Index      : constant := 2;

   Subprogram_Count  : constant := 3;

end Rose.Interfaces.Cap_Set;
