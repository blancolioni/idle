with Rose.Capabilities;
with Rose.Command_Line.Launch;
with Rose.Core.Serve;
with Rose.Core.Serve_Metadata;
with Rose.Interfaces.Directory.Client;
with Rose.System_Calls;
with Serve_Server;
pragma Unreferenced (Rose.Core.Serve_Metadata);

procedure Rose.Core.Serve_Main is
   Call   : Rose.Command_Line.Launch.Launch_Call;
   Home   : Rose.Interfaces.Directory.Client.Directory_Client;
   Result : Rose.Capabilities.Capability;
begin
   Rose.Command_Line.Launch.Receive (Call);
   Rose.Interfaces.Directory.Client.Open
     (Home,
      Rose.Command_Line.Launch.Cap_Argument (Call, 1));
   Rose.System_Calls.Use_Capabilities
     (Create_Endpoint => Rose.Command_Line.Launch.Cap_Argument (Call, 0));
   Rose.Core.Serve
     (Name => Rose.Command_Line.Launch.String_Argument (Call, 1),
      Home => Home,
      Result => Result);
   Rose.Command_Line.Launch.Cap_Result (Call, 0, Result);
   Rose.Command_Line.Launch.Complete (Call);
   Serve_Server.Start;
end Rose.Core.Serve_Main;
