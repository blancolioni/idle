with Rose.Objects;

package Rose.Interfaces.Items is

   Items_Interface  : constant Rose.Objects.Endpoint_Id :=
     16#AB81_444D_7CB2_F569#;

   Pair_Endpoint    : constant Rose.Objects.Endpoint_Id :=
     16#9EF4_CA15_6DC2_770E#;

   Store_Endpoint   : constant Rose.Objects.Endpoint_Id :=
     16#A192_4F73_53F4_11F5#;

   Single_Endpoint  : constant Rose.Objects.Endpoint_Id :=
     16#FC53_F4B0_6A40_06D6#;

   Pair_Index       : constant := 0;

   Store_Index      : constant := 1;

   Single_Index     : constant := 2;

   Subprogram_Count : constant := 3;

end Rose.Interfaces.Items;
