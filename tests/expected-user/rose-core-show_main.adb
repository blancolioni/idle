with Rose.Command_Line.Launch;
with Rose.Core.Show;
with Rose.Core.Show_Metadata;
with Rose.Interfaces.File.Client;
with Rose.Interfaces.Stream_Writer.Client;
with Rose.System_Calls;
pragma Unreferenced (Rose.Core.Show_Metadata);

procedure Rose.Core.Show_Main is
   Call    : Rose.Command_Line.Launch.Launch_Call;
   Logging : Rose.Interfaces.Stream_Writer.Client.Stream_Writer_Client;
   Source  : Rose.Interfaces.File.Client.File_Client;
   Count   : Natural;
begin
   Rose.Command_Line.Launch.Receive (Call);
   Rose.Command_Line.Launch.Use_Standard_Output (Call, 0);
   Rose.Interfaces.Stream_Writer.Client.Open
     (Logging,
      Rose.Command_Line.Launch.Cap_Argument (Call, 1));
   Rose.Interfaces.File.Client.Open
     (Source,
      Rose.Command_Line.Launch.Cap_Argument (Call, 3));
   Rose.System_Calls.Use_Capabilities
     (Delete_Cap => Rose.Command_Line.Launch.Cap_Argument (Call, 2));
   Rose.Core.Show (Logging => Logging, Source => Source, Count => Count);
   Rose.Command_Line.Launch.Natural_Result (Call, 1, Count);
   Rose.Command_Line.Launch.Complete (Call);
end Rose.Core.Show_Main;
