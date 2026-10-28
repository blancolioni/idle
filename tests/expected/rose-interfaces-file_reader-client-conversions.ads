with Rose.Interfaces.Resource.Client;
with Rose.Interfaces.Stream_Reader.Client;

package Rose.Interfaces.File_Reader.Client.Conversions is

   function To_Stream_Reader
     (Item : File_Reader_Client)
      return Rose.Interfaces.Stream_Reader.Client.Stream_Reader_Client;

   function To_Resource
     (Item : File_Reader_Client)
      return Rose.Interfaces.Resource.Client.Resource_Client;

end Rose.Interfaces.File_Reader.Client.Conversions;
