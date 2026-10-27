with Rose.Capabilities;
with Rose.Server;

package Rose.Interfaces.Restorable.Server is

   type Restorable_Interface is limited interface
     and Rose.Interfaces.Restorable.Restorable_Object;

   procedure Attach
     (Server_Context : in out Rose.Server.Server_Context;
      Object         : not null access Restorable_Interface'Class);

   procedure Publish
     (Server_Context : in out Rose.Server.Server_Context;
      Object         : not null access Restorable_Interface'Class);

   function Interface_Cap
     (Object : not null access Restorable_Interface'Class)
      return Rose.Capabilities.Capability;

end Rose.Interfaces.Restorable.Server;
