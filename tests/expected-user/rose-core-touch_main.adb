with Rose.Command_Line.Launch;
with Rose.Core.Touch;
with Rose.Core.Touch_Metadata;
with Rose.Interfaces.Writable_Directory.Client;
pragma Unreferenced (Rose.Core.Touch_Metadata);

procedure Rose.Core.Touch_Main is
   Call      : Rose.Command_Line.Launch.Launch_Call;
   Directory : Rose.Interfaces.Writable_Directory.Client
     .Writable_Directory_Client;
begin
   Rose.Command_Line.Launch.Receive (Call);
   Rose.Interfaces.Writable_Directory.Client.Open
     (Directory,
      Rose.Command_Line.Launch.Cap_Argument (Call, 0));
   Rose.Core.Touch
     (Name => Rose.Command_Line.Launch.String_Argument (Call, 1),
      Directory => Directory);
   Rose.Command_Line.Launch.Complete (Call);
end Rose.Core.Touch_Main;
