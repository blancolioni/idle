with Rose.Capabilities;
with Rose.Objects;
with Rose.Words;
with System.Storage_Elements;

package Rose.Interfaces.Items is

   Items_Interface  : constant Rose.Objects.Endpoint_Id :=
     16#AB81_444D_7CB2_F569#;

   Pair_Endpoint    : constant Rose.Objects.Endpoint_Id :=
     16#9EF4_CA15_6DC2_770E#;

   Store_Endpoint   : constant Rose.Objects.Endpoint_Id :=
     16#A192_4F73_53F4_11F5#;

   Single_Endpoint  : constant Rose.Objects.Endpoint_Id :=
     16#FC53_F4B0_6A40_06D6#;

   Pair_Index       : constant := 0;

   Store_Index      : constant := 1;

   Single_Index     : constant := 2;

   Subprogram_Count : constant := 3;

   type Items_Object is limited interface;

   function Items_Cap
     (Item : in out Items_Object)
      return Rose.Capabilities.Capability is abstract;

   function Pair
     (Item     : in out Items_Object;
      Name     : String;
      Password : String)
      return Rose.Capabilities.Capability is abstract;

   procedure Store
     (Item  : in out Items_Object;
      Index : Rose.Words.Word;
      Key   : String;
      Data  : System.Storage_Elements.Storage_Array;
      Owner : Rose.Capabilities.Capability) is abstract;

   procedure Single (Item : in out Items_Object; Name : String) is abstract;

end Rose.Interfaces.Items;
