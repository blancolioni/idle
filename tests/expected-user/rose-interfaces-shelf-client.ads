with Rose.Capabilities;

package Rose.Interfaces.Shelf.Client is

   type Shelf_Client is
     limited new Rose.Interfaces.Shelf.Shelf_Object
     with private;

   procedure Open_Cap_Set
     (Client  : out Shelf_Client;
      Put     : Rose.Capabilities.Capability;
      Get     : Rose.Capabilities.Capability;
      Get_Old : Rose.Capabilities.Capability;
      Pack    : Rose.Capabilities.Capability);

   procedure Open
     (Client        : out Shelf_Client;
      Interface_Cap : Rose.Capabilities.Capability);

   function From_Cap (Cap : Rose.Capabilities.Capability) return Shelf_Client;

   procedure Close (Client : in out Shelf_Client);

   overriding procedure Put
     (Item : in out Shelf_Client;
      Info : Rose.Interfaces.Shelf.File_Info_V1);

   overriding function Get
     (Item  : in out Shelf_Client;
      Index : Natural)
      return Rose.Interfaces.Shelf.File_Info;

   overriding function Get_Old
     (Item  : in out Shelf_Client;
      Index : Natural)
      return Rose.Interfaces.Shelf.File_Info_V1;

   overriding function Pack
     (Item : in out Shelf_Client)
      return Rose.Interfaces.Shelf.Bundle;

   overriding function Shelf_Cap
     (Item : in out Shelf_Client)
      return Rose.Capabilities.Capability;

   function Get_Interface_Cap
     (Item : Shelf_Client)
      return Rose.Capabilities.Capability;

   function Get_Put_Cap
     (Item : in out Shelf_Client)
      return Rose.Capabilities.Capability;

   function Get_Get_Cap
     (Item : in out Shelf_Client)
      return Rose.Capabilities.Capability;

   function Get_Get_Old_Cap
     (Item : in out Shelf_Client)
      return Rose.Capabilities.Capability;

   function Get_Pack_Cap
     (Item : in out Shelf_Client)
      return Rose.Capabilities.Capability;

private

   type Shelf_Client is
     limited new Rose.Interfaces.Shelf.Shelf_Object
   with record
      Is_Open       : Boolean := False;
      Interface_Cap : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
      Put           : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
      Get           : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
      Get_Old       : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
      Pack          : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
   end record;

end Rose.Interfaces.Shelf.Client;
