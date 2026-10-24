with Rose.Command_Line.Launch;
with Rose.Core.Echo;
with Rose.Core.Echo_Metadata;
pragma Unreferenced (Rose.Core.Echo_Metadata);

procedure Rose.Core.Echo_Main is
   Call : Rose.Command_Line.Launch.Launch_Call;
begin
   Rose.Command_Line.Launch.Receive (Call);
   Rose.Command_Line.Launch.Use_Standard_Output (Call, 0);
   Rose.Core.Echo
     (New_Line => Rose.Command_Line.Launch.Boolean_Argument (Call, 0),
      Arguments => Rose.Command_Line.Launch.String_List_Argument (Call, 1, 1));
   Rose.Command_Line.Launch.Complete (Call);
end Rose.Core.Echo_Main;
