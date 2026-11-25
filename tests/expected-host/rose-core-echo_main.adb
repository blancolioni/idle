with Rose.Command_Line.Host;
with Rose.Core.Echo;
with Rose.Core.Echo_Metadata;

procedure Rose.Core.Echo_Main is
   Call : Rose.Command_Line.Host.Launch_Call;
begin
   Rose.Command_Line.Host.Receive (Call, Rose.Core.Echo_Metadata.Text);
   Rose.Core.Echo
     (New_Line => Rose.Command_Line.Host.Boolean_Argument (Call, 0),
      Arguments => Rose.Command_Line.Host.String_List_Argument (Call, 1, 1));
   Rose.Command_Line.Host.Complete (Call);
exception
   when E : Rose.Command_Line.Command_Failed =>
      Rose.Command_Line.Host.Fail (Call, E);
   when Rose.Command_Line.Host.Stopped =>
      null;
end Rose.Core.Echo_Main;
