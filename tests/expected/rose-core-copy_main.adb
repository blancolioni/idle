with Rose.Capabilities;
with Rose.Command_Line.Launch;
with Rose.Core.Copy;
with Rose.Core.Copy_Metadata;
with Rose.Interfaces.File.Client;
with Rose.Interfaces.Stream_Writer.Client;
with Rose.Interfaces.Writable_Directory.Client;
with Rose.Interfaces.Writable_File.Client;
with Rose.System_Calls;
pragma Unreferenced (Rose.Core.Copy_Metadata);

procedure Rose.Core.Copy_Main is
   Call        : Rose.Command_Line.Launch.Launch_Call;
   Logging     : Rose.Interfaces.Stream_Writer.Client.Stream_Writer_Client;
   Source      : Rose.Interfaces.File.Client.File_Client;
   Target      : Rose.Interfaces.Writable_File.Client.Writable_File_Client;
   Root        : Rose.Interfaces.Writable_Directory.Client
     .Writable_Directory_Client;
   Copied      : Rose.Capabilities.Capability;
   Count       : Natural;
   Report      : String (1 .. Rose.Command_Line.Launch.Max_Result_Length);
   Report_Last : Natural;
begin
   Rose.Command_Line.Launch.Receive (Call);
   Rose.Command_Line.Launch.Use_Standard_Error (Call, 0);
   Rose.Interfaces.Stream_Writer.Client.Open
     (Logging,
      Rose.Command_Line.Launch.Cap_Argument (Call, 1));
   Rose.Interfaces.File.Client.Open
     (Source,
      Rose.Command_Line.Launch.Cap_Argument (Call, 4));
   Rose.Interfaces.Writable_File.Client.Open
     (Target,
      Rose.Command_Line.Launch.Cap_Argument (Call, 5));
   Rose.Interfaces.Writable_Directory.Client.Open
     (Root,
      Rose.Command_Line.Launch.Cap_Argument (Call, 6));
   Rose.System_Calls.Use_Capabilities
     (Create_Endpoint => Rose.Command_Line.Launch.Cap_Argument (Call, 2),
      Delete_Cap => Rose.Command_Line.Launch.Cap_Argument (Call, 3));
   Rose.Core.Copy
     (Logging => Logging,
      Source => Source,
      Target => Target,
      Root => Root,
      Copied => Copied,
      Count => Count,
      Verbose => Rose.Command_Line.Launch.Boolean_Argument (Call, 0),
      Report => Report,
      Report_Last => Report_Last,
      Note => Rose.Command_Line.Launch.String_Argument (Call, 1));
   Rose.Command_Line.Launch.Cap_Result (Call, 0, Copied);
   Rose.Command_Line.Launch.Natural_Result (Call, 1, Count);
   Rose.Command_Line.Launch.String_Result (Call, 1, Report (1 .. Report_Last));
   Rose.Command_Line.Launch.Complete (Call);
end Rose.Core.Copy_Main;
