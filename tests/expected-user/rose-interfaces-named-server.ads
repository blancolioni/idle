with Rose.Capabilities;
with Rose.Server;

package Rose.Interfaces.Named.Server is

   type Named_Interface is limited interface
     and Rose.Interfaces.Named.Named_Object;

   procedure Attach
     (Server_Context : in out Rose.Server.Server_Context;
      Object         : not null access Named_Interface'Class);

   procedure Publish
     (Server_Context : in out Rose.Server.Server_Context;
      Object         : not null access Named_Interface'Class);

   function Interface_Cap
     (Object : not null access Named_Interface'Class)
      return Rose.Capabilities.Capability;

end Rose.Interfaces.Named.Server;
