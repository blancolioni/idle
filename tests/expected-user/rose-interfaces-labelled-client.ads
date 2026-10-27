with Rose.Capabilities;
with Rose.Words;

package Rose.Interfaces.Labelled.Client is

   type Labelled_Client is
     limited new Rose.Interfaces.Labelled.Labelled_Object
     with private;

   procedure Open_Cap_Set
     (Client    : out Labelled_Client;
      Badge     : Rose.Capabilities.Capability;
      Set_Label : Rose.Capabilities.Capability);

   procedure Open
     (Client        : out Labelled_Client;
      Interface_Cap : Rose.Capabilities.Capability);

   function From_Cap
     (Cap : Rose.Capabilities.Capability)
      return Labelled_Client;

   procedure Close (Client : in out Labelled_Client);

   overriding function Badge
     (Item : in out Labelled_Client)
      return Rose.Capabilities.Capability;

   overriding procedure Set_Label
     (Item  : in out Labelled_Client;
      Label : Rose.Words.Word);

   overriding function Labelled_Cap
     (Item : in out Labelled_Client)
      return Rose.Capabilities.Capability;

   function Get_Interface_Cap
     (Item : Labelled_Client)
      return Rose.Capabilities.Capability;

   function Get_Badge_Cap
     (Item : in out Labelled_Client)
      return Rose.Capabilities.Capability;

   function Get_Set_Label_Cap
     (Item : in out Labelled_Client)
      return Rose.Capabilities.Capability;

private

   type Labelled_Client is
     limited new Rose.Interfaces.Labelled.Labelled_Object
   with record
      Is_Open       : Boolean := False;
      Interface_Cap : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
      Badge         : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
      Set_Label     : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
   end record;

end Rose.Interfaces.Labelled.Client;
