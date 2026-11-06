with Rose.Capabilities;
with Rose.Interfaces.Resource;
with Rose.Interfaces.Transactional;
with Rose.Interfaces.Writable_File;
with Rose.Objects;

package Rose.Interfaces.Transactional_Writable_File is

   File_Interface                        : constant Rose.Objects.Endpoint_Id :=
     16#7D9D_DE97_9C08_C7C9#;

   Stream_Writer_Interface               : constant Rose.Objects.Endpoint_Id :=
     16#346F_D760_8A40_95B7#;

   Writable_File_Interface               : constant Rose.Objects.Endpoint_Id :=
     16#2C97_F990_37FB_6AB9#;

   Transactional_Interface               : constant Rose.Objects.Endpoint_Id :=
     16#FC69_1234_89B4_BA88#;

   Resource_Interface                    : constant Rose.Objects.Endpoint_Id :=
     16#F49B_1FE7_07D3_B4B5#;

   Transactional_Writable_File_Interface : constant Rose.Objects.Endpoint_Id :=
     16#9003_751E_D4E8_2BCB#;

   Size_Endpoint                         : constant Rose.Objects.Endpoint_Id :=
     16#F6D0_973E_DEDA_8E48#;

   Open_Reader_Endpoint                  : constant Rose.Objects.Endpoint_Id :=
     16#CDF7_65AA_4E7F_CF7F#;

   Open_Seekable_Reader_Endpoint         : constant Rose.Objects.Endpoint_Id :=
     16#E29C_C755_27E1_0E80#;

   Write_Endpoint                        : constant Rose.Objects.Endpoint_Id :=
     16#C5CD_0953_4A8B_BC37#;

   Truncate_Endpoint                     : constant Rose.Objects.Endpoint_Id :=
     16#87FC_81AD_DC91_1DB9#;

   New_Version_Endpoint                  : constant Rose.Objects.Endpoint_Id :=
     16#9485_9E3C_A2FA_C7E8#;

   Commit_Endpoint                       : constant Rose.Objects.Endpoint_Id :=
     16#893C_52C0_D783_084D#;

   Rollback_Endpoint                     : constant Rose.Objects.Endpoint_Id :=
     16#3230_D0E4_CB12_34B4#;

   Release_Endpoint                      : constant Rose.Objects.Endpoint_Id :=
     16#7F24_9764_E75A_970F#;

   Size_Index                            : constant := 0;

   Open_Reader_Index                     : constant := 1;

   Open_Seekable_Reader_Index            : constant := 2;

   Write_Index                           : constant := 3;

   Truncate_Index                        : constant := 4;

   New_Version_Index                     : constant := 5;

   Commit_Index                          : constant := 6;

   Rollback_Index                        : constant := 7;

   Release_Index                         : constant := 8;

   Subprogram_Count                      : constant := 9;

   type Transactional_Writable_File_Object is limited interface
     and Rose.Interfaces.Writable_File.Writable_File_Object
     and Rose.Interfaces.Transactional.Transactional_Object
     and Rose.Interfaces.Resource.Resource_Object;

   function Transactional_Writable_File_Cap
     (Item : in out Transactional_Writable_File_Object)
      return Rose.Capabilities.Capability is abstract;

end Rose.Interfaces.Transactional_Writable_File;
