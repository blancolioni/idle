with Rose.Capabilities;
with Rose.Command_Line;

package Rose.Core.Touch_Client is

   procedure Call
     (Endpoint  : Rose.Capabilities.Capability;
      Name      : String;
      Directory : Rose.Capabilities.Capability);

end Rose.Core.Touch_Client;
