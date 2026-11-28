with Rose.Capabilities;
with Rose.Interfaces.Core.Units;

package Rose.Interfaces.Catalogue.Client is

   type Catalogue_Client is
     limited new Rose.Interfaces.Catalogue.Catalogue_Object
     with private;

   procedure Open_Cap_Set
     (Client : out Catalogue_Client;
      Total  : Rose.Capabilities.Capability;
      Resize : Rose.Capabilities.Capability;
      Find   : Rose.Capabilities.Capability);

   procedure Open
     (Client        : out Catalogue_Client;
      Interface_Cap : Rose.Capabilities.Capability);

   function From_Cap
     (Cap : Rose.Capabilities.Capability)
      return Catalogue_Client;

   procedure Close (Client : in out Catalogue_Client);

   overriding function Total
     (Item : in out Catalogue_Client)
      return Rose.Interfaces.Core.Units.Bytes;

   overriding procedure Resize
     (Item : in out Catalogue_Client;
      Size : Rose.Interfaces.Core.Units.Bytes;
      Done : out Rose.Interfaces.Core.Units.Percent);

   overriding function Find
     (Item  : in out Catalogue_Client;
      Index : Natural)
      return Rose.Interfaces.Catalogue.Entry_Info;

   overriding function Catalogue_Cap
     (Item : in out Catalogue_Client)
      return Rose.Capabilities.Capability;

   function Get_Interface_Cap
     (Item : Catalogue_Client)
      return Rose.Capabilities.Capability;

   function Get_Total_Cap
     (Item : in out Catalogue_Client)
      return Rose.Capabilities.Capability;

   function Get_Resize_Cap
     (Item : in out Catalogue_Client)
      return Rose.Capabilities.Capability;

   function Get_Find_Cap
     (Item : in out Catalogue_Client)
      return Rose.Capabilities.Capability;

private

   type Catalogue_Client is
     limited new Rose.Interfaces.Catalogue.Catalogue_Object
   with record
      Is_Open       : Boolean := False;
      Interface_Cap : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
      Total         : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
      Resize        : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
      Find          : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
   end record;

end Rose.Interfaces.Catalogue.Client;
