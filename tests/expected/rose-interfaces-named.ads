with Rose.Objects;
with Rose.Words;

package Rose.Interfaces.Named is

   Max_Badges       : constant := 16;

   type Badge_Count is range 0 .. Max_Badges;

   type Badge_Serial is new Rose.Words.Word_64;

   type Badge_Colour is (Red, Green, Blue);

   Named_Interface  : constant Rose.Objects.Endpoint_Id := 16#1111_0000_0001#;

   Badge_Endpoint   : constant Rose.Objects.Endpoint_Id := 16#2222_0000_0001#;

   Badge_Index      : constant := 0;

   Subprogram_Count : constant := 1;

end Rose.Interfaces.Named;
