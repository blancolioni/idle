with Rose.Invocation;
with Rose.System_Calls;

package body Rose.Interfaces.Lease.Client.Conversions is

   ----------------
   -- To_Counter --
   ----------------

   function To_Counter
     (Item : Lease_Client)
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
     (Item : Lease_Client)
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

   -----------------
   -- To_Resource --
   -----------------

   function To_Resource
     (Item : Lease_Client)
      return Rose.Interfaces.Resource.Client.Resource_Client
   is
      use type Rose.Capabilities.Capability;
      Params : aliased Rose.Invocation.Invocation_Record;
      Result : Rose.Interfaces.Resource.Client.Resource_Client;
   begin
      if Item.Interface_Cap = Rose.Capabilities.Null_Capability then
         Rose.Interfaces.Resource.Client.Open_Cap_Set (Result, Item.Release);
      else
         Rose.System_Calls.Initialize_Send (Params, Item.Interface_Cap);
         Rose.System_Calls.Send_Word (Params, Natural (3));
         Rose.System_Calls.Receive_Caps (Params, 1);
         Rose.System_Calls.Invoke_Capability (Params);
         Rose.Interfaces.Resource.Client.Open (Result, Params.Caps (0));
      end if;
      return Result;
   end To_Resource;

end Rose.Interfaces.Lease.Client.Conversions;
