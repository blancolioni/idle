with Rose.Invocation;
with Rose.System_Calls;

package body Rose.Interfaces.Meter.Client.Conversions is

   ----------------
   -- To_Counter --
   ----------------

   function To_Counter
     (Item : Meter_Client)
      return Rose.Interfaces.Counter.Client.Counter_Client
   is
      use type Rose.Capabilities.Capability;
      Params : aliased Rose.Invocation.Invocation_Record;
      Result : Rose.Interfaces.Counter.Client.Counter_Client;
   begin
      if Item.Interface_Cap = Rose.Capabilities.Null_Capability then
         Rose.Interfaces.Counter.Client.Open_Cap_Set
           (Result,
            Item.Badge,
            Item.Increment,
            Item.Value);
      else
         Rose.System_Calls.Initialize_Send (Params, Item.Interface_Cap);
         Rose.System_Calls.Send_Word (Params, Natural (2));
         Rose.System_Calls.Receive_Caps (Params, 1);
         Rose.System_Calls.Invoke_Capability (Params);
         Rose.Interfaces.Counter.Client.Open (Result, Params.Caps (0));
      end if;
      return Result;
   end To_Counter;

   --------------
   -- To_Named --
   --------------

   function To_Named
     (Item : Meter_Client)
      return Rose.Interfaces.Named.Client.Named_Client
   is
      use type Rose.Capabilities.Capability;
      Params : aliased Rose.Invocation.Invocation_Record;
      Result : Rose.Interfaces.Named.Client.Named_Client;
   begin
      if Item.Interface_Cap = Rose.Capabilities.Null_Capability then
         Rose.Interfaces.Named.Client.Open_Cap_Set (Result, Item.Badge);
      else
         Rose.System_Calls.Initialize_Send (Params, Item.Interface_Cap);
         Rose.System_Calls.Send_Word (Params, Natural (1));
         Rose.System_Calls.Receive_Caps (Params, 1);
         Rose.System_Calls.Invoke_Capability (Params);
         Rose.Interfaces.Named.Client.Open (Result, Params.Caps (0));
      end if;
      return Result;
   end To_Named;

end Rose.Interfaces.Meter.Client.Conversions;
