with Rose.Interfaces.Named.Client;

package Rose.Interfaces.Counter.Client.Conversions is

   function To_Named
     (Item : Counter_Client)
      return Rose.Interfaces.Named.Client.Named_Client;

end Rose.Interfaces.Counter.Client.Conversions;
