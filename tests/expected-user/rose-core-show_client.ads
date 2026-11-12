with Rose.Capabilities;

package Rose.Core.Show_Client is

   procedure Call
     (Endpoint        : Rose.Capabilities.Capability;
      Standard_Output : Rose.Capabilities.Capability;
      Logging         : Rose.Capabilities.Capability;
      Delete_Cap      : Rose.Capabilities.Capability;
      Source          : Rose.Capabilities.Capability;
      Count           : out Natural;
      Input           : Rose.Capabilities.Capability);

end Rose.Core.Show_Client;
