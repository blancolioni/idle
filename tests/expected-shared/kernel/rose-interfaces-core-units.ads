with Interfaces;
with Rose.Objects;
with Rose.Words;

package Rose.Interfaces.Core.Units is

   type Bytes is new Rose.Words.Word_64;

   type Duration is new Standard.Interfaces.Integer_64;

   type Percent is range 0 .. 100;

   type Unit_Kind is (Size, Time);

   Units_Interface  : constant Rose.Objects.Endpoint_Id :=
     16#E245_8E22_1EC7_813F#;

   Subprogram_Count : constant := 0;

end Rose.Interfaces.Core.Units;
