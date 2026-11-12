with Rose.Command_Line.Launch_Client;

package body Rose.Core.Echo_Client is

   ----------
   -- Call --
   ----------

   procedure Call
     (Endpoint        : Rose.Capabilities.Capability;
      Standard_Output : Rose.Capabilities.Capability;
      New_Line        : Boolean := True;
      Arguments       : Rose.Command_Line.String_List)
   is
      Launch_Call : Rose.Command_Line.Launch_Client.Launch_Call;
   begin
      Rose.Command_Line.Launch_Client.Start (Launch_Call, Endpoint);
      Rose.Command_Line.Launch_Client.Cap_Argument
        (Launch_Call,
         0,
         Standard_Output);
      Rose.Command_Line.Launch_Client.Boolean_Argument
        (Launch_Call,
         0,
         New_Line);
      Rose.Command_Line.Launch_Client.String_List_Argument
        (Launch_Call,
         1,
         Arguments);
      Rose.Command_Line.Launch_Client.Invoke (Launch_Call);
   end Call;

end Rose.Core.Echo_Client;
