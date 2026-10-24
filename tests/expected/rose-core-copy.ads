with Rose.Interfaces.Directory.Client;
with Rose.Interfaces.File.Client;
with Rose.Interfaces.Stream_Writer.Client;

procedure Rose.Core.Copy
  (Logging     : Rose.Interfaces.Stream_Writer.Client.Stream_Writer_Client;
   Source      : Rose.Interfaces.File.Client.File_Client;
   Target      : Rose.Interfaces.File.Client.File_Client;
   Root        : Rose.Interfaces.Directory.Client.Directory_Client;
   Count       : out Natural;
   Verbose     : in out Boolean;
   Report      : out String;
   Report_Last : out Natural;
   Note        : in out String;
   Note_Last   : out Natural);
