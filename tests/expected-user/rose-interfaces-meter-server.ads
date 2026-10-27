with Rose.Capabilities;
with Rose.Server;

package Rose.Interfaces.Meter.Server is

   type Meter_Interface is limited interface
     and Rose.Interfaces.Meter.Meter_Object;

   procedure Attach
     (Server_Context : in out Rose.Server.Server_Context;
      Object         : not null access Meter_Interface'Class);

   procedure Publish
     (Server_Context : in out Rose.Server.Server_Context;
      Object         : not null access Meter_Interface'Class);

   function Interface_Cap
     (Object : not null access Meter_Interface'Class)
      return Rose.Capabilities.Capability;

end Rose.Interfaces.Meter.Server;
