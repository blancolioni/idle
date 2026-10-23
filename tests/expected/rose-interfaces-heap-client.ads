with Rose.Capabilities;
with Rose.Invocation;
with Rose.Words;

package Rose.Interfaces.Heap.Client is

   type Heap_Client is private;

   procedure Open_Cap_Set
     (Client            : out Heap_Client;
      Current_Bound     : Rose.Capabilities.Capability;
      Request_New_Bound : Rose.Capabilities.Capability);

   procedure Open
     (Client        : out Heap_Client;
      Interface_Cap : Rose.Capabilities.Capability);

   procedure Close (Client : in out Heap_Client);

   function Current_Bound (Item : Heap_Client) return Rose.Words.Word;

   procedure Request_New_Bound
     (Item      : Heap_Client;
      New_Bound : Rose.Words.Word);

   function Get_Interface_Cap
     (Item : Heap_Client)
      return Rose.Capabilities.Capability;

   function Get_Current_Bound_Cap
     (Item : Heap_Client)
      return Rose.Capabilities.Capability;

   function Get_Request_New_Bound_Cap
     (Item : Heap_Client)
      return Rose.Capabilities.Capability;

   function Has_Error return Boolean;

   function Get_Last_Error return Rose.Invocation.Invocation_Error;

private

   type Heap_Client is record
      Is_Open           : Boolean := False;
      Interface_Cap     : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
      Current_Bound     : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
      Request_New_Bound : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
   end record;

end Rose.Interfaces.Heap.Client;
