with Rose.Capabilities;
with Rose.Objects;
with Rose.Server;

package Rose.Interfaces.Timer.Server is

   type Timer_Interface is limited interface
     and Rose.Interfaces.Timer.Timer_Object;

   procedure Attach
     (Server_Context : in out Rose.Server.Server_Context;
      Object         : not null access Timer_Interface'Class);

   procedure Publish
     (Server_Context : in out Rose.Server.Server_Context;
      Object         : not null access Timer_Interface'Class);

   function Interface_Cap
     (Object : not null access Timer_Interface'Class)
      return Rose.Capabilities.Capability;

   function Cap_Of
     (Object       : Timer_Interface'Class;
      Interface_Id : Rose.Objects.Endpoint_Id :=
        Rose.Interfaces.Timer.Timer_Interface)
      return Rose.Capabilities.Capability;

end Rose.Interfaces.Timer.Server;
