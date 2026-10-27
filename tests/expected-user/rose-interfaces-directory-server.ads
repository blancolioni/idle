with Rose.Capabilities;
with Rose.Objects;
with Rose.Server;

package Rose.Interfaces.Directory.Server is

   type Directory_Interface is limited interface
     and Rose.Interfaces.Directory.Directory_Object;

   procedure Attach
     (Server_Context : in out Rose.Server.Server_Context;
      Object         : not null access Directory_Interface'Class);

   procedure Publish
     (Server_Context : in out Rose.Server.Server_Context;
      Object         : not null access Directory_Interface'Class);

   function Interface_Cap
     (Object : not null access Directory_Interface'Class)
      return Rose.Capabilities.Capability;

   function Cap_Of
     (Object       : Directory_Interface'Class;
      Interface_Id : Rose.Objects.Endpoint_Id :=
        Rose.Interfaces.Directory.Directory_Interface)
      return Rose.Capabilities.Capability;

end Rose.Interfaces.Directory.Server;
