with Rose.Capabilities;

package Rose.Core.Serve_Client is

   procedure Call
     (Endpoint        : Rose.Capabilities.Capability;
      Create_Endpoint : Rose.Capabilities.Capability;
      Name            : String;
      Home            : Rose.Capabilities.Capability;
      Result          : out Rose.Capabilities.Capability);

end Rose.Core.Serve_Client;
