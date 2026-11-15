with Rose.Capabilities;
with Rose.Objects;

package Rose.Interfaces.Common.Named is

   Named_Interface  : constant Rose.Objects.Endpoint_Id :=
     16#9208_2F83_E925_52F0#;

   Badge_Endpoint   : constant Rose.Objects.Endpoint_Id :=
     16#C9B6_319C_F3D5_7B5C#;

   Badge_Index      : constant := 0;

   Subprogram_Count : constant := 1;

   type Named_Object is limited interface;

   function Named_Cap
     (Item : in out Named_Object)
      return Rose.Capabilities.Capability is abstract;

   function Badge
     (Item : in out Named_Object)
      return Rose.Capabilities.Capability is abstract;

end Rose.Interfaces.Common.Named;
