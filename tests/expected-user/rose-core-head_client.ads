with Rose.Capabilities;
with Rose.Command_Line;

package Rose.Core.Head_Client is

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
      Names           : Rose.Command_Line.String_List);

end Rose.Core.Head_Client;
