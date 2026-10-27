with Rose.Capabilities;
with Rose.Interfaces.Cap;
with Rose.Words;

package Rose.Interfaces.Timer.Client is

   type Timer_Client is
     limited new Rose.Interfaces.Timer.Timer_Object
     with private;

   procedure Open_Cap_Set
     (Client    : out Timer_Client;
      Set_Timer : Rose.Capabilities.Capability);

   procedure Open
     (Client        : out Timer_Client;
      Interface_Cap : Rose.Capabilities.Capability);

   function From_Cap (Cap : Rose.Capabilities.Capability) return Timer_Client;

   procedure Close (Client : in out Timer_Client);

   overriding function Set_Timer
     (Item         : in out Timer_Client;
      Milliseconds : Rose.Words.Word;
      Cap          : Rose.Capabilities.Capability)
      return Rose.Interfaces.Cap.Cap_Object'Class;

   overriding function Timer_Cap
     (Item : in out Timer_Client)
      return Rose.Capabilities.Capability;

   function Get_Interface_Cap
     (Item : Timer_Client)
      return Rose.Capabilities.Capability;

   function Get_Set_Timer_Cap
     (Item : in out Timer_Client)
      return Rose.Capabilities.Capability;

private

   type Timer_Client is
     limited new Rose.Interfaces.Timer.Timer_Object
   with record
      Is_Open       : Boolean := False;
      Interface_Cap : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
      Set_Timer     : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
   end record;

end Rose.Interfaces.Timer.Client;
