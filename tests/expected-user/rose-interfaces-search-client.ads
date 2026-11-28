with Rose.Capabilities;

package Rose.Interfaces.Search.Client is

   type Search_Client is
     limited new Rose.Interfaces.Search.Search_Object
     with private;

   procedure Open_Cap_Set
     (Client : out Search_Client;
      Get    : Rose.Capabilities.Capability);

   procedure Open
     (Client        : out Search_Client;
      Interface_Cap : Rose.Capabilities.Capability);

   function From_Cap (Cap : Rose.Capabilities.Capability) return Search_Client;

   procedure Close (Client : in out Search_Client);

   overriding function Get
     (Item  : in out Search_Client;
      Index : Natural)
      return Rose.Interfaces.Search.Grep_Match;

   overriding function Search_Cap
     (Item : in out Search_Client)
      return Rose.Capabilities.Capability;

   function Get_Interface_Cap
     (Item : Search_Client)
      return Rose.Capabilities.Capability;

   function Get_Get_Cap
     (Item : in out Search_Client)
      return Rose.Capabilities.Capability;

private

   type Search_Client is
     limited new Rose.Interfaces.Search.Search_Object
   with record
      Is_Open       : Boolean := False;
      Interface_Cap : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
      Get           : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
   end record;

end Rose.Interfaces.Search.Client;
