with Rose.Capabilities;
with Rose.Objects;

package Rose.Interfaces.Resource is

   Resource_Interface : constant Rose.Objects.Endpoint_Id :=
     16#F49B_1FE7_07D3_B4B5#;

   Release_Endpoint   : constant Rose.Objects.Endpoint_Id :=
     16#7F24_9764_E75A_970F#;

   Release_Index      : constant := 0;

   Subprogram_Count   : constant := 1;

   type Resource_Object is limited interface;

   function Resource_Cap
     (Item : in out Resource_Object)
      return Rose.Capabilities.Capability is abstract;

   procedure Release (Item : in out Resource_Object) is abstract;

end Rose.Interfaces.Resource;
