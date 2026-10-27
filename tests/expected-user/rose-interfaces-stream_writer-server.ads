with Rose.Capabilities;
with Rose.Server;

package Rose.Interfaces.Stream_Writer.Server is

   type Stream_Writer_Interface is limited interface
     and Rose.Interfaces.Stream_Writer.Stream_Writer_Object;

   procedure Attach
     (Server_Context : in out Rose.Server.Server_Context;
      Object         : not null access Stream_Writer_Interface'Class);

   procedure Publish
     (Server_Context : in out Rose.Server.Server_Context;
      Object         : not null access Stream_Writer_Interface'Class);

   function Interface_Cap
     (Object : not null access Stream_Writer_Interface'Class)
      return Rose.Capabilities.Capability;

end Rose.Interfaces.Stream_Writer.Server;
