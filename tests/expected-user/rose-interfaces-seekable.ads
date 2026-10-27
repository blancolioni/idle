with Rose.Objects;
with Rose.Words;

package Rose.Interfaces.Seekable is

   Seekable_Interface : constant Rose.Objects.Endpoint_Id :=
     16#6496_B9FE_93A9_D452#;

   Seek_Endpoint      : constant Rose.Objects.Endpoint_Id :=
     16#61A2_A8A5_DB58_B9E9#;

   Seek_Index         : constant := 0;

   Subprogram_Count   : constant := 1;

   type Seekable_Object is limited interface;

   procedure Seek
     (Item              : in out Seekable_Object;
      Offset_From_Start : Rose.Words.Word_64) is abstract;

end Rose.Interfaces.Seekable;
