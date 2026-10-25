with Rose.Interfaces.Cap.Client;
with Rose.Interfaces.Segment.Client;
with Rose.Interfaces.Server.Client;

package Rose.Interfaces.Process.Client.Conversions is

   function To_Segment
     (Item : Process_Client)
      return Rose.Interfaces.Segment.Client.Segment_Client;

   function To_Server
     (Item : Process_Client)
      return Rose.Interfaces.Server.Client.Server_Client;

   function To_Cap
     (Item : Process_Client)
      return Rose.Interfaces.Cap.Client.Cap_Client;

end Rose.Interfaces.Process.Client.Conversions;
