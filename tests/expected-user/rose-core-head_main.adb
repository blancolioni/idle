with Rose.Command_Line.Launch;
with Rose.Core.Head;
with Rose.Core.Head_Metadata;
pragma Unreferenced (Rose.Core.Head_Metadata);

procedure Rose.Core.Head_Main is
   Call : Rose.Command_Line.Launch.Launch_Call;
begin
   Rose.Command_Line.Launch.Receive (Call);
   Rose.Command_Line.Launch.Use_Standard_Input (Call, 0);
   Rose.Command_Line.Launch.Use_Standard_Output (Call, 1);
   Rose.Command_Line.Launch.Use_Standard_Error (Call, 2);
   Rose.Core.Head
     (Lines => Positive (Rose.Command_Line.Launch.Natural_Argument (Call, 0)),
      Skip => Rose.Command_Line.Launch.Natural_Argument (Call, 1),
      Quiet => Rose.Command_Line.Launch.Boolean_Argument (Call, 2),
      Header => Rose.Command_Line.Launch.String_Argument (Call, 1),
      Prefix => Rose.Command_Line.Launch.String_Argument (Call, 2),
      Names => Rose.Command_Line.Launch.String_List_Argument (Call, 3, 3));
   Rose.Command_Line.Launch.Complete (Call);
end Rose.Core.Head_Main;
