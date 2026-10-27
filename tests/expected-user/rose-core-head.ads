with Rose.Command_Line;

procedure Rose.Core.Head
  (Lines  : Positive := 10;
   Skip   : Natural := 0;
   Quiet  : Boolean := False;
   Header : String := "==> ""input"" <==";
   Prefix : String;
   Names  : Rose.Command_Line.String_List);
