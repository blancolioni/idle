with Rose.Capabilities;
with Rose.Objects;
with Rose.Server;

package Rose.Interfaces.Seekable_File_Reader.Server is

   type Seekable_File_Reader_Interface is limited interface
     and Rose.Interfaces.Seekable_File_Reader.Seekable_File_Reader_Object;

   procedure Attach
     (Server_Context : in out Rose.Server.Server_Context;
      Object         : not null access Seekable_File_Reader_Interface'Class);

   procedure Publish
     (Server_Context : in out Rose.Server.Server_Context;
      Object         : not null access Seekable_File_Reader_Interface'Class);

   function Interface_Cap
     (Object : not null access Seekable_File_Reader_Interface'Class)
      return Rose.Capabilities.Capability;

   function Cap_Of
     (Object       : Seekable_File_Reader_Interface'Class;
      Interface_Id : Rose.Objects.Endpoint_Id :=
        Rose.Interfaces.Seekable_File_Reader.Seekable_File_Reader_Interface)
      return Rose.Capabilities.Capability;

end Rose.Interfaces.Seekable_File_Reader.Server;
