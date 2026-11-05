with Rose.Capabilities;
with Rose.Interfaces.File.Client;
with Rose.Interfaces.Journal.Client;
with Rose.Interfaces.Stream_Writer.Client;
with Rose.Interfaces.Transactional.Client;
with Rose.Interfaces.Transactional_Writable_File.Client;
with Rose.Interfaces.Writable_Directory.Client;
with Rose.Interfaces.Writable_File.Client;

procedure Rose.Core.Copy
  (Logging     : Rose.Interfaces.Stream_Writer.Client.Stream_Writer_Client;
   Source      : Rose.Interfaces.File.Client.File_Client;
   Target      : Rose.Interfaces.Writable_File.Client.Writable_File_Client;
   Root        :
     Rose.Interfaces.Writable_Directory.Client.Writable_Directory_Client;
   Batch       : Rose.Interfaces.Transactional.Client.Transactional_Client;
   Draft       :
     Rose.Interfaces.Transactional_Writable_File.Client
       .Transactional_Writable_File_Client;
   Ledger      : Rose.Interfaces.Journal.Client.Journal_Client;
   Copied      : out Rose.Capabilities.Capability;
   Count       : out Natural;
   Verbose     : Boolean := False;
   Report      : out String;
   Report_Last : out Natural;
   Note        : String := "none");
