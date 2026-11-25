with Rose.Interfaces.File;
with Rose.Interfaces.Stream_Reader;
with Rose.Interfaces.Stream_Writer;
with Rose.Interfaces.Writable_Directory;

procedure Rose.Core.Scan
  (Logging : in out Rose.Interfaces.Stream_Writer.Stream_Writer_Object'Class;
   Source  : in out Rose.Interfaces.File.File_Object'Class;
   Input   : in out Rose.Interfaces.Stream_Reader.Stream_Reader_Object'Class;
   Root    : in out
     Rose.Interfaces.Writable_Directory.Writable_Directory_Object'Class;
   Verbose : Boolean := False);
