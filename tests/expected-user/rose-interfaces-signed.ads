with Rose.Capabilities;
with Rose.Objects;
with Rose.Words;

package Rose.Interfaces.Signed is

   Signed_Interface    : constant Rose.Objects.Endpoint_Id :=
     16#C9BD_4EF5_794E_6919#;

   Clamp_Endpoint      : constant Rose.Objects.Endpoint_Id :=
     16#CA6B_33C4_4D4B_04E3#;

   Position_Endpoint   : constant Rose.Objects.Endpoint_Id :=
     16#F3D8_5E15_6C48_987A#;

   Offset_Endpoint     : constant Rose.Objects.Endpoint_Id :=
     16#E9BD_1CBC_BB2D_CC7D#;

   Difference_Endpoint : constant Rose.Objects.Endpoint_Id :=
     16#F64B_7F5A_F9EA_9375#;

   Bounds_Endpoint     : constant Rose.Objects.Endpoint_Id :=
     16#3B28_34F6_4F0C_7FE3#;

   Clamp_Index         : constant := 0;

   Position_Index      : constant := 1;

   Offset_Index        : constant := 2;

   Difference_Index    : constant := 3;

   Bounds_Index        : constant := 4;

   Subprogram_Count    : constant := 5;

   type Signed_Object is limited interface;

   function Signed_Cap
     (Item : in out Signed_Object)
      return Rose.Capabilities.Capability is abstract;

   function Clamp
     (Item  : in out Signed_Object;
      Value : Integer;
      Low   : Integer)
      return Integer is abstract;

   procedure Position
     (Item  : in out Signed_Object;
      Index : Rose.Words.Word;
      X     : out Integer;
      Y     : out Integer;
      Count : out Natural) is abstract;

   procedure Offset
     (Item    : in out Signed_Object;
      Delta_X : in out Integer) is abstract;

   function Difference
     (Item  : in out Signed_Object;
      Left  : Long_Long_Integer;
      Right : Long_Long_Integer)
      return Long_Long_Integer is abstract;

   procedure Bounds
     (Item : in out Signed_Object;
      Low  : out Long_Long_Integer;
      High : out Long_Long_Integer) is abstract;

end Rose.Interfaces.Signed;
