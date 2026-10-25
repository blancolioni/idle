package body Rose.Interfaces.Counter.Client.Conversions is

   --------------
   -- To_Named --
   --------------

   function To_Named
     (Item : Counter_Client)
      return Rose.Interfaces.Named.Client.Named_Client
   is
      Result : Rose.Interfaces.Named.Client.Named_Client;
   begin
      Rose.Interfaces.Named.Client.Open_Cap_Set (Result, Item.Badge);
      return Result;
   end To_Named;

end Rose.Interfaces.Counter.Client.Conversions;
