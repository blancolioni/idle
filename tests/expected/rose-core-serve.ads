with Rose.Capabilities;
with Rose.Interfaces.Directory.Client;

procedure Rose.Core.Serve
  (Name   : String;
   Home   : Rose.Interfaces.Directory.Client.Directory_Client;
   Result : out Rose.Capabilities.Capability);
