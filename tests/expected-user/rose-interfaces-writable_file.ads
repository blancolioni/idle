with Rose.Capabilities;
with Rose.Interfaces.File;
with Rose.Interfaces.Stream_Writer;
with Rose.Objects;
with System.Storage_Elements;
limited with Rose.Interfaces.Transactional_Writable_File;

package Rose.Interfaces.Writable_File is

   File_Interface                : constant Rose.Objects.Endpoint_Id :=
     16#7D9D_DE97_9C08_C7C9#;

   Stream_Writer_Interface       : constant Rose.Objects.Endpoint_Id :=
     16#346F_D760_8A40_95B7#;

   Writable_File_Interface       : constant Rose.Objects.Endpoint_Id :=
     16#2C97_F990_37FB_6AB9#;

   Size_Endpoint                 : constant Rose.Objects.Endpoint_Id :=
     16#F6D0_973E_DEDA_8E48#;

   Open_Reader_Endpoint          : constant Rose.Objects.Endpoint_Id :=
     16#CDF7_65AA_4E7F_CF7F#;

   Open_Seekable_Reader_Endpoint : constant Rose.Objects.Endpoint_Id :=
     16#E29C_C755_27E1_0E80#;

   Write_Endpoint                : constant Rose.Objects.Endpoint_Id :=
     16#C5CD_0953_4A8B_BC37#;

   Truncate_Endpoint             : constant Rose.Objects.Endpoint_Id :=
     16#87FC_81AD_DC91_1DB9#;

   New_Version_Endpoint          : constant Rose.Objects.Endpoint_Id :=
     16#9485_9E3C_A2FA_C7E8#;

   Size_Index                    : constant := 0;

   Open_Reader_Index             : constant := 1;

   Open_Seekable_Reader_Index    : constant := 2;

   Write_Index                   : constant := 3;

   Truncate_Index                : constant := 4;

   New_Version_Index             : constant := 5;

   Subprogram_Count              : constant := 6;

   type Writable_File_Object is limited interface
     and Rose.Interfaces.File.File_Object
     and Rose.Interfaces.Stream_Writer.Stream_Writer_Object;

   function Writable_File_Cap
     (Item : in out Writable_File_Object)
      return Rose.Capabilities.Capability is abstract;

   procedure Truncate
     (Item : in out Writable_File_Object;
      Size : System.Storage_Elements.Storage_Count) is abstract;

   function New_Version
     (Item : in out Writable_File_Object)
      return
        Rose.Interfaces.Transactional_Writable_File
          .Transactional_Writable_File_Object'Class is abstract;

end Rose.Interfaces.Writable_File;
