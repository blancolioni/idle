with Rose.Capabilities;

package Rose.Interfaces.Finder.Client is

   type Finder_Client is
     limited new Rose.Interfaces.Finder.Finder_Object
     with private;

   procedure Open_Cap_Set
     (Client : out Finder_Client;
      Get    : Rose.Capabilities.Capability);

   procedure Open
     (Client        : out Finder_Client;
      Interface_Cap : Rose.Capabilities.Capability);

   function From_Cap (Cap : Rose.Capabilities.Capability) return Finder_Client;

   procedure Close (Client : in out Finder_Client);

   overriding function Get
     (Item  : in out Finder_Client;
      Index : Natural)
      return Rose.Interfaces.Finder.File_Info;

   overriding function Finder_Cap
     (Item : in out Finder_Client)
      return Rose.Capabilities.Capability;

   function Get_Interface_Cap
     (Item : Finder_Client)
      return Rose.Capabilities.Capability;

   function Get_Get_Cap
     (Item : in out Finder_Client)
      return Rose.Capabilities.Capability;

private

   type Finder_Client is
     limited new Rose.Interfaces.Finder.Finder_Object
   with record
      Is_Open       : Boolean := False;
      Interface_Cap : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
      Get           : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
   end record;

end Rose.Interfaces.Finder.Client;
