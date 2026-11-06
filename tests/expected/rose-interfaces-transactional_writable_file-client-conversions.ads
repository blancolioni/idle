with Rose.Interfaces.File.Client;
with Rose.Interfaces.Resource.Client;
with Rose.Interfaces.Stream_Writer.Client;
with Rose.Interfaces.Transactional.Client;
with Rose.Interfaces.Writable_File.Client;

package Rose.Interfaces.Transactional_Writable_File.Client.Conversions is

   function To_File
     (Item : Transactional_Writable_File_Client)
      return Rose.Interfaces.File.Client.File_Client;

   function To_Stream_Writer
     (Item : Transactional_Writable_File_Client)
      return Rose.Interfaces.Stream_Writer.Client.Stream_Writer_Client;

   function To_Writable_File
     (Item : Transactional_Writable_File_Client)
      return Rose.Interfaces.Writable_File.Client.Writable_File_Client;

   function To_Transactional
     (Item : Transactional_Writable_File_Client)
      return Rose.Interfaces.Transactional.Client.Transactional_Client;

   function To_Resource
     (Item : Transactional_Writable_File_Client)
      return Rose.Interfaces.Resource.Client.Resource_Client;

end Rose.Interfaces.Transactional_Writable_File.Client.Conversions;
