with Rose.Capabilities;
with Rose.Objects;
with Rose.Server;

package Rose.Interfaces.Items.Server is

   type Items_Interface is limited interface
     and Rose.Interfaces.Items.Items_Object;

   procedure Attach
     (Server_Context : in out Rose.Server.Server_Context;
      Object         : not null access Items_Interface'Class);

   procedure Publish
     (Server_Context : in out Rose.Server.Server_Context;
      Object         : not null access Items_Interface'Class);

   function Interface_Cap
     (Object : not null access Items_Interface'Class)
      return Rose.Capabilities.Capability;

   function Cap_Of
     (Object       : Items_Interface'Class;
      Interface_Id : Rose.Objects.Endpoint_Id :=
        Rose.Interfaces.Items.Items_Interface)
      return Rose.Capabilities.Capability;

end Rose.Interfaces.Items.Server;
