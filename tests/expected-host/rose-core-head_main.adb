with Rose.Command_Line.Host;
with Rose.Core.Head;
with Rose.Core.Head_Metadata;

procedure Rose.Core.Head_Main is
   Call : Rose.Command_Line.Host.Launch_Call;
begin
   Rose.Command_Line.Host.Receive (Call, Rose.Core.Head_Metadata.Text);
   Rose.Core.Head
     (Lines => Positive (Rose.Command_Line.Host.Natural_Argument (Call, 0)),
      Skip => Rose.Command_Line.Host.Natural_Argument (Call, 1),
      Quiet => Rose.Command_Line.Host.Boolean_Argument (Call, 2),
      Header => Rose.Command_Line.Host.String_Argument (Call, 1),
      Prefix => Rose.Command_Line.Host.String_Argument (Call, 2),
      Names => Rose.Command_Line.Host.String_List_Argument (Call, 3, 3));
   Rose.Command_Line.Host.Complete (Call);
exception
   when E : Rose.Command_Line.Command_Failed =>
      Rose.Command_Line.Host.Fail (Call, E);
   when Rose.Command_Line.Host.Stopped =>
      null;
end Rose.Core.Head_Main;
