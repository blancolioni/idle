with Rose.Capabilities;
with Rose.Interfaces.Directory;

procedure Rose.Core.Serve
  (Name   : String;
   Home   : in out Rose.Interfaces.Directory.Directory_Object'Class;
   Result : out Rose.Capabilities.Capability);
