with Rose.Command_Line.Launch_Client;

package body Rose.Core.Edit_Client is

   ----------
   -- Call --
   ----------

   procedure Call
     (Endpoint       : Rose.Capabilities.Capability;
      Standard_Error : Rose.Capabilities.Capability;
      Doc            : Rose.Capabilities.Capability;
      Doc_Selector   : Natural := 0;
      Lines          : Natural := 0;
      Input          : Rose.Capabilities.Capability;
      Input_Selector : Natural := 0)
   is
      Launch_Call : Rose.Command_Line.Launch_Client.Launch_Call;
   begin
      Rose.Command_Line.Launch_Client.Start (Launch_Call, Endpoint);
      Rose.Command_Line.Launch_Client.Cap_Argument
        (Launch_Call,
         0,
         Standard_Error);
      Rose.Command_Line.Launch_Client.Cap_Argument (Launch_Call, 1, Doc);
      Rose.Command_Line.Launch_Client.Natural_Argument
        (Launch_Call,
         0,
         Doc_Selector);
      Rose.Command_Line.Launch_Client.Natural_Argument (Launch_Call, 1, Lines);
      Rose.Command_Line.Launch_Client.Cap_Argument (Launch_Call, 2, Input);
      Rose.Command_Line.Launch_Client.Natural_Argument
        (Launch_Call,
         2,
         Input_Selector);
      Rose.Command_Line.Launch_Client.Invoke (Launch_Call);
   end Call;

end Rose.Core.Edit_Client;
