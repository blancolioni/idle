with Rose.Command_Line.Launch;
with Rose.Core.Tally;
with Rose.Core.Tally_Metadata;
with Rose.Interfaces.Common.Named.Client;
with Rose.Interfaces.Measures.Counter.Client;
pragma Unreferenced (Rose.Core.Tally_Metadata);

procedure Rose.Core.Tally_Main is
   Call            : Rose.Command_Line.Launch.Launch_Call;
   Counter_Service : Rose.Interfaces.Measures.Counter.Client.Counter_Client;
   Label           : Rose.Interfaces.Common.Named.Client.Named_Client;
   Source          : Rose.Interfaces.Common.Named.Client.Named_Client;
begin
   Rose.Command_Line.Launch.Receive (Call);
   Rose.Interfaces.Measures.Counter.Client.Open
     (Counter_Service,
      Rose.Command_Line.Launch.Cap_Argument (Call, 0));
   Rose.Interfaces.Common.Named.Client.Open
     (Label,
      Rose.Command_Line.Launch.Cap_Argument (Call, 1));
   Rose.Interfaces.Common.Named.Client.Open_Cap_Set
     (Source,
      Rose.Command_Line.Launch.Cap_Argument (Call, 2));
   Rose.Command_Line.Launch.Set_Command_Line ("Rose.Core.Tally");
   Rose.Core.Tally
     (Counter_Service => Counter_Service,
      Label => Label,
      Source => Source);
   Rose.Command_Line.Launch.Complete (Call);
end Rose.Core.Tally_Main;
