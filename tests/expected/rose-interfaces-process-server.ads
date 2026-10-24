with Rose.Capabilities;
with Rose.Objects;
with Rose.Server;
with Rose.Words;

package Rose.Interfaces.Process.Server is

   type Add_Segment_Handler is access procedure
     (Id            : Rose.Objects.Capability_Identifier;
      Virtual_Base  : Rose.Words.Word;
      Virtual_Bound : Rose.Words.Word;
      Region        : Rose.Capabilities.Capability;
      Region_Offset : Rose.Words.Word;
      Flags         : Rose.Words.Word);

   type Add_Nonpersistent_Segment_Handler is access procedure
     (Id            : Rose.Objects.Capability_Identifier;
      Virtual_Base  : Rose.Words.Word;
      Virtual_Bound : Rose.Words.Word;
      Flags         : Rose.Words.Word);

   type Published_Interface_Handler is access function
     (Id : Rose.Objects.Capability_Identifier)
      return Rose.Capabilities.Capability;

   type Destroy_Handler is access procedure
     (Id : Rose.Objects.Capability_Identifier);

   type Get_Object_Id_Handler is access function
     (Id : Rose.Objects.Capability_Identifier)
      return Rose.Objects.Object_Id;

   type Heap_Interface_Handler is access function
     (Id : Rose.Objects.Capability_Identifier)
      return Rose.Capabilities.Capability;

   type Exit_Process_Handler is access procedure
     (Id          : Rose.Objects.Capability_Identifier;
      Exit_Status : Natural);

   type Publish_Interface_Handler is access procedure
     (Id            : Rose.Objects.Capability_Identifier;
      Interface_Cap : Rose.Capabilities.Capability);

   procedure Create_Server
     (Server_Context            : in out Rose.Server.Server_Context;
      Add_Segment               : Add_Segment_Handler;
      Add_Nonpersistent_Segment : Add_Nonpersistent_Segment_Handler;
      Published_Interface       : Published_Interface_Handler;
      Destroy                   : Destroy_Handler;
      Get_Object_Id             : Get_Object_Id_Handler;
      Heap_Interface            : Heap_Interface_Handler;
      Exit_Process              : Exit_Process_Handler;
      Publish_Interface         : Publish_Interface_Handler;
      Instanced                 : Boolean := False);

   procedure Attach_Interface
     (Server_Context            : in out Rose.Server.Server_Context;
      Add_Segment               : Add_Segment_Handler;
      Add_Nonpersistent_Segment : Add_Nonpersistent_Segment_Handler;
      Published_Interface       : Published_Interface_Handler;
      Destroy                   : Destroy_Handler;
      Get_Object_Id             : Get_Object_Id_Handler;
      Heap_Interface            : Heap_Interface_Handler;
      Exit_Process              : Exit_Process_Handler;
      Publish_Interface         : Publish_Interface_Handler;
      Instanced                 : Boolean := False);

   procedure Publish_Interface
     (Server_Context            : in out Rose.Server.Server_Context;
      Add_Segment               : Add_Segment_Handler;
      Add_Nonpersistent_Segment : Add_Nonpersistent_Segment_Handler;
      Published_Interface       : Published_Interface_Handler;
      Destroy                   : Destroy_Handler;
      Get_Object_Id             : Get_Object_Id_Handler;
      Heap_Interface            : Heap_Interface_Handler;
      Exit_Process              : Exit_Process_Handler;
      Publish_Interface         : Publish_Interface_Handler);

   function Get_Add_Segment_Cap return Rose.Capabilities.Capability;

   function Get_Add_Nonpersistent_Segment_Cap
      return Rose.Capabilities.Capability;

   function Get_Published_Interface_Cap return Rose.Capabilities.Capability;

   function Get_Destroy_Cap return Rose.Capabilities.Capability;

   function Get_Get_Object_Id_Cap return Rose.Capabilities.Capability;

   function Get_Heap_Interface_Cap return Rose.Capabilities.Capability;

   function Get_Exit_Process_Cap return Rose.Capabilities.Capability;

   function Get_Publish_Interface_Cap return Rose.Capabilities.Capability;

end Rose.Interfaces.Process.Server;
