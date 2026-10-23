with Rose.Capabilities;
with Rose.Server;
with Rose.Words;

package Rose.Interfaces.Timer.Server is

   type Set_Timer_Handler is access function
     (Id           : Rose.Objects.Capability_Identifier;
      Milliseconds : Rose.Words.Word;
      Cap          : Rose.Capabilities.Capability)
      return Rose.Capabilities.Capability;

   procedure Create_Server
     (Server_Context : in out Rose.Server.Server_Context;
      Set_Timer      : Set_Timer_Handler;
      Instanced      : Boolean := False);

   procedure Attach_Interface
     (Server_Context : in out Rose.Server.Server_Context;
      Set_Timer      : Set_Timer_Handler;
      Instanced      : Boolean := False);

   procedure Publish_Interface
     (Server_Context : in out Rose.Server.Server_Context;
      Set_Timer      : Set_Timer_Handler);

   function Get_Set_Timer_Cap return Rose.Capabilities.Capability;

end Rose.Interfaces.Timer.Server;
