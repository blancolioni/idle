with Rose.Invocation;
with Rose.System_Calls;

package body Rose.Interfaces.Exec.Client.Conversions is

   ---------------
   -- To_Launch --
   ---------------

   function To_Launch
     (Item : Exec_Client)
      return Rose.Interfaces.Launch.Client.Launch_Client
   is
      use type Rose.Capabilities.Capability;
      Params : aliased Rose.Invocation.Invocation_Record;
      Result : Rose.Interfaces.Launch.Client.Launch_Client;
   begin
      if Item.Interface_Cap = Rose.Capabilities.Null_Capability then
         Rose.Interfaces.Launch.Client.Open_Cap_Set (Result, Item.Launch);
      else
         Rose.System_Calls.Initialize_Send (Params, Item.Interface_Cap);
         Rose.System_Calls.Send_Word (Params, Natural (1));
         Rose.System_Calls.Receive_Caps (Params, 1);
         Rose.System_Calls.Invoke_Capability (Params);
         Rose.Interfaces.Launch.Client.Open (Result, Params.Caps (0));
      end if;
      return Result;
   end To_Launch;

end Rose.Interfaces.Exec.Client.Conversions;
