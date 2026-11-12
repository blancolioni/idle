with Rose.Command_Line.Launch_Client;

package body Rose.Core.Head_Client is

   ----------
   -- Call --
   ----------

   procedure Call
     (Endpoint        : Rose.Capabilities.Capability;
      Standard_Input  : Rose.Capabilities.Capability;
      Standard_Output : Rose.Capabilities.Capability;
      Standard_Error  : Rose.Capabilities.Capability;
      Lines           : Positive := 10;
      Skip            : Natural := 0;
      Quiet           : Boolean := False;
      Header          : String := "==> ""input"" <==";
      Prefix          : String;
      Names           : Rose.Command_Line.String_List)
   is
      Launch_Call : Rose.Command_Line.Launch_Client.Launch_Call;
   begin
      Rose.Command_Line.Launch_Client.Start (Launch_Call, Endpoint);
      Rose.Command_Line.Launch_Client.Cap_Argument
        (Launch_Call,
         0,
         Standard_Input);
      Rose.Command_Line.Launch_Client.Cap_Argument
        (Launch_Call,
         1,
         Standard_Output);
      Rose.Command_Line.Launch_Client.Cap_Argument
        (Launch_Call,
         2,
         Standard_Error);
      Rose.Command_Line.Launch_Client.Natural_Argument (Launch_Call, 0, Lines);
      Rose.Command_Line.Launch_Client.Natural_Argument (Launch_Call, 1, Skip);
      Rose.Command_Line.Launch_Client.Boolean_Argument (Launch_Call, 2, Quiet);
      Rose.Command_Line.Launch_Client.String_Argument (Launch_Call, Header);
      Rose.Command_Line.Launch_Client.String_Argument (Launch_Call, Prefix);
      Rose.Command_Line.Launch_Client.String_List_Argument
        (Launch_Call,
         3,
         Names);
      Rose.Command_Line.Launch_Client.Invoke (Launch_Call);
   end Call;

end Rose.Core.Head_Client;
