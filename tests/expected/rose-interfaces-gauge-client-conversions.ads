with Rose.Interfaces.Counter.Client;
with Rose.Interfaces.Labelled.Client;
with Rose.Interfaces.Named.Client;

package Rose.Interfaces.Gauge.Client.Conversions is

   function To_Named
     (Item : Gauge_Client)
      return Rose.Interfaces.Named.Client.Named_Client;

   function To_Counter
     (Item : Gauge_Client)
      return Rose.Interfaces.Counter.Client.Counter_Client;

   function To_Labelled
     (Item : Gauge_Client)
      return Rose.Interfaces.Labelled.Client.Labelled_Client;

end Rose.Interfaces.Gauge.Client.Conversions;
