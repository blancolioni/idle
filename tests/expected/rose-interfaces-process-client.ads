with Rose.Capabilities;
with Rose.Interfaces.Heap.Client;
with Rose.Interfaces.Region.Client;
with Rose.Invocation;
with Rose.Objects;
with Rose.Words;

package Rose.Interfaces.Process.Client is

   type Process_Client is private;

   procedure Open_Cap_Set
     (Client                    : out Process_Client;
      Add_Segment               : Rose.Capabilities.Capability;
      Add_Nonpersistent_Segment : Rose.Capabilities.Capability;
      Published_Interface       : Rose.Capabilities.Capability;
      Destroy                   : Rose.Capabilities.Capability;
      Get_Object_Id             : Rose.Capabilities.Capability;
      Heap_Interface            : Rose.Capabilities.Capability;
      Exit_Process              : Rose.Capabilities.Capability;
      Publish_Interface         : Rose.Capabilities.Capability);

   procedure Open
     (Client        : out Process_Client;
      Interface_Cap : Rose.Capabilities.Capability);

   procedure Close (Client : in out Process_Client);

   procedure Add_Segment
     (Item          : Process_Client;
      Virtual_Base  : Rose.Words.Word;
      Virtual_Bound : Rose.Words.Word;
      Region        : Rose.Interfaces.Region.Client.Region_Client;
      Region_Offset : Rose.Words.Word;
      Flags         : Rose.Words.Word);

   procedure Add_Nonpersistent_Segment
     (Item          : Process_Client;
      Virtual_Base  : Rose.Words.Word;
      Virtual_Bound : Rose.Words.Word;
      Flags         : Rose.Words.Word);

   function Published_Interface
     (Item : Process_Client)
      return Rose.Capabilities.Capability;

   procedure Destroy (Item : Process_Client);

   function Get_Object_Id
     (Item : Process_Client)
      return Rose.Objects.Object_Id;

   function Heap_Interface
     (Item : Process_Client)
      return Rose.Interfaces.Heap.Client.Heap_Client;

   procedure Exit_Process (Item : Process_Client; Exit_Status : Natural);

   procedure Publish_Interface
     (Item          : Process_Client;
      Interface_Cap : Rose.Capabilities.Capability);

   function Get_Interface_Cap
     (Item : Process_Client)
      return Rose.Capabilities.Capability;

   function Get_Add_Segment_Cap
     (Item : Process_Client)
      return Rose.Capabilities.Capability;

   function Get_Add_Nonpersistent_Segment_Cap
     (Item : Process_Client)
      return Rose.Capabilities.Capability;

   function Get_Published_Interface_Cap
     (Item : Process_Client)
      return Rose.Capabilities.Capability;

   function Get_Destroy_Cap
     (Item : Process_Client)
      return Rose.Capabilities.Capability;

   function Get_Get_Object_Id_Cap
     (Item : Process_Client)
      return Rose.Capabilities.Capability;

   function Get_Heap_Interface_Cap
     (Item : Process_Client)
      return Rose.Capabilities.Capability;

   function Get_Exit_Process_Cap
     (Item : Process_Client)
      return Rose.Capabilities.Capability;

   function Get_Publish_Interface_Cap
     (Item : Process_Client)
      return Rose.Capabilities.Capability;

   function Has_Error return Boolean;

   function Get_Last_Error return Rose.Invocation.Invocation_Error;

private

   type Process_Client is record
      Is_Open                   : Boolean := False;
      Interface_Cap             : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
      Add_Segment               : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
      Add_Nonpersistent_Segment : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
      Published_Interface       : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
      Destroy                   : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
      Get_Object_Id             : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
      Heap_Interface            : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
      Exit_Process              : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
      Publish_Interface         : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
   end record;

end Rose.Interfaces.Process.Client;
