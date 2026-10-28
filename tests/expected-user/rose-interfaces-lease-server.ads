with Rose.Capabilities;
with Rose.Objects;
with Rose.Server;

package Rose.Interfaces.Lease.Server is

   type Lease_Interface is limited interface
     and Rose.Interfaces.Lease.Lease_Object;

   procedure Attach
     (Server_Context : in out Rose.Server.Server_Context;
      Object         : not null access Lease_Interface'Class);

   procedure Publish
     (Server_Context : in out Rose.Server.Server_Context;
      Object         : not null access Lease_Interface'Class);

   function Interface_Cap
     (Object : not null access Lease_Interface'Class)
      return Rose.Capabilities.Capability;

   function Cap_Of
     (Object       : Lease_Interface'Class;
      Interface_Id : Rose.Objects.Endpoint_Id :=
        Rose.Interfaces.Lease.Lease_Interface)
      return Rose.Capabilities.Capability;

end Rose.Interfaces.Lease.Server;
