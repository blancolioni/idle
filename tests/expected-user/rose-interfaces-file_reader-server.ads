with Rose.Capabilities;
with Rose.Objects;
with Rose.Server;

package Rose.Interfaces.File_Reader.Server is

   type File_Reader_Interface is limited interface
     and Rose.Interfaces.File_Reader.File_Reader_Object;

   procedure Attach
     (Server_Context : in out Rose.Server.Server_Context;
      Object         : not null access File_Reader_Interface'Class);

   procedure Publish
     (Server_Context : in out Rose.Server.Server_Context;
      Object         : not null access File_Reader_Interface'Class);

   function Interface_Cap
     (Object : not null access File_Reader_Interface'Class)
      return Rose.Capabilities.Capability;

   function Cap_Of
     (Object       : File_Reader_Interface'Class;
      Interface_Id : Rose.Objects.Endpoint_Id :=
        Rose.Interfaces.File_Reader.File_Reader_Interface)
      return Rose.Capabilities.Capability;

end Rose.Interfaces.File_Reader.Server;
