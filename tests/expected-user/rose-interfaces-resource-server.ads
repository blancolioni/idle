with Rose.Capabilities;
with Rose.Objects;
with Rose.Server;

package Rose.Interfaces.Resource.Server is

   type Resource_Interface is limited interface
     and Rose.Interfaces.Resource.Resource_Object;

   procedure Attach
     (Server_Context : in out Rose.Server.Server_Context;
      Object         : not null access Resource_Interface'Class);

   procedure Publish
     (Server_Context : in out Rose.Server.Server_Context;
      Object         : not null access Resource_Interface'Class);

   function Interface_Cap
     (Object : not null access Resource_Interface'Class)
      return Rose.Capabilities.Capability;

   function Cap_Of
     (Object       : Resource_Interface'Class;
      Interface_Id : Rose.Objects.Endpoint_Id :=
        Rose.Interfaces.Resource.Resource_Interface)
      return Rose.Capabilities.Capability;

end Rose.Interfaces.Resource.Server;
