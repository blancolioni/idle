with Rose.Capabilities;
with Rose.Invocation;

package Rose.Interfaces.Cap_Set.Client is

   type Cap_Set_Client is private;

   procedure Open_Cap_Set
     (Client  : out Cap_Set_Client;
      Append  : Rose.Capabilities.Capability;
      Get_Cap : Rose.Capabilities.Capability;
      Length  : Rose.Capabilities.Capability);

   procedure Open
     (Client        : out Cap_Set_Client;
      Interface_Cap : Rose.Capabilities.Capability);

   procedure Close (Client : in out Cap_Set_Client);

   procedure Append
     (Item : Cap_Set_Client;
      Caps : Rose.Capabilities.Capability_Array);

   function Get_Cap
     (Item  : Cap_Set_Client;
      Index : Positive)
      return Rose.Capabilities.Capability;

   function Length (Item : Cap_Set_Client) return Natural;

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

   function Has_Error return Boolean;

   function Get_Last_Error return Rose.Invocation.Invocation_Error;

private

   type Cap_Set_Client is record
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
