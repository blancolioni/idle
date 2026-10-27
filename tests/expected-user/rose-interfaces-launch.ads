with Rose.Capabilities;
with Rose.Objects;
with System.Storage_Elements;
limited with Rose.Interfaces.Process;

package Rose.Interfaces.Launch is

   Launch_Interface : constant Rose.Objects.Endpoint_Id :=
     16#8B8B_A324_FA51_3FD2#;

   Launch_Endpoint  : constant Rose.Objects.Endpoint_Id :=
     16#FC1_B77F_4AA3_E406#;

   Launch_Index     : constant := 0;

   Subprogram_Count : constant := 1;

   type Launch_Object is limited interface;

   function Launch_Cap
     (Item : in out Launch_Object)
      return Rose.Capabilities.Capability is abstract;

   function Launch
     (Item        : in out Launch_Object;
      Caps        : Rose.Capabilities.Capability_Array;
      Environment : System.Storage_Elements.Storage_Array)
      return Rose.Interfaces.Process.Process_Object'Class is abstract;

end Rose.Interfaces.Launch;
