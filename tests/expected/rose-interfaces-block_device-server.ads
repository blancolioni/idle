with Rose.Capabilities;
with Rose.Objects;
with Rose.Server;
with System.Storage_Elements;

package Rose.Interfaces.Block_Device.Server is

   type Get_Parameters_Handler is access procedure
     (Id          : Rose.Objects.Capability_Identifier;
      Block_Count : out Rose.Interfaces.Block_Device.Block_Address_Type;
      Block_Size  : out Rose.Interfaces.Block_Device.Block_Size_Type);

   type Read_Blocks_Handler is access procedure
     (Id     : Rose.Objects.Capability_Identifier;
      Start  : Rose.Interfaces.Block_Device.Block_Address_Type;
      Count  : Natural;
      Blocks : out System.Storage_Elements.Storage_Array);

   type Write_Blocks_Handler is access procedure
     (Id     : Rose.Objects.Capability_Identifier;
      Start  : Rose.Interfaces.Block_Device.Block_Address_Type;
      Count  : Natural;
      Blocks : System.Storage_Elements.Storage_Array);

   procedure Create_Server
     (Server_Context : in out Rose.Server.Server_Context;
      Get_Parameters : Get_Parameters_Handler;
      Read_Blocks    : Read_Blocks_Handler;
      Write_Blocks   : Write_Blocks_Handler;
      Instanced      : Boolean := False);

   procedure Attach_Interface
     (Server_Context : in out Rose.Server.Server_Context;
      Get_Parameters : Get_Parameters_Handler;
      Read_Blocks    : Read_Blocks_Handler;
      Write_Blocks   : Write_Blocks_Handler;
      Instanced      : Boolean := False);

   procedure Publish_Interface
     (Server_Context : in out Rose.Server.Server_Context;
      Get_Parameters : Get_Parameters_Handler;
      Read_Blocks    : Read_Blocks_Handler;
      Write_Blocks   : Write_Blocks_Handler);

   function Get_Get_Parameters_Cap return Rose.Capabilities.Capability;

   function Get_Read_Blocks_Cap return Rose.Capabilities.Capability;

   function Get_Write_Blocks_Cap return Rose.Capabilities.Capability;

   procedure Remove_Instance (Identifier : Rose.Objects.Capability_Identifier);

end Rose.Interfaces.Block_Device.Server;
