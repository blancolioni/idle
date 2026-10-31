with Rose.Capabilities;
with Rose.Objects;
with Rose.Server;

package Rose.Interfaces.Flags.Server is

   type Flags_Interface is limited interface
     and Rose.Interfaces.Flags.Flags_Object;

   procedure Attach
     (Server_Context : in out Rose.Server.Server_Context;
      Object         : not null access Flags_Interface'Class);

   procedure Publish
     (Server_Context : in out Rose.Server.Server_Context;
      Object         : not null access Flags_Interface'Class);

   function Interface_Cap
     (Object : not null access Flags_Interface'Class)
      return Rose.Capabilities.Capability;

   function Cap_Of
     (Object       : Flags_Interface'Class;
      Interface_Id : Rose.Objects.Endpoint_Id :=
        Rose.Interfaces.Flags.Flags_Interface)
      return Rose.Capabilities.Capability;

end Rose.Interfaces.Flags.Server;
