with Rose.Interfaces.Launch.Client;

package Rose.Interfaces.Exec.Client.Conversions is

   function To_Launch
     (Item : Exec_Client)
      return Rose.Interfaces.Launch.Client.Launch_Client;

end Rose.Interfaces.Exec.Client.Conversions;
