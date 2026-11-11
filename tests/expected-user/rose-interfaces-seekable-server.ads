with Rose.Capabilities;
with Rose.Objects;
with Rose.Server;

package Rose.Interfaces.Seekable.Server is

   type Seekable_Interface is limited interface
     and Rose.Interfaces.Seekable.Seekable_Object;

   procedure Attach
     (Server_Context : in out Rose.Server.Server_Context;
      Object         : not null access Seekable_Interface'Class;
      Identifier     : Rose.Objects.Capability_Identifier := 0);

   procedure Publish
     (Server_Context : in out Rose.Server.Server_Context;
      Object         : not null access Seekable_Interface'Class);

   function Interface_Cap
     (Object : not null access Seekable_Interface'Class)
      return Rose.Capabilities.Capability;

   function Identifier_Of
     (Object : not null access Seekable_Interface'Class)
      return Rose.Objects.Capability_Identifier;

   function Cap_Of
     (Object       : Seekable_Interface'Class;
      Interface_Id : Rose.Objects.Endpoint_Id :=
        Rose.Interfaces.Seekable.Seekable_Interface)
      return Rose.Capabilities.Capability;

end Rose.Interfaces.Seekable.Server;
