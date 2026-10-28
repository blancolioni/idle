with Rose.Objects;

package Rose.Interfaces.Directory is

   type File_Kind is (Directory, Ordinary_File, Special_File);

   Directory_Interface            : constant Rose.Objects.Endpoint_Id :=
     16#1C5_FBB7_19DE_112A#;

   Directory_Entry_Count_Endpoint : constant Rose.Objects.Endpoint_Id :=
     16#ADDF_FA0F_D647_4D75#;

   Directory_Entry_Name_Endpoint  : constant Rose.Objects.Endpoint_Id :=
     16#DB37_1B14_7C74_740F#;

   Directory_Entry_Kind_Endpoint  : constant Rose.Objects.Endpoint_Id :=
     16#DE96_8891_CE34_5B4F#;

   Directory_Entry_Size_Endpoint  : constant Rose.Objects.Endpoint_Id :=
     16#5FA_DAEB_F56E_5038#;

   Find_Entry_Endpoint            : constant Rose.Objects.Endpoint_Id :=
     16#ECDE_34C4_3D46_477B#;

   Get_Ordinary_File_Endpoint     : constant Rose.Objects.Endpoint_Id :=
     16#20D5_30E6_B1E4_F50A#;

   Get_Directory_Endpoint         : constant Rose.Objects.Endpoint_Id :=
     16#1A5A_45A6_6CB5_6E1D#;

   Directory_Entry_Count_Index    : constant := 0;

   Directory_Entry_Name_Index     : constant := 1;

   Directory_Entry_Kind_Index     : constant := 2;

   Directory_Entry_Size_Index     : constant := 3;

   Find_Entry_Index               : constant := 4;

   Get_Ordinary_File_Index        : constant := 5;

   Get_Directory_Index            : constant := 6;

   Subprogram_Count               : constant := 7;

end Rose.Interfaces.Directory;
