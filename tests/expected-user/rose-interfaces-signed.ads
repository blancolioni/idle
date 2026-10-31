with Interfaces;
with Rose.Capabilities;
with Rose.Objects;
with Rose.Words;

package Rose.Interfaces.Signed is

   Signed_Interface    : constant Rose.Objects.Endpoint_Id :=
     16#C9BD_4EF5_794E_6919#;

   Clamp_Endpoint      : constant Rose.Objects.Endpoint_Id :=
     16#8087_6C4F_CB8B_D8FA#;

   Position_Endpoint   : constant Rose.Objects.Endpoint_Id :=
     16#C55D_DED1_F2CD_A995#;

   Offset_Endpoint     : constant Rose.Objects.Endpoint_Id :=
     16#45FC_D3DA_8AFD_AC18#;

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
      Value : Standard.Interfaces.Integer_32;
      Low   : Standard.Interfaces.Integer_32)
      return Standard.Interfaces.Integer_32 is abstract;

   procedure Position
     (Item  : in out Signed_Object;
      Index : Rose.Words.Word;
      X     : out Standard.Interfaces.Integer_32;
      Y     : out Standard.Interfaces.Integer_32;
      Count : out Natural) is abstract;

   procedure Offset
     (Item    : in out Signed_Object;
      Delta_X : in out Standard.Interfaces.Integer_32) is abstract;

   function Difference
     (Item  : in out Signed_Object;
      Left  : Standard.Interfaces.Integer_64;
      Right : Standard.Interfaces.Integer_64)
      return Standard.Interfaces.Integer_64 is abstract;

   procedure Bounds
     (Item : in out Signed_Object;
      Low  : out Standard.Interfaces.Integer_64;
      High : out Standard.Interfaces.Integer_64) is abstract;

end Rose.Interfaces.Signed;
