with Rose.Command_Line.Launch_Client;

package body Rose.Core.Touch_Client is

   ----------
   -- Call --
   ----------

   procedure Call
     (Endpoint  : Rose.Capabilities.Capability;
      Name      : String;
      Directory : Rose.Capabilities.Capability)
   is
      Launch_Call : Rose.Command_Line.Launch_Client.Launch_Call;
   begin
      Rose.Command_Line.Launch_Client.Start (Launch_Call, Endpoint);
      Rose.Command_Line.Launch_Client.Cap_Argument (Launch_Call, 0, Directory);
      Rose.Command_Line.Launch_Client.String_Argument (Launch_Call, Name);
      Rose.Command_Line.Launch_Client.Invoke (Launch_Call);
   end Call;

end Rose.Core.Touch_Client;
