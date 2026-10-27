with Rose.Capabilities;
with Rose.Objects;
with Rose.Server;

package Rose.Interfaces.Cap.Server is

   type Cap_Interface is limited interface and Rose.Interfaces.Cap.Cap_Object;

   procedure Attach
     (Server_Context : in out Rose.Server.Server_Context;
      Object         : not null access Cap_Interface'Class);

   procedure Publish
     (Server_Context : in out Rose.Server.Server_Context;
      Object         : not null access Cap_Interface'Class);

   function Interface_Cap
     (Object : not null access Cap_Interface'Class)
      return Rose.Capabilities.Capability;

   function Cap_Of
     (Object       : Cap_Interface'Class;
      Interface_Id : Rose.Objects.Endpoint_Id :=
        Rose.Interfaces.Cap.Cap_Interface)
      return Rose.Capabilities.Capability;

end Rose.Interfaces.Cap.Server;
