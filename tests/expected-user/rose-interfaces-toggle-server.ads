with Rose.Capabilities;
with Rose.Objects;
with Rose.Server;

package Rose.Interfaces.Toggle.Server is

   type Toggle_Interface is limited interface
     and Rose.Interfaces.Toggle.Toggle_Object;

   procedure Attach
     (Server_Context : in out Rose.Server.Server_Context;
      Object         : not null access Toggle_Interface'Class);

   procedure Publish
     (Server_Context : in out Rose.Server.Server_Context;
      Object         : not null access Toggle_Interface'Class);

   function Interface_Cap
     (Object : not null access Toggle_Interface'Class)
      return Rose.Capabilities.Capability;

   function Cap_Of
     (Object       : Toggle_Interface'Class;
      Interface_Id : Rose.Objects.Endpoint_Id :=
        Rose.Interfaces.Toggle.Toggle_Interface)
      return Rose.Capabilities.Capability;

end Rose.Interfaces.Toggle.Server;
