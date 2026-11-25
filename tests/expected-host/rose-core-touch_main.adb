with Rose.Command_Line.Host;
with Rose.Core.Touch;
with Rose.Core.Touch_Metadata;
with Rose.Host.Files;

procedure Rose.Core.Touch_Main is
   Call      : Rose.Command_Line.Host.Launch_Call;
   Directory : Rose.Host.Files.Directory;
begin
   Rose.Command_Line.Host.Receive (Call, Rose.Core.Touch_Metadata.Text);
   Rose.Host.Files.Open
     (Directory,
      Rose.Command_Line.Host.Interface_Argument (Call, 0));
   Rose.Core.Touch
     (Name => Rose.Command_Line.Host.String_Argument (Call, 1),
      Directory => Directory);
   Rose.Command_Line.Host.Complete (Call);
exception
   when E : Rose.Command_Line.Command_Failed =>
      Rose.Command_Line.Host.Fail (Call, E);
   when Rose.Command_Line.Host.Stopped =>
      null;
end Rose.Core.Touch_Main;
