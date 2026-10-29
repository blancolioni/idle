with Rose.Capabilities;
with Rose.Invocation;
with Rose.Words;
with System.Storage_Elements;

package Rose.Interfaces.Items.Client is

   type Items_Client is private;

   procedure Open_Cap_Set
     (Client : out Items_Client;
      Pair   : Rose.Capabilities.Capability;
      Store  : Rose.Capabilities.Capability;
      Single : Rose.Capabilities.Capability);

   procedure Open
     (Client        : out Items_Client;
      Interface_Cap : Rose.Capabilities.Capability);

   procedure Close (Client : in out Items_Client);

   function Pair
     (Item     : Items_Client;
      Name     : String;
      Password : String)
      return Rose.Capabilities.Capability;

   procedure Store
     (Item  : Items_Client;
      Index : Rose.Words.Word;
      Key   : String;
      Data  : System.Storage_Elements.Storage_Array;
      Owner : Rose.Capabilities.Capability);

   procedure Single (Item : Items_Client; Name : String);

   function Get_Interface_Cap
     (Item : Items_Client)
      return Rose.Capabilities.Capability;

   function Get_Pair_Cap
     (Item : Items_Client)
      return Rose.Capabilities.Capability;

   function Get_Store_Cap
     (Item : Items_Client)
      return Rose.Capabilities.Capability;

   function Get_Single_Cap
     (Item : Items_Client)
      return Rose.Capabilities.Capability;

   function Has_Error return Boolean;

   function Get_Last_Error return Rose.Invocation.Invocation_Error;

private

   type Items_Client is record
      Is_Open       : Boolean := False;
      Interface_Cap : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
      Pair          : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
      Store         : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
      Single        : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
   end record;

end Rose.Interfaces.Items.Client;
