with Rose.Capabilities;
with Rose.Objects;
with System.Storage_Elements;
limited with Rose.Interfaces.Process;

package Rose.Interfaces.Launch is

   Launch_Interface        : constant Rose.Objects.Endpoint_Id :=
     16#8B8B_A324_FA51_3FD2#;

   Launch_Endpoint         : constant Rose.Objects.Endpoint_Id :=
     16#FC1_B77F_4AA3_E406#;

   Launch_Command_Endpoint : constant Rose.Objects.Endpoint_Id :=
     16#D74B_62A6_3FD9_8B4F#;

   Metadata_Endpoint       : constant Rose.Objects.Endpoint_Id :=
     16#2B7A_157F_3FEB_540B#;

   Launch_Index            : constant := 0;

   Launch_Command_Index    : constant := 1;

   Metadata_Index          : constant := 2;

   Subprogram_Count        : constant := 3;

   type Launch_Object is limited interface;

   function Launch_Cap
     (Item : in out Launch_Object)
      return Rose.Capabilities.Capability is abstract;

   function Launch
     (Item        : in out Launch_Object;
      Caps        : Rose.Capabilities.Capability_Array;
      Environment : System.Storage_Elements.Storage_Array)
      return Rose.Interfaces.Process.Process_Object'Class is abstract;

   function Launch_Command
     (Item : in out Launch_Object;
      Caps : Rose.Capabilities.Capability_Array)
      return Rose.Capabilities.Capability is abstract;

   function Metadata (Item : in out Launch_Object) return String is abstract;

end Rose.Interfaces.Launch;
