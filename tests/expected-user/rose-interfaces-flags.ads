with Rose.Capabilities;
with Rose.Objects;
with Rose.Words;

package Rose.Interfaces.Flags is

   Flags_Interface  : constant Rose.Objects.Endpoint_Id :=
     16#E222_B9A6_AF39_39FA#;

   Is_Set_Endpoint  : constant Rose.Objects.Endpoint_Id :=
     16#FBEE_A308_6854_947D#;

   Query_Endpoint   : constant Rose.Objects.Endpoint_Id :=
     16#AF34_98CB_4898_77B8#;

   Toggle_Endpoint  : constant Rose.Objects.Endpoint_Id :=
     16#46FD_6516_3D1F_0544#;

   Is_Set_Index     : constant := 0;

   Query_Index      : constant := 1;

   Toggle_Index     : constant := 2;

   Subprogram_Count : constant := 3;

   type Flags_Object is limited interface;

   function Flags_Cap
     (Item : in out Flags_Object)
      return Rose.Capabilities.Capability is abstract;

   function Is_Set
     (Item    : in out Flags_Object;
      Name    : String;
      Default : Boolean)
      return Boolean is abstract;

   procedure Query
     (Item    : in out Flags_Object;
      Index   : Rose.Words.Word;
      Trusted : out Boolean;
      Count   : out Natural) is abstract;

   procedure Toggle
     (Item  : in out Flags_Object;
      Value : in out Boolean) is abstract;

end Rose.Interfaces.Flags;
