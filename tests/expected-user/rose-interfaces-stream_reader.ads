with Rose.Objects;
with System.Storage_Elements;

package Rose.Interfaces.Stream_Reader is

   Stream_Reader_Interface : constant Rose.Objects.Endpoint_Id :=
     16#51A3_D80D_A576_BBEA#;

   Read_Endpoint           : constant Rose.Objects.Endpoint_Id :=
     16#9175_845E_31B1_857C#;

   Read_Index              : constant := 0;

   Subprogram_Count        : constant := 1;

   type Stream_Reader_Object is limited interface;

   procedure Read
     (Item   : in out Stream_Reader_Object;
      Buffer : out System.Storage_Elements.Storage_Array;
      Last   : out System.Storage_Elements.Storage_Count) is abstract;

end Rose.Interfaces.Stream_Reader;
