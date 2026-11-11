with Replace_Server;
with Replace_Server.State;
with Rose.Capabilities;
with Rose.Command_Line.Launch;
with Rose.Core.Replace;
with Rose.Core.Replace_Metadata;
with Rose.Interfaces.Constructor.Client;
with Rose.Replacement;
with Rose.System_Calls;
pragma Unreferenced (Rose.Core.Replace_Metadata);

procedure Rose.Core.Replace_Main is
   Call            : Rose.Command_Line.Launch.Launch_Call;
   Cap_Set_Service : Rose.Interfaces.Constructor.Client.Constructor_Client;
   Result          : Rose.Capabilities.Capability;
   Restore_Caps    : Rose.Replacement.Named_Caps;
begin
   Rose.Command_Line.Launch.Receive (Call);
   Rose.Interfaces.Constructor.Client.Open
     (Cap_Set_Service,
      Rose.Command_Line.Launch.Cap_Argument (Call, 1));
   Rose.System_Calls.Use_Capabilities
     (Create_Endpoint => Rose.Command_Line.Launch.Cap_Argument (Call, 0));
   Restore_Caps.Add
     ("Cap_Set_Service",
      Rose.Command_Line.Launch.Cap_Argument (Call, 1));
   Rose.Replacement.Start
     (Rose.Command_Line.Launch.Cap_Argument (Call, 2),
      Rose.Command_Line.Launch.Cap_Argument (Call, 3),
      Restore_Caps,
      Replace_Server.State.Read_State'Access);
   Rose.Command_Line.Launch.Set_Command_Line ("Rose.Core.Replace");
   Rose.Core.Replace (Cap_Set_Service => Cap_Set_Service, Result => Result);
   Rose.Command_Line.Launch.Cap_Result (Call, 0, Result);
   Rose.Command_Line.Launch.Complete (Call);
   Replace_Server.Start;
end Rose.Core.Replace_Main;
