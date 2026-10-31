with Rose.Capabilities;
with Rose.Objects;
with Rose.Server;

package Rose.Interfaces.Boolean_Out.Server is

   type Boolean_Out_Interface is limited interface
     and Rose.Interfaces.Boolean_Out.Boolean_Out_Object;

   procedure Attach
     (Server_Context : in out Rose.Server.Server_Context;
      Object         : not null access Boolean_Out_Interface'Class);

   procedure Publish
     (Server_Context : in out Rose.Server.Server_Context;
      Object         : not null access Boolean_Out_Interface'Class);

   function Interface_Cap
     (Object : not null access Boolean_Out_Interface'Class)
      return Rose.Capabilities.Capability;

   function Cap_Of
     (Object       : Boolean_Out_Interface'Class;
      Interface_Id : Rose.Objects.Endpoint_Id :=
        Rose.Interfaces.Boolean_Out.Boolean_Out_Interface)
      return Rose.Capabilities.Capability;

end Rose.Interfaces.Boolean_Out.Server;
