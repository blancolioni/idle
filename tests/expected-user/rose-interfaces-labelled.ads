with Rose.Capabilities;
with Rose.Objects;
with Rose.Words;

package Rose.Interfaces.Labelled is

   Labelled_Interface : constant Rose.Objects.Endpoint_Id :=
     16#11FE_D019_CE22_9B98#;

   Badge_Endpoint     : constant Rose.Objects.Endpoint_Id :=
     16#3E0F_A7AD_9812_58AB#;

   Set_Label_Endpoint : constant Rose.Objects.Endpoint_Id :=
     16#FE9E_9999_9FF9_2D7A#;

   Badge_Index        : constant := 0;

   Set_Label_Index    : constant := 1;

   Subprogram_Count   : constant := 2;

   type Labelled_Object is limited interface;

   function Badge
     (Item : Labelled_Object)
      return Rose.Capabilities.Capability is abstract;

   procedure Set_Label
     (Item  : in out Labelled_Object;
      Label : Rose.Words.Word) is abstract;

end Rose.Interfaces.Labelled;
