with Rose.Capabilities;
with Rose.Objects;
with Rose.Server;
with System.Storage_Elements;

package Rose.Interfaces.Stream_Writer.Server is

   type Write_Handler is access procedure
     (Id     : Rose.Objects.Capability_Identifier;
      Buffer : System.Storage_Elements.Storage_Array);

   procedure Create_Server
     (Server_Context : in out Rose.Server.Server_Context;
      Write          : Write_Handler;
      Instanced      : Boolean := False);

   procedure Attach_Interface
     (Server_Context : in out Rose.Server.Server_Context;
      Write          : Write_Handler;
      Instanced      : Boolean := False);

   procedure Publish_Interface
     (Server_Context : in out Rose.Server.Server_Context;
      Write          : Write_Handler);

   function Get_Write_Cap return Rose.Capabilities.Capability;

   procedure Remove_Instance (Identifier : Rose.Objects.Capability_Identifier);

end Rose.Interfaces.Stream_Writer.Server;
