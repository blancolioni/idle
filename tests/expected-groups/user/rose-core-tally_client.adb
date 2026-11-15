with Rose.Command_Line.Launch_Client;

package body Rose.Core.Tally_Client is

   ----------
   -- Call --
   ----------

   procedure Call
     (Endpoint        : Rose.Capabilities.Capability;
      Counter_Service : Rose.Capabilities.Capability;
      Label           : Rose.Capabilities.Capability;
      Source          : Rose.Capabilities.Capability)
   is
      Launch_Call : Rose.Command_Line.Launch_Client.Launch_Call;
   begin
      Rose.Command_Line.Launch_Client.Start (Launch_Call, Endpoint);
      Rose.Command_Line.Launch_Client.Cap_Argument
        (Launch_Call,
         0,
         Counter_Service);
      Rose.Command_Line.Launch_Client.Cap_Argument (Launch_Call, 1, Label);
      Rose.Command_Line.Launch_Client.Cap_Argument (Launch_Call, 2, Source);
      Rose.Command_Line.Launch_Client.Invoke (Launch_Call);
   end Call;

end Rose.Core.Tally_Client;
