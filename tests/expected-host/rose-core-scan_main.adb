with Rose.Command_Line.Host;
with Rose.Core.Scan;
with Rose.Core.Scan_Metadata;
with Rose.Host.Files;
with Rose.Host.Streams;

procedure Rose.Core.Scan_Main is
   Call    : Rose.Command_Line.Host.Launch_Call;
   Logging : Rose.Host.Streams.Writer;
   Source  : Rose.Host.Files.File;
   Input   : Rose.Host.Streams.Reader;
   Root    : Rose.Host.Files.Directory;
begin
   Rose.Command_Line.Host.Receive (Call, Rose.Core.Scan_Metadata.Text);
   Rose.Host.Streams.Open
     (Logging,
      Rose.Command_Line.Host.Interface_Argument (Call, 1));
   Rose.Host.Files.Open
     (Source,
      Rose.Command_Line.Host.Interface_Argument (Call, 2));
   Rose.Host.Streams.Open
     (Input,
      Rose.Command_Line.Host.Interface_Argument (Call, 3));
   Rose.Host.Files.Open
     (Root,
      Rose.Command_Line.Host.Interface_Argument (Call, 4));
   Rose.Core.Scan
     (Logging => Logging,
      Source => Source,
      Input => Input,
      Root => Root,
      Verbose => Rose.Command_Line.Host.Boolean_Argument (Call, 0));
   Rose.Command_Line.Host.Complete (Call);
exception
   when E : Rose.Command_Line.Command_Failed =>
      Rose.Command_Line.Host.Fail (Call, E);
   when Rose.Command_Line.Host.Stopped =>
      null;
end Rose.Core.Scan_Main;
