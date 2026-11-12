with Rose.Command_Line.Launch_Client;

package body Rose.Core.Replace_Client is

   ----------
   -- Call --
   ----------

   procedure Call
     (Endpoint        : Rose.Capabilities.Capability;
      Create_Endpoint : Rose.Capabilities.Capability;
      Cap_Set_Service : Rose.Capabilities.Capability;
      Result          : out Rose.Capabilities.Capability;
      Previous        : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
      Saved           : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability)
   is
      Launch_Call : Rose.Command_Line.Launch_Client.Launch_Call;
   begin
      Rose.Command_Line.Launch_Client.Start (Launch_Call, Endpoint);
      Rose.Command_Line.Launch_Client.Cap_Argument
        (Launch_Call,
         0,
         Create_Endpoint);
      Rose.Command_Line.Launch_Client.Cap_Argument
        (Launch_Call,
         1,
         Cap_Set_Service);
      Rose.Command_Line.Launch_Client.Optional_Cap_Argument
        (Launch_Call,
         2,
         Previous);
      Rose.Command_Line.Launch_Client.Optional_Cap_Argument
        (Launch_Call,
         3,
         Saved);
      Rose.Command_Line.Launch_Client.Invoke (Launch_Call);
      Result := Rose.Command_Line.Launch_Client.Cap_Result (Launch_Call, 0);
   end Call;

end Rose.Core.Replace_Client;
