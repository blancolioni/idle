with Rose.Command_Line.Launch_Client;

package body Rose.Core.Show_Client is

   ----------
   -- Call --
   ----------

   procedure Call
     (Endpoint        : Rose.Capabilities.Capability;
      Standard_Output : Rose.Capabilities.Capability;
      Logging         : Rose.Capabilities.Capability;
      Delete_Cap      : Rose.Capabilities.Capability;
      Source          : Rose.Capabilities.Capability;
      Count           : out Natural;
      Input           : Rose.Capabilities.Capability)
   is
      Launch_Call : Rose.Command_Line.Launch_Client.Launch_Call;
   begin
      Rose.Command_Line.Launch_Client.Start (Launch_Call, Endpoint);
      Rose.Command_Line.Launch_Client.Cap_Argument
        (Launch_Call,
         0,
         Standard_Output);
      Rose.Command_Line.Launch_Client.Cap_Argument (Launch_Call, 1, Logging);
      Rose.Command_Line.Launch_Client.Cap_Argument
        (Launch_Call,
         2,
         Delete_Cap);
      Rose.Command_Line.Launch_Client.Cap_Argument (Launch_Call, 3, Source);
      Rose.Command_Line.Launch_Client.Cap_Argument (Launch_Call, 4, Input);
      Rose.Command_Line.Launch_Client.Invoke (Launch_Call);
      Count := Rose.Command_Line.Launch_Client.Natural_Result (Launch_Call, 1);
   end Call;

end Rose.Core.Show_Client;
