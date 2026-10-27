with Rose.Capabilities;
with Rose.Server;

package Rose.Interfaces.Cap_Set.Server is

   type Cap_Set_Interface is limited interface
     and Rose.Interfaces.Cap_Set.Cap_Set_Object;

   procedure Attach
     (Server_Context : in out Rose.Server.Server_Context;
      Object         : not null access Cap_Set_Interface'Class);

   procedure Publish
     (Server_Context : in out Rose.Server.Server_Context;
      Object         : not null access Cap_Set_Interface'Class);

   function Interface_Cap
     (Object : not null access Cap_Set_Interface'Class)
      return Rose.Capabilities.Capability;

end Rose.Interfaces.Cap_Set.Server;
