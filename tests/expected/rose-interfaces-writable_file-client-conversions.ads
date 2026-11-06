with Rose.Interfaces.File.Client;
with Rose.Interfaces.Stream_Writer.Client;

package Rose.Interfaces.Writable_File.Client.Conversions is

   function To_File
     (Item : Writable_File_Client)
      return Rose.Interfaces.File.Client.File_Client;

   function To_Stream_Writer
     (Item : Writable_File_Client)
      return Rose.Interfaces.Stream_Writer.Client.Stream_Writer_Client;

end Rose.Interfaces.Writable_File.Client.Conversions;
