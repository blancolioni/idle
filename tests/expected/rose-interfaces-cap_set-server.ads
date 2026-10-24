with Rose.Capabilities;
with Rose.Server;

package Rose.Interfaces.Cap_Set.Server is

   type Append_Handler is access procedure
     (Id   : Rose.Objects.Capability_Identifier;
      Caps : Rose.Capabilities.Capability_Array);

   type Get_Cap_Handler is access function
     (Id    : Rose.Objects.Capability_Identifier;
      Index : Positive)
      return Rose.Capabilities.Capability;

   type Length_Handler is access function
     (Id : Rose.Objects.Capability_Identifier)
      return Natural;

   procedure Create_Server
     (Server_Context : in out Rose.Server.Server_Context;
      Append         : Append_Handler;
      Get_Cap        : Get_Cap_Handler;
      Length         : Length_Handler;
      Instanced      : Boolean := False);

   procedure Attach_Interface
     (Server_Context : in out Rose.Server.Server_Context;
      Append         : Append_Handler;
      Get_Cap        : Get_Cap_Handler;
      Length         : Length_Handler;
      Instanced      : Boolean := False);

   procedure Publish_Interface
     (Server_Context : in out Rose.Server.Server_Context;
      Append         : Append_Handler;
      Get_Cap        : Get_Cap_Handler;
      Length         : Length_Handler);

   function Get_Append_Cap return Rose.Capabilities.Capability;

   function Get_Get_Cap_Cap return Rose.Capabilities.Capability;

   function Get_Length_Cap return Rose.Capabilities.Capability;

end Rose.Interfaces.Cap_Set.Server;
