with Rose.Capabilities;
with Rose.Objects;
with Rose.Server;

package Rose.Interfaces.Launch.Server is

   type Launch_Interface is limited interface
     and Rose.Interfaces.Launch.Launch_Object;

   procedure Attach
     (Server_Context : in out Rose.Server.Server_Context;
      Object         : not null access Launch_Interface'Class);

   procedure Publish
     (Server_Context : in out Rose.Server.Server_Context;
      Object         : not null access Launch_Interface'Class);

   function Interface_Cap
     (Object : not null access Launch_Interface'Class)
      return Rose.Capabilities.Capability;

   function Cap_Of
     (Object       : Launch_Interface'Class;
      Interface_Id : Rose.Objects.Endpoint_Id :=
        Rose.Interfaces.Launch.Launch_Interface)
      return Rose.Capabilities.Capability;

end Rose.Interfaces.Launch.Server;
