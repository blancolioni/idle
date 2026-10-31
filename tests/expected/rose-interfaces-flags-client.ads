with Rose.Capabilities;
with Rose.Invocation;
with Rose.Words;

package Rose.Interfaces.Flags.Client is

   type Flags_Client is private;

   procedure Open_Cap_Set
     (Client : out Flags_Client;
      Is_Set : Rose.Capabilities.Capability;
      Query  : Rose.Capabilities.Capability;
      Toggle : Rose.Capabilities.Capability);

   procedure Open
     (Client        : out Flags_Client;
      Interface_Cap : Rose.Capabilities.Capability);

   procedure Close (Client : in out Flags_Client);

   function Is_Set
     (Item    : Flags_Client;
      Name    : String;
      Default : Boolean)
      return Boolean;

   procedure Query
     (Item    : Flags_Client;
      Index   : Rose.Words.Word;
      Trusted : out Boolean;
      Count   : out Natural);

   procedure Toggle (Item : Flags_Client; Value : in out Boolean);

   function Get_Interface_Cap
     (Item : Flags_Client)
      return Rose.Capabilities.Capability;

   function Get_Is_Set_Cap
     (Item : Flags_Client)
      return Rose.Capabilities.Capability;

   function Get_Query_Cap
     (Item : Flags_Client)
      return Rose.Capabilities.Capability;

   function Get_Toggle_Cap
     (Item : Flags_Client)
      return Rose.Capabilities.Capability;

   function Has_Error return Boolean;

   function Get_Last_Error return Rose.Invocation.Invocation_Error;

private

   type Flags_Client is record
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
