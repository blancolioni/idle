with Rose.Capabilities;
with Rose.Server;

package Rose.Interfaces.Seekable.Server is

   type Seekable_Interface is limited interface
     and Rose.Interfaces.Seekable.Seekable_Object;

   procedure Attach
     (Server_Context : in out Rose.Server.Server_Context;
      Object         : not null access Seekable_Interface'Class);

   procedure Publish
     (Server_Context : in out Rose.Server.Server_Context;
      Object         : not null access Seekable_Interface'Class);

   function Interface_Cap
     (Object : not null access Seekable_Interface'Class)
      return Rose.Capabilities.Capability;

end Rose.Interfaces.Seekable.Server;
