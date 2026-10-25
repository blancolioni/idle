package body Rose.Interfaces.Exec.Client.Conversions is

   ---------------
   -- To_Launch --
   ---------------

   function To_Launch
     (Item : Exec_Client)
      return Rose.Interfaces.Launch.Client.Launch_Client
   is
      Result : Rose.Interfaces.Launch.Client.Launch_Client;
   begin
      Rose.Interfaces.Launch.Client.Open_Cap_Set (Result, Item.Launch);
      return Result;
   end To_Launch;

end Rose.Interfaces.Exec.Client.Conversions;
