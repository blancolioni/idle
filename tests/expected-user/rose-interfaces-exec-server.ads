with Rose.Capabilities;
with Rose.Objects;
with Rose.Server;

package Rose.Interfaces.Exec.Server is

   type Exec_Interface is limited interface
     and Rose.Interfaces.Exec.Exec_Object;

   procedure Attach
     (Server_Context : in out Rose.Server.Server_Context;
      Object         : not null access Exec_Interface'Class);

   procedure Publish
     (Server_Context : in out Rose.Server.Server_Context;
      Object         : not null access Exec_Interface'Class);

   function Interface_Cap
     (Object : not null access Exec_Interface'Class)
      return Rose.Capabilities.Capability;

   function Cap_Of
     (Object       : Exec_Interface'Class;
      Interface_Id : Rose.Objects.Endpoint_Id :=
        Rose.Interfaces.Exec.Exec_Interface)
      return Rose.Capabilities.Capability;

end Rose.Interfaces.Exec.Server;
