with Rose.Capabilities;
with Rose.Objects;
with Rose.Server;
with Rose.Words;
with System.Storage_Elements;

package Rose.Interfaces.Seekable_File_Reader.Server is

   type Read_Handler is access procedure
     (Id     : Rose.Objects.Capability_Identifier;
      Buffer : out System.Storage_Elements.Storage_Array;
      Last   : out System.Storage_Elements.Storage_Count);

   type Release_Handler is access procedure
     (Id : Rose.Objects.Capability_Identifier);

   type Seek_Handler is access procedure
     (Id                : Rose.Objects.Capability_Identifier;
      Offset_From_Start : Rose.Words.Word_64);

   procedure Create_Server
     (Server_Context : in out Rose.Server.Server_Context;
      Read           : Read_Handler;
      Release        : Release_Handler;
      Seek           : Seek_Handler;
      Instanced      : Boolean := False);

   procedure Attach_Interface
     (Server_Context : in out Rose.Server.Server_Context;
      Read           : Read_Handler;
      Release        : Release_Handler;
      Seek           : Seek_Handler;
      Instanced      : Boolean := False);

   procedure Publish_Interface
     (Server_Context : in out Rose.Server.Server_Context;
      Read           : Read_Handler;
      Release        : Release_Handler;
      Seek           : Seek_Handler);

   function Get_Read_Cap return Rose.Capabilities.Capability;

   function Get_Release_Cap return Rose.Capabilities.Capability;

   function Get_Seek_Cap return Rose.Capabilities.Capability;

   procedure Remove_Instance (Identifier : Rose.Objects.Capability_Identifier);

end Rose.Interfaces.Seekable_File_Reader.Server;
