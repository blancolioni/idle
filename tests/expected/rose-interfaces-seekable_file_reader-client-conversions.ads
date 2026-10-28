with Rose.Interfaces.File_Reader.Client;
with Rose.Interfaces.Resource.Client;
with Rose.Interfaces.Seekable.Client;
with Rose.Interfaces.Stream_Reader.Client;

package Rose.Interfaces.Seekable_File_Reader.Client.Conversions is

   function To_Stream_Reader
     (Item : Seekable_File_Reader_Client)
      return Rose.Interfaces.Stream_Reader.Client.Stream_Reader_Client;

   function To_Resource
     (Item : Seekable_File_Reader_Client)
      return Rose.Interfaces.Resource.Client.Resource_Client;

   function To_File_Reader
     (Item : Seekable_File_Reader_Client)
      return Rose.Interfaces.File_Reader.Client.File_Reader_Client;

   function To_Seekable
     (Item : Seekable_File_Reader_Client)
      return Rose.Interfaces.Seekable.Client.Seekable_Client;

end Rose.Interfaces.Seekable_File_Reader.Client.Conversions;
