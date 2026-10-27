with Rose.Capabilities;
with Rose.Objects;
with Rose.Server;

package Rose.Interfaces.Labelled.Server is

   type Labelled_Interface is limited interface
     and Rose.Interfaces.Labelled.Labelled_Object;

   procedure Attach
     (Server_Context : in out Rose.Server.Server_Context;
      Object         : not null access Labelled_Interface'Class);

   procedure Publish
     (Server_Context : in out Rose.Server.Server_Context;
      Object         : not null access Labelled_Interface'Class);

   function Interface_Cap
     (Object : not null access Labelled_Interface'Class)
      return Rose.Capabilities.Capability;

   function Cap_Of
     (Object       : Labelled_Interface'Class;
      Interface_Id : Rose.Objects.Endpoint_Id :=
        Rose.Interfaces.Labelled.Labelled_Interface)
      return Rose.Capabilities.Capability;

end Rose.Interfaces.Labelled.Server;
