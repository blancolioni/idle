with Rose.Capabilities;
with Rose.Invocation;
with Rose.Words;

package Rose.Interfaces.Labelled.Client is

   type Labelled_Client is private;

   procedure Open_Cap_Set
     (Client    : out Labelled_Client;
      Badge     : Rose.Capabilities.Capability;
      Set_Label : Rose.Capabilities.Capability);

   procedure Open
     (Client        : out Labelled_Client;
      Interface_Cap : Rose.Capabilities.Capability);

   procedure Close (Client : in out Labelled_Client);

   function Badge (Item : Labelled_Client) return Rose.Capabilities.Capability;

   procedure Set_Label (Item : Labelled_Client; Label : Rose.Words.Word);

   function Get_Interface_Cap
     (Item : Labelled_Client)
      return Rose.Capabilities.Capability;

   function Get_Badge_Cap
     (Item : Labelled_Client)
      return Rose.Capabilities.Capability;

   function Get_Set_Label_Cap
     (Item : Labelled_Client)
      return Rose.Capabilities.Capability;

   function Has_Error return Boolean;

   function Get_Last_Error return Rose.Invocation.Invocation_Error;

private

   type Labelled_Client is record
      Is_Open       : Boolean := False;
      Interface_Cap : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
      Badge         : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
      Set_Label     : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
   end record;

end Rose.Interfaces.Labelled.Client;
