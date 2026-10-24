with Rose.Capabilities;
with Rose.Objects;
with Rose.Server;
with Rose.Words;

package Rose.Interfaces.Heap.Server is

   type Current_Bound_Handler is access function
     (Id : Rose.Objects.Capability_Identifier)
      return Rose.Words.Word;

   type Request_New_Bound_Handler is access procedure
     (Id        : Rose.Objects.Capability_Identifier;
      New_Bound : Rose.Words.Word);

   procedure Create_Server
     (Server_Context    : in out Rose.Server.Server_Context;
      Current_Bound     : Current_Bound_Handler;
      Request_New_Bound : Request_New_Bound_Handler;
      Instanced         : Boolean := False);

   procedure Attach_Interface
     (Server_Context    : in out Rose.Server.Server_Context;
      Current_Bound     : Current_Bound_Handler;
      Request_New_Bound : Request_New_Bound_Handler;
      Instanced         : Boolean := False);

   procedure Publish_Interface
     (Server_Context    : in out Rose.Server.Server_Context;
      Current_Bound     : Current_Bound_Handler;
      Request_New_Bound : Request_New_Bound_Handler);

   function Get_Current_Bound_Cap return Rose.Capabilities.Capability;

   function Get_Request_New_Bound_Cap return Rose.Capabilities.Capability;

   procedure Remove_Instance (Identifier : Rose.Objects.Capability_Identifier);

end Rose.Interfaces.Heap.Server;
