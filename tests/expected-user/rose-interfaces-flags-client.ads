with Rose.Capabilities;
with Rose.Words;

package Rose.Interfaces.Flags.Client is

   type Flags_Client is
     limited new Rose.Interfaces.Flags.Flags_Object
     with private;

   procedure Open_Cap_Set
     (Client : out Flags_Client;
      Is_Set : Rose.Capabilities.Capability;
      Query  : Rose.Capabilities.Capability;
      Toggle : Rose.Capabilities.Capability);

   procedure Open
     (Client        : out Flags_Client;
      Interface_Cap : Rose.Capabilities.Capability);

   function From_Cap (Cap : Rose.Capabilities.Capability) return Flags_Client;

   procedure Close (Client : in out Flags_Client);

   overriding function Is_Set
     (Item    : in out Flags_Client;
      Name    : String;
      Default : Boolean)
      return Boolean;

   overriding procedure Query
     (Item    : in out Flags_Client;
      Index   : Rose.Words.Word;
      Trusted : out Boolean;
      Count   : out Natural);

   overriding procedure Toggle
     (Item  : in out Flags_Client;
      Value : in out Boolean);

   overriding function Flags_Cap
     (Item : in out Flags_Client)
      return Rose.Capabilities.Capability;

   function Get_Interface_Cap
     (Item : Flags_Client)
      return Rose.Capabilities.Capability;

   function Get_Is_Set_Cap
     (Item : in out Flags_Client)
      return Rose.Capabilities.Capability;

   function Get_Query_Cap
     (Item : in out Flags_Client)
      return Rose.Capabilities.Capability;

   function Get_Toggle_Cap
     (Item : in out Flags_Client)
      return Rose.Capabilities.Capability;

private

   type Flags_Client is
     limited new Rose.Interfaces.Flags.Flags_Object
   with record
      Is_Open       : Boolean := False;
      Interface_Cap : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
      Is_Set        : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
      Query         : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
      Toggle        : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
   end record;

end Rose.Interfaces.Flags.Client;
