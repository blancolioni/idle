with Rose.Capabilities;
with Rose.Objects;
with Rose.Server;

package Rose.Interfaces.Editor.Server is

   type Editor_Interface is limited interface
     and Rose.Interfaces.Editor.Editor_Object;

   procedure Attach
     (Server_Context : in out Rose.Server.Server_Context;
      Object         : not null access Editor_Interface'Class;
      Identifier     : Rose.Objects.Capability_Identifier := 0);

   procedure Publish
     (Server_Context : in out Rose.Server.Server_Context;
      Object         : not null access Editor_Interface'Class);

   function Interface_Cap
     (Server_Context : Rose.Server.Server_Context;
      Object         : not null access Editor_Interface'Class)
      return Rose.Capabilities.Capability;

   function Identifier_Of
     (Server_Context : Rose.Server.Server_Context;
      Object         : not null access Editor_Interface'Class)
      return Rose.Objects.Capability_Identifier;

   function Cap_Of
     (Server_Context : Rose.Server.Server_Context;
      Object         : Editor_Interface'Class;
      Interface_Id   : Rose.Objects.Endpoint_Id :=
        Rose.Interfaces.Editor.Editor_Interface)
      return Rose.Capabilities.Capability;

end Rose.Interfaces.Editor.Server;
