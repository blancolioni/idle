with Rose.Capabilities;
with Rose.Interfaces.Launch;
with Rose.Objects;
limited with Rose.Interfaces.Stream_Reader;
limited with Rose.Interfaces.Stream_Writer;

package Rose.Interfaces.Exec is

   Launch_Interface             : constant Rose.Objects.Endpoint_Id :=
     16#8B8B_A324_FA51_3FD2#;

   Exec_Interface               : constant Rose.Objects.Endpoint_Id :=
     16#4279_2F9D_69F2_5EA9#;

   Launch_Endpoint              : constant Rose.Objects.Endpoint_Id :=
     16#1E89_E16B_EF48_3A33#;

   Launch_Command_Endpoint      : constant Rose.Objects.Endpoint_Id :=
     16#8329_BE24_AEF6_AF8F#;

   Metadata_Endpoint            : constant Rose.Objects.Endpoint_Id :=
     16#2B7A_157F_3FEB_540B#;

   Install_Endpoint             : constant Rose.Objects.Endpoint_Id :=
     16#8A1C_7544_62D5_0C26#;

   Set_Standard_Output_Endpoint : constant Rose.Objects.Endpoint_Id :=
     16#FDE0_0BDD_7A19_06B9#;

   Launch_Index                 : constant := 0;

   Launch_Command_Index         : constant := 1;

   Metadata_Index               : constant := 2;

   Install_Index                : constant := 3;

   Set_Standard_Output_Index    : constant := 4;

   Subprogram_Count             : constant := 5;

   type Exec_Object is limited interface
     and Rose.Interfaces.Launch.Launch_Object;

   function Exec_Cap
     (Item : in out Exec_Object)
      return Rose.Capabilities.Capability is abstract;

   function Install
     (Item         : in out Exec_Object;
      Executable   : in out
        Rose.Interfaces.Stream_Reader.Stream_Reader_Object'Class;
      Name         : String;
      Install_Caps : Rose.Capabilities.Capability)
      return Rose.Interfaces.Launch.Launch_Object'Class is abstract;

   procedure Set_Standard_Output
     (Item   : in out Exec_Object;
      Output : in out Rose.Interfaces.Stream_Writer.Stream_Writer_Object'Class)
   is abstract;

end Rose.Interfaces.Exec;
