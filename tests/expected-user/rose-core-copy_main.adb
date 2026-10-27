with Rose.Command_Line.Launch;
with Rose.Core.Copy;
with Rose.Core.Copy_Metadata;
with Rose.Interfaces.Directory.Client;
with Rose.Interfaces.File.Client;
with Rose.Interfaces.Stream_Writer.Client;
with Rose.Strings;
with Rose.System_Calls;
pragma Unreferenced (Rose.Core.Copy_Metadata);

procedure Rose.Core.Copy_Main is
   Call    : Rose.Command_Line.Launch.Launch_Call;
   Logging : Rose.Interfaces.Stream_Writer.Client.Stream_Writer_Client;
   Source  : Rose.Interfaces.File.Client.File_Client;
   Target  : Rose.Interfaces.File.Client.File_Client;
   Root    : Rose.Interfaces.Directory.Client.Directory_Client;
   Count   : Natural;
   Verbose : Boolean;
   Report  : Rose.Command_Line.Text;
   Note    : Rose.Command_Line.Text;
begin
   Rose.Command_Line.Launch.Receive (Call);
   Rose.Command_Line.Launch.Use_Standard_Error (Call, 0);
   Rose.Interfaces.Stream_Writer.Client.Open
     (Logging,
      Rose.Command_Line.Launch.Cap_Argument (Call, 1));
   Rose.Interfaces.File.Client.Open
     (Source,
      Rose.Command_Line.Launch.Cap_Argument (Call, 4));
   Rose.Interfaces.File.Client.Open
     (Target,
      Rose.Command_Line.Launch.Cap_Argument (Call, 5));
   Rose.Interfaces.Directory.Client.Open
     (Root,
      Rose.Command_Line.Launch.Cap_Argument (Call, 6));
   Verbose := Rose.Command_Line.Launch.Boolean_Argument (Call, 0);
   Note :=
     Rose.Strings.To_Text (Rose.Command_Line.Launch.String_Argument (Call, 1));
   Rose.System_Calls.Use_Capabilities
     (Create_Endpoint => Rose.Command_Line.Launch.Cap_Argument (Call, 2),
      Delete_Cap => Rose.Command_Line.Launch.Cap_Argument (Call, 3));
   Rose.Core.Copy
     (Logging => Logging,
      Source => Source,
      Target => Target,
      Root => Root,
      Count => Count,
      Verbose => Verbose,
      Report => Report,
      Note => Note);
   Rose.Command_Line.Launch.Natural_Result (Call, 1, Count);
   Rose.Command_Line.Launch.Boolean_Result (Call, 2, Verbose);
   Rose.Command_Line.Launch.String_Result
     (Call,
      1,
      Rose.Strings.To_String (Report));
   Rose.Command_Line.Launch.String_Result
     (Call,
      2,
      Rose.Strings.To_String (Note));
   Rose.Command_Line.Launch.Complete (Call);
end Rose.Core.Copy_Main;
