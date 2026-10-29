with Rose.Capabilities;
with Rose.Words;
with System.Storage_Elements;

package Rose.Interfaces.Items.Client is

   type Items_Client is
     limited new Rose.Interfaces.Items.Items_Object
     with private;

   procedure Open_Cap_Set
     (Client : out Items_Client;
      Pair   : Rose.Capabilities.Capability;
      Store  : Rose.Capabilities.Capability;
      Single : Rose.Capabilities.Capability);

   procedure Open
     (Client        : out Items_Client;
      Interface_Cap : Rose.Capabilities.Capability);

   function From_Cap (Cap : Rose.Capabilities.Capability) return Items_Client;

   procedure Close (Client : in out Items_Client);

   overriding function Pair
     (Item     : in out Items_Client;
      Name     : String;
      Password : String)
      return Rose.Capabilities.Capability;

   overriding procedure Store
     (Item  : in out Items_Client;
      Index : Rose.Words.Word;
      Key   : String;
      Data  : System.Storage_Elements.Storage_Array;
      Owner : Rose.Capabilities.Capability);

   overriding procedure Single (Item : in out Items_Client; Name : String);

   overriding function Items_Cap
     (Item : in out Items_Client)
      return Rose.Capabilities.Capability;

   function Get_Interface_Cap
     (Item : Items_Client)
      return Rose.Capabilities.Capability;

   function Get_Pair_Cap
     (Item : in out Items_Client)
      return Rose.Capabilities.Capability;

   function Get_Store_Cap
     (Item : in out Items_Client)
      return Rose.Capabilities.Capability;

   function Get_Single_Cap
     (Item : in out Items_Client)
      return Rose.Capabilities.Capability;

private

   type Items_Client is
     limited new Rose.Interfaces.Items.Items_Object
   with record
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
