with Rose.Interfaces.File.Client;
with Rose.Interfaces.Stream_Writer.Client;

procedure Rose.Core.Show
  (Logging : Rose.Interfaces.Stream_Writer.Client.Stream_Writer_Client;
   Source  : Rose.Interfaces.File.Client.File_Client;
   Count   : out Natural);
