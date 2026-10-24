with Rose.Objects;

package Rose.Interfaces.Exec is

   Launch_Interface : constant Rose.Objects.Endpoint_Id := 16#60A8_2B69_97DC#;

   Exec_Interface   : constant Rose.Objects.Endpoint_Id := 16#AB32_3151_FC8F#;

   Launch_Endpoint  : constant Rose.Objects.Endpoint_Id := 16#377_796D_7E54#;

   Install_Endpoint : constant Rose.Objects.Endpoint_Id := 16#F4E3_8AA2_B8DE#;

   Launch_Index     : constant := 0;

   Install_Index    : constant := 1;

   Subprogram_Count : constant := 2;

end Rose.Interfaces.Exec;
