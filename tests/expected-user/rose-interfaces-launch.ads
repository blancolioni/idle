with Rose.Capabilities;
with Rose.Objects;
with System.Storage_Elements;
limited with Rose.Interfaces.Process;

package Rose.Interfaces.Launch is

   Launch_Interface        : constant Rose.Objects.Endpoint_Id :=
     16#8B8B_A324_FA51_3FD2#;

   Launch_Endpoint         : constant Rose.Objects.Endpoint_Id :=
     16#1E89_E16B_EF48_3A33#;

   Launch_Command_Endpoint : constant Rose.Objects.Endpoint_Id :=
     16#8329_BE24_AEF6_AF8F#;

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
      Environment : System.Storage_Elements.Storage_Array)
      return Rose.Interfaces.Process.Process_Object'Class is abstract;

   function Launch_Command
     (Item : in out Launch_Object)
      return Rose.Capabilities.Capability is abstract;

   function Metadata (Item : in out Launch_Object) return String is abstract;

end Rose.Interfaces.Launch;
