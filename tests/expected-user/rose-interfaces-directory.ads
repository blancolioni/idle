with Rose.Capabilities;
with Rose.Objects;
with System.Storage_Elements;
limited with Rose.Interfaces.File;
limited with Rose.Interfaces.Stream_Reader;

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

   Read_File_Endpoint             : constant Rose.Objects.Endpoint_Id :=
     16#EB8A_CB9A_A7B9_FD83#;

   Create_Directory_Endpoint      : constant Rose.Objects.Endpoint_Id :=
     16#A869_05E0_FF03_B268#;

   Create_File_Endpoint           : constant Rose.Objects.Endpoint_Id :=
     16#3451_684E_97FB_9A2A#;

   Directory_Entry_Count_Index    : constant := 0;

   Directory_Entry_Name_Index     : constant := 1;

   Directory_Entry_Kind_Index     : constant := 2;

   Directory_Entry_Size_Index     : constant := 3;

   Find_Entry_Index               : constant := 4;

   Get_Ordinary_File_Index        : constant := 5;

   Get_Directory_Index            : constant := 6;

   Read_File_Index                : constant := 7;

   Create_Directory_Index         : constant := 8;

   Create_File_Index              : constant := 9;

   Subprogram_Count               : constant := 10;

   type Directory_Object is limited interface;

   function Directory_Cap
     (Item : in out Directory_Object)
      return Rose.Capabilities.Capability is abstract;

   function Directory_Entry_Count
     (Item : in out Directory_Object)
      return Natural is abstract;

   function Directory_Entry_Name
     (Item  : in out Directory_Object;
      Index : Positive)
      return String is abstract;

   function Directory_Entry_Kind
     (Item  : in out Directory_Object;
      Index : Positive)
      return Rose.Interfaces.Directory.File_Kind is abstract;

   function Directory_Entry_Size
     (Item  : in out Directory_Object;
      Index : Positive)
      return System.Storage_Elements.Storage_Count is abstract;

   function Find_Entry
     (Item : in out Directory_Object;
      Name : String)
      return Natural is abstract;

   function Get_Ordinary_File
     (Item  : in out Directory_Object;
      Index : Positive)
      return Rose.Interfaces.File.File_Object'Class is abstract;

   function Get_Directory
     (Item  : in out Directory_Object;
      Index : Positive)
      return Rose.Interfaces.Directory.Directory_Object'Class is abstract;

   function Read_File
     (Item  : in out Directory_Object;
      Index : Positive)
      return Rose.Interfaces.Stream_Reader.Stream_Reader_Object'Class
   is abstract;

   function Create_Directory
     (Item : in out Directory_Object;
      Name : String)
      return Rose.Interfaces.Directory.Directory_Object'Class is abstract;

   function Create_File
     (Item : in out Directory_Object;
      Name : String)
      return Rose.Interfaces.File.File_Object'Class is abstract;

end Rose.Interfaces.Directory;
