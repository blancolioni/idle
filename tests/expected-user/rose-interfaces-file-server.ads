with Rose.Capabilities;
with Rose.Objects;
with Rose.Server;

package Rose.Interfaces.File.Server is

   type File_Interface is limited interface
     and Rose.Interfaces.File.File_Object;

   procedure Attach
     (Server_Context : in out Rose.Server.Server_Context;
      Object         : not null access File_Interface'Class);

   procedure Publish
     (Server_Context : in out Rose.Server.Server_Context;
      Object         : not null access File_Interface'Class);

   function Interface_Cap
     (Object : not null access File_Interface'Class)
      return Rose.Capabilities.Capability;

   function Cap_Of
     (Object       : File_Interface'Class;
      Interface_Id : Rose.Objects.Endpoint_Id :=
        Rose.Interfaces.File.File_Interface)
      return Rose.Capabilities.Capability;

end Rose.Interfaces.File.Server;
