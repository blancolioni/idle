with Rose.Capabilities;

package Rose.Interfaces.Cap_Set.Client is

   type Cap_Set_Client is
     limited new Rose.Interfaces.Cap_Set.Cap_Set_Object
     with private;

   procedure Open_Cap_Set
     (Client  : out Cap_Set_Client;
      Append  : Rose.Capabilities.Capability;
      Get_Cap : Rose.Capabilities.Capability;
      Length  : Rose.Capabilities.Capability);

   procedure Open
     (Client        : out Cap_Set_Client;
      Interface_Cap : Rose.Capabilities.Capability);

   procedure Close (Client : in out Cap_Set_Client);

   overriding procedure Append
     (Item : in out Cap_Set_Client;
      Caps : Rose.Capabilities.Capability_Array);

   overriding function Get_Cap
     (Item  : Cap_Set_Client;
      Index : Positive)
      return Rose.Capabilities.Capability;

   overriding function Length (Item : Cap_Set_Client) return Natural;

   function Get_Interface_Cap
     (Item : Cap_Set_Client)
      return Rose.Capabilities.Capability;

   function Get_Append_Cap
     (Item : Cap_Set_Client)
      return Rose.Capabilities.Capability;

   function Get_Get_Cap_Cap
     (Item : Cap_Set_Client)
      return Rose.Capabilities.Capability;

   function Get_Length_Cap
     (Item : Cap_Set_Client)
      return Rose.Capabilities.Capability;

private

   type Cap_Set_Client is
     limited new Rose.Interfaces.Cap_Set.Cap_Set_Object
   with record
      Is_Open       : Boolean := False;
      Interface_Cap : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
      Append        : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
      Get_Cap       : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
      Length        : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
   end record;

end Rose.Interfaces.Cap_Set.Client;
