with Rose.Command_Line.Launch;
with Rose.Core.Probe;
with Rose.Core.Probe_Metadata;
with Rose.Interfaces.Stream_Writer.Client;
pragma Unreferenced (Rose.Core.Probe_Metadata);

procedure Rose.Core.Probe_Main is
   Call     : Rose.Command_Line.Launch.Launch_Call;
   Time_Log : Rose.Interfaces.Stream_Writer.Client.Stream_Writer_Client;
   Port_Log : Rose.Interfaces.Stream_Writer.Client.Stream_Writer_Client;
begin
   Rose.Command_Line.Launch.Receive (Call);
   Rose.Interfaces.Stream_Writer.Client.Open
     (Time_Log,
      Rose.Command_Line.Launch.Cap_Argument (Call, 0));
   Rose.Interfaces.Stream_Writer.Client.Open
     (Port_Log,
      Rose.Command_Line.Launch.Cap_Argument (Call, 1));
   Rose.Command_Line.Launch.Use_Standard_Output (Call, 2);
   Rose.Command_Line.Launch.Use_Standard_Error (Call, 3);
   Rose.Core.Probe (Time_Log => Time_Log, Port_Log => Port_Log);
   Rose.Command_Line.Launch.Complete (Call);
end Rose.Core.Probe_Main;
