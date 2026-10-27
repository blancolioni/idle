with Rose.Interfaces.File;
with Rose.Interfaces.Stream_Writer;

procedure Rose.Core.Show
  (Logging : in out Rose.Interfaces.Stream_Writer.Stream_Writer_Object'Class;
   Source  : in out Rose.Interfaces.File.File_Object'Class;
   Count   : out Natural);
