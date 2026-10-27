with Rose.Capabilities;
with Rose.Objects;
with Rose.Server;

package Rose.Interfaces.Gauge.Server is

   type Gauge_Interface is limited interface
     and Rose.Interfaces.Gauge.Gauge_Object;

   procedure Attach
     (Server_Context : in out Rose.Server.Server_Context;
      Object         : not null access Gauge_Interface'Class);

   procedure Publish
     (Server_Context : in out Rose.Server.Server_Context;
      Object         : not null access Gauge_Interface'Class);

   function Interface_Cap
     (Object : not null access Gauge_Interface'Class)
      return Rose.Capabilities.Capability;

   function Cap_Of
     (Object       : Gauge_Interface'Class;
      Interface_Id : Rose.Objects.Endpoint_Id :=
        Rose.Interfaces.Gauge.Gauge_Interface)
      return Rose.Capabilities.Capability;

end Rose.Interfaces.Gauge.Server;
