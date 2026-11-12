with Rose.Capabilities;
with Rose.Command_Line;

package Rose.Core.Echo_Client is

   procedure Call
     (Endpoint        : Rose.Capabilities.Capability;
      Standard_Output : Rose.Capabilities.Capability;
      New_Line        : Boolean := True;
      Arguments       : Rose.Command_Line.String_List);

end Rose.Core.Echo_Client;
