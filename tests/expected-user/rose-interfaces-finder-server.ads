with Rose.Capabilities;
with Rose.Objects;
with Rose.Server;

package Rose.Interfaces.Finder.Server is

   type Finder_Interface is limited interface
     and Rose.Interfaces.Finder.Finder_Object;

   procedure Attach
     (Server_Context : in out Rose.Server.Server_Context;
      Object         : not null access Finder_Interface'Class;
      Identifier     : Rose.Objects.Capability_Identifier := 0);

   procedure Publish
     (Server_Context : in out Rose.Server.Server_Context;
      Object         : not null access Finder_Interface'Class);

   function Interface_Cap
     (Server_Context : Rose.Server.Server_Context;
      Object         : not null access Finder_Interface'Class)
      return Rose.Capabilities.Capability;

   function Identifier_Of
     (Server_Context : Rose.Server.Server_Context;
      Object         : not null access Finder_Interface'Class)
      return Rose.Objects.Capability_Identifier;

   function Cap_Of
     (Server_Context : Rose.Server.Server_Context;
      Object         : Finder_Interface'Class;
      Interface_Id   : Rose.Objects.Endpoint_Id :=
        Rose.Interfaces.Finder.Finder_Interface)
      return Rose.Capabilities.Capability;

end Rose.Interfaces.Finder.Server;
