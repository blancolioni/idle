with Rose.Capabilities;
with Rose.Objects;

package Rose.Interfaces.Cap.Client is

   type Cap_Client is limited new Rose.Interfaces.Cap.Cap_Object with private;

   procedure Open_Cap_Set
     (Client        : out Cap_Client;
      Destroy       : Rose.Capabilities.Capability;
      Get_Object_Id : Rose.Capabilities.Capability);

   procedure Open
     (Client        : out Cap_Client;
      Interface_Cap : Rose.Capabilities.Capability);

   function From_Cap (Cap : Rose.Capabilities.Capability) return Cap_Client;

   procedure Close (Client : in out Cap_Client);

   overriding procedure Destroy (Item : in out Cap_Client);

   overriding function Get_Object_Id
     (Item : in out Cap_Client)
      return Rose.Objects.Object_Id;

   overriding function Cap_Cap
     (Item : in out Cap_Client)
      return Rose.Capabilities.Capability;

   function Get_Interface_Cap
     (Item : Cap_Client)
      return Rose.Capabilities.Capability;

   function Get_Destroy_Cap
     (Item : in out Cap_Client)
      return Rose.Capabilities.Capability;

   function Get_Get_Object_Id_Cap
     (Item : in out Cap_Client)
      return Rose.Capabilities.Capability;

private

   type Cap_Client is limited new Rose.Interfaces.Cap.Cap_Object with record
      Is_Open       : Boolean := False;
      Interface_Cap : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
      Destroy       : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
      Get_Object_Id : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
   end record;

end Rose.Interfaces.Cap.Client;
