with Rose.Capabilities;
with Rose.Objects;
with Rose.Server;

package Rose.Interfaces.Exchange.Server is

   type Exchange_Interface is limited interface
     and Rose.Interfaces.Exchange.Exchange_Object;

   procedure Attach
     (Server_Context : in out Rose.Server.Server_Context;
      Object         : not null access Exchange_Interface'Class);

   procedure Publish
     (Server_Context : in out Rose.Server.Server_Context;
      Object         : not null access Exchange_Interface'Class);

   function Interface_Cap
     (Object : not null access Exchange_Interface'Class)
      return Rose.Capabilities.Capability;

   function Cap_Of
     (Object       : Exchange_Interface'Class;
      Interface_Id : Rose.Objects.Endpoint_Id :=
        Rose.Interfaces.Exchange.Exchange_Interface)
      return Rose.Capabilities.Capability;

end Rose.Interfaces.Exchange.Server;
