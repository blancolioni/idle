with Rose.Capabilities;
with Rose.Server;
with System.Storage_Elements;

package Rose.Interfaces.Stream_Reader.Server is

   type Read_Handler is access procedure
     (Id     : Rose.Objects.Capability_Identifier;
      Buffer : out System.Storage_Elements.Storage_Array;
      Last   : out System.Storage_Elements.Storage_Count);

   procedure Create_Server
     (Server_Context : in out Rose.Server.Server_Context;
      Read           : Read_Handler;
      Instanced      : Boolean := False);

   procedure Attach_Interface
     (Server_Context : in out Rose.Server.Server_Context;
      Read           : Read_Handler;
      Instanced      : Boolean := False);

   procedure Publish_Interface
     (Server_Context : in out Rose.Server.Server_Context;
      Read           : Read_Handler);

   function Get_Read_Cap return Rose.Capabilities.Capability;

end Rose.Interfaces.Stream_Reader.Server;
