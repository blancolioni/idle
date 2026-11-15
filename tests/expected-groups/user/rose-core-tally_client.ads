with Rose.Capabilities;

package Rose.Core.Tally_Client is

   procedure Call
     (Endpoint        : Rose.Capabilities.Capability;
      Counter_Service : Rose.Capabilities.Capability;
      Label           : Rose.Capabilities.Capability;
      Source          : Rose.Capabilities.Capability);

end Rose.Core.Tally_Client;
