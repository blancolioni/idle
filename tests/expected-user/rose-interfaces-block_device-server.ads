with Rose.Capabilities;
with Rose.Objects;
with Rose.Server;

package Rose.Interfaces.Block_Device.Server is

   type Block_Device_Interface is limited interface
     and Rose.Interfaces.Block_Device.Block_Device_Object;

   procedure Attach
     (Server_Context : in out Rose.Server.Server_Context;
      Object         : not null access Block_Device_Interface'Class);

   procedure Publish
     (Server_Context : in out Rose.Server.Server_Context;
      Object         : not null access Block_Device_Interface'Class);

   function Interface_Cap
     (Object : not null access Block_Device_Interface'Class)
      return Rose.Capabilities.Capability;

   function Cap_Of
     (Object       : Block_Device_Interface'Class;
      Interface_Id : Rose.Objects.Endpoint_Id :=
        Rose.Interfaces.Block_Device.Block_Device_Interface)
      return Rose.Capabilities.Capability;

end Rose.Interfaces.Block_Device.Server;
