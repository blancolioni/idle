with Rose.Capabilities;
with Rose.Interfaces.Resource;
with Rose.Interfaces.Stream_Reader;
with Rose.Objects;

package Rose.Interfaces.File_Reader is

   Stream_Reader_Interface : constant Rose.Objects.Endpoint_Id :=
     16#51A3_D80D_A576_BBEA#;

   Resource_Interface      : constant Rose.Objects.Endpoint_Id :=
     16#F49B_1FE7_07D3_B4B5#;

   File_Reader_Interface   : constant Rose.Objects.Endpoint_Id :=
     16#B2E9_4013_771C_C77A#;

   Read_Endpoint           : constant Rose.Objects.Endpoint_Id :=
     16#9175_845E_31B1_857C#;

   Release_Endpoint        : constant Rose.Objects.Endpoint_Id :=
     16#7F24_9764_E75A_970F#;

   Read_Index              : constant := 0;

   Release_Index           : constant := 1;

   Subprogram_Count        : constant := 2;

   type File_Reader_Object is limited interface
     and Rose.Interfaces.Stream_Reader.Stream_Reader_Object
     and Rose.Interfaces.Resource.Resource_Object;

   function File_Reader_Cap
     (Item : in out File_Reader_Object)
      return Rose.Capabilities.Capability is abstract;

end Rose.Interfaces.File_Reader;
