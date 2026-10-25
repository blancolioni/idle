package body Rose.Interfaces.Meter.Client.Conversions is

   ----------------
   -- To_Counter --
   ----------------

   function To_Counter
     (Item : Meter_Client)
      return Rose.Interfaces.Counter.Client.Counter_Client
   is
      Result : Rose.Interfaces.Counter.Client.Counter_Client;
   begin
      Rose.Interfaces.Counter.Client.Open_Cap_Set
        (Result,
         Item.Badge,
         Item.Increment,
         Item.Value);
      return Result;
   end To_Counter;

   --------------
   -- To_Named --
   --------------

   function To_Named
     (Item : Meter_Client)
      return Rose.Interfaces.Named.Client.Named_Client
   is
      Result : Rose.Interfaces.Named.Client.Named_Client;
   begin
      Rose.Interfaces.Named.Client.Open_Cap_Set (Result, Item.Badge);
      return Result;
   end To_Named;

end Rose.Interfaces.Meter.Client.Conversions;
