with Rose.Command_Line.Launch_Client;

package body Rose.Core.Serve_Client is

   ----------
   -- Call --
   ----------

   procedure Call
     (Endpoint        : Rose.Capabilities.Capability;
      Create_Endpoint : Rose.Capabilities.Capability;
      Name            : String;
      Home            : Rose.Capabilities.Capability;
      Result          : out Rose.Capabilities.Capability)
   is
      Launch_Call : Rose.Command_Line.Launch_Client.Launch_Call;
   begin
      Rose.Command_Line.Launch_Client.Start (Launch_Call, Endpoint);
      Rose.Command_Line.Launch_Client.Cap_Argument
        (Launch_Call,
         0,
         Create_Endpoint);
      Rose.Command_Line.Launch_Client.Cap_Argument (Launch_Call, 1, Home);
      Rose.Command_Line.Launch_Client.String_Argument (Launch_Call, Name);
      Rose.Command_Line.Launch_Client.Invoke (Launch_Call);
      Result := Rose.Command_Line.Launch_Client.Cap_Result (Launch_Call, 0);
   end Call;

end Rose.Core.Serve_Client;
