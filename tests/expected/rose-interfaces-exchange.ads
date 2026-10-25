with Rose.Objects;

package Rose.Interfaces.Exchange is

   Exchange_Interface       : constant Rose.Objects.Endpoint_Id :=
     16#930B_6D6B_463C_5A3D#;

   Create_Endpoint_Endpoint : constant Rose.Objects.Endpoint_Id :=
     16#7434_0B0E_7CAF_645A#;

   Split_Endpoint           : constant Rose.Objects.Endpoint_Id :=
     16#92A_77B5_5699_F1C6#;

   Rename_Endpoint          : constant Rose.Objects.Endpoint_Id :=
     16#D3BB_D15A_CEF9_E102#;

   Partner_Endpoint         : constant Rose.Objects.Endpoint_Id :=
     16#7C39_929A_8C5D_E6CF#;

   Gather_Endpoint          : constant Rose.Objects.Endpoint_Id :=
     16#8A1A_E55F_4C75_9986#;

   Create_Endpoint_Index    : constant := 0;

   Split_Index              : constant := 1;

   Rename_Index             : constant := 2;

   Partner_Index            : constant := 3;

   Gather_Index             : constant := 4;

   Subprogram_Count         : constant := 5;

end Rose.Interfaces.Exchange;
