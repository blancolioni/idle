with Rose.Interfaces.Counter.Client;
with Rose.Interfaces.Named.Client;
with Rose.Interfaces.Resource.Client;

package Rose.Interfaces.Lease.Client.Conversions is

   function To_Named
     (Item : Lease_Client)
      return Rose.Interfaces.Named.Client.Named_Client;

   function To_Counter
     (Item : Lease_Client)
      return Rose.Interfaces.Counter.Client.Counter_Client;

   function To_Resource
     (Item : Lease_Client)
      return Rose.Interfaces.Resource.Client.Resource_Client;

end Rose.Interfaces.Lease.Client.Conversions;
