with Rose.Command_Line.Launch_Client;
with Rose.Texts;

package body Rose.Core.Copy_Client is

   ----------
   -- Call --
   ----------

   procedure Call
     (Endpoint        : Rose.Capabilities.Capability;
      Standard_Error  : Rose.Capabilities.Capability;
      Logging         : Rose.Capabilities.Capability;
      Create_Endpoint : Rose.Capabilities.Capability;
      Delete_Cap      : Rose.Capabilities.Capability;
      Source          : Rose.Capabilities.Capability;
      Target          : Rose.Capabilities.Capability;
      Root            : Rose.Capabilities.Capability;
      Batch           : Rose.Capabilities.Capability;
      Draft           : Rose.Capabilities.Capability;
      Ledger          : Rose.Capabilities.Capability;
      Copied          : out Rose.Capabilities.Capability;
      Count           : out Natural;
      Verbose         : Boolean := False;
      Report          : out Rose.Command_Line.Text;
      Note            : String := "none")
   is
      Launch_Call : Rose.Command_Line.Launch_Client.Launch_Call;
   begin
      Rose.Command_Line.Launch_Client.Start (Launch_Call, Endpoint);
      Rose.Command_Line.Launch_Client.Cap_Argument
        (Launch_Call,
         0,
         Standard_Error);
      Rose.Command_Line.Launch_Client.Cap_Argument (Launch_Call, 1, Logging);
      Rose.Command_Line.Launch_Client.Cap_Argument
        (Launch_Call,
         2,
         Create_Endpoint);
      Rose.Command_Line.Launch_Client.Cap_Argument
        (Launch_Call,
         3,
         Delete_Cap);
      Rose.Command_Line.Launch_Client.Cap_Argument (Launch_Call, 4, Source);
      Rose.Command_Line.Launch_Client.Cap_Argument (Launch_Call, 5, Target);
      Rose.Command_Line.Launch_Client.Cap_Argument (Launch_Call, 6, Root);
      Rose.Command_Line.Launch_Client.Cap_Argument (Launch_Call, 7, Batch);
      Rose.Command_Line.Launch_Client.Cap_Argument (Launch_Call, 8, Draft);
      Rose.Command_Line.Launch_Client.Cap_Argument (Launch_Call, 9, Ledger);
      Rose.Command_Line.Launch_Client.Boolean_Argument
        (Launch_Call,
         0,
         Verbose);
      Rose.Command_Line.Launch_Client.String_Argument (Launch_Call, Note);
      Rose.Command_Line.Launch_Client.Invoke (Launch_Call);
      Copied := Rose.Command_Line.Launch_Client.Cap_Result (Launch_Call, 0);
      Count := Rose.Command_Line.Launch_Client.Natural_Result (Launch_Call, 1);
      Report :=
        Rose.Texts.To_Text
          (Rose.Command_Line.Launch_Client.String_Result (Launch_Call, 1));
   end Call;

end Rose.Core.Copy_Client;
