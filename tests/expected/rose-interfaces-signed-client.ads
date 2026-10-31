with Interfaces;
with Rose.Capabilities;
with Rose.Invocation;
with Rose.Words;

package Rose.Interfaces.Signed.Client is

   type Signed_Client is private;

   procedure Open_Cap_Set
     (Client     : out Signed_Client;
      Clamp      : Rose.Capabilities.Capability;
      Position   : Rose.Capabilities.Capability;
      Offset     : Rose.Capabilities.Capability;
      Difference : Rose.Capabilities.Capability;
      Bounds     : Rose.Capabilities.Capability);

   procedure Open
     (Client        : out Signed_Client;
      Interface_Cap : Rose.Capabilities.Capability);

   procedure Close (Client : in out Signed_Client);

   function Clamp
     (Item  : Signed_Client;
      Value : Standard.Interfaces.Integer_32;
      Low   : Standard.Interfaces.Integer_32)
      return Standard.Interfaces.Integer_32;

   procedure Position
     (Item  : Signed_Client;
      Index : Rose.Words.Word;
      X     : out Standard.Interfaces.Integer_32;
      Y     : out Standard.Interfaces.Integer_32;
      Count : out Natural);

   procedure Offset
     (Item    : Signed_Client;
      Delta_X : in out Standard.Interfaces.Integer_32);

   function Difference
     (Item  : Signed_Client;
      Left  : Standard.Interfaces.Integer_64;
      Right : Standard.Interfaces.Integer_64)
      return Standard.Interfaces.Integer_64;

   procedure Bounds
     (Item : Signed_Client;
      Low  : out Standard.Interfaces.Integer_64;
      High : out Standard.Interfaces.Integer_64);

   function Get_Interface_Cap
     (Item : Signed_Client)
      return Rose.Capabilities.Capability;

   function Get_Clamp_Cap
     (Item : Signed_Client)
      return Rose.Capabilities.Capability;

   function Get_Position_Cap
     (Item : Signed_Client)
      return Rose.Capabilities.Capability;

   function Get_Offset_Cap
     (Item : Signed_Client)
      return Rose.Capabilities.Capability;

   function Get_Difference_Cap
     (Item : Signed_Client)
      return Rose.Capabilities.Capability;

   function Get_Bounds_Cap
     (Item : Signed_Client)
      return Rose.Capabilities.Capability;

   function Has_Error return Boolean;

   function Get_Last_Error return Rose.Invocation.Invocation_Error;

private

   type Signed_Client is record
      Is_Open       : Boolean := False;
      Interface_Cap : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
      Clamp         : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
      Position      : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
      Offset        : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
      Difference    : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
      Bounds        : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
   end record;

end Rose.Interfaces.Signed.Client;
