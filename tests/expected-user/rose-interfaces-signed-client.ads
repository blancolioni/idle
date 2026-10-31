with Rose.Capabilities;
with Rose.Words;

package Rose.Interfaces.Signed.Client is

   type Signed_Client is
     limited new Rose.Interfaces.Signed.Signed_Object
     with private;

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

   function From_Cap (Cap : Rose.Capabilities.Capability) return Signed_Client;

   procedure Close (Client : in out Signed_Client);

   overriding function Clamp
     (Item  : in out Signed_Client;
      Value : Integer;
      Low   : Integer)
      return Integer;

   overriding procedure Position
     (Item  : in out Signed_Client;
      Index : Rose.Words.Word;
      X     : out Integer;
      Y     : out Integer;
      Count : out Natural);

   overriding procedure Offset
     (Item    : in out Signed_Client;
      Delta_X : in out Integer);

   overriding function Difference
     (Item  : in out Signed_Client;
      Left  : Long_Long_Integer;
      Right : Long_Long_Integer)
      return Long_Long_Integer;

   overriding procedure Bounds
     (Item : in out Signed_Client;
      Low  : out Long_Long_Integer;
      High : out Long_Long_Integer);

   overriding function Signed_Cap
     (Item : in out Signed_Client)
      return Rose.Capabilities.Capability;

   function Get_Interface_Cap
     (Item : Signed_Client)
      return Rose.Capabilities.Capability;

   function Get_Clamp_Cap
     (Item : in out Signed_Client)
      return Rose.Capabilities.Capability;

   function Get_Position_Cap
     (Item : in out Signed_Client)
      return Rose.Capabilities.Capability;

   function Get_Offset_Cap
     (Item : in out Signed_Client)
      return Rose.Capabilities.Capability;

   function Get_Difference_Cap
     (Item : in out Signed_Client)
      return Rose.Capabilities.Capability;

   function Get_Bounds_Cap
     (Item : in out Signed_Client)
      return Rose.Capabilities.Capability;

private

   type Signed_Client is
     limited new Rose.Interfaces.Signed.Signed_Object
   with record
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
