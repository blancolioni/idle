package body Rose.Interfaces.Gauge.Client.Conversions is

   ----------------
   -- To_Counter --
   ----------------

   function To_Counter
     (Item : Gauge_Client)
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

   -----------------
   -- To_Labelled --
   -----------------

   function To_Labelled
     (Item : Gauge_Client)
      return Rose.Interfaces.Labelled.Client.Labelled_Client
   is
      Result : Rose.Interfaces.Labelled.Client.Labelled_Client;
   begin
      Rose.Interfaces.Labelled.Client.Open_Cap_Set
        (Result,
         Item.Badge,
         Item.Set_Label);
      return Result;
   end To_Labelled;

   --------------
   -- To_Named --
   --------------

   function To_Named
     (Item : Gauge_Client)
      return Rose.Interfaces.Named.Client.Named_Client
   is
      Result : Rose.Interfaces.Named.Client.Named_Client;
   begin
      Rose.Interfaces.Named.Client.Open_Cap_Set (Result, Item.Badge);
      return Result;
   end To_Named;

end Rose.Interfaces.Gauge.Client.Conversions;
