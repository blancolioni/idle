with Rose.Capabilities;
with Rose.Interfaces.Cap.Client;
with Rose.Invocation;
with Rose.Words;

package Rose.Interfaces.Timer.Client is

   type Timer_Client is private;

   procedure Open_Cap_Set
     (Client    : out Timer_Client;
      Set_Timer : Rose.Capabilities.Capability);

   procedure Open
     (Client        : out Timer_Client;
      Interface_Cap : Rose.Capabilities.Capability);

   procedure Close (Client : in out Timer_Client);

   function Set_Timer
     (Item         : Timer_Client;
      Milliseconds : Rose.Words.Word;
      Cap          : Rose.Capabilities.Capability)
      return Rose.Interfaces.Cap.Client.Cap_Client;

   function Get_Interface_Cap
     (Item : Timer_Client)
      return Rose.Capabilities.Capability;

   function Get_Set_Timer_Cap
     (Item : Timer_Client)
      return Rose.Capabilities.Capability;

   function Has_Error return Boolean;

   function Get_Last_Error return Rose.Invocation.Invocation_Error;

private

   type Timer_Client is record
      Is_Open       : Boolean := False;
      Interface_Cap : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
      Set_Timer     : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
   end record;

end Rose.Interfaces.Timer.Client;
