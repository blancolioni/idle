with Rose.Interfaces.Counter.Client;
with Rose.Interfaces.Named.Client;

package Rose.Interfaces.Meter.Client.Conversions is

   function To_Named
     (Item : Meter_Client)
      return Rose.Interfaces.Named.Client.Named_Client;

   function To_Counter
     (Item : Meter_Client)
      return Rose.Interfaces.Counter.Client.Counter_Client;

end Rose.Interfaces.Meter.Client.Conversions;
