with Rose.Command_Line;
with Rose.Interfaces.Directory;
with Rose.Interfaces.File;
with Rose.Interfaces.Stream_Writer;

procedure Rose.Core.Copy
  (Logging : in out Rose.Interfaces.Stream_Writer.Stream_Writer_Object'Class;
   Source  : in out Rose.Interfaces.File.File_Object'Class;
   Target  : in out Rose.Interfaces.File.File_Object'Class;
   Root    : in out Rose.Interfaces.Directory.Directory_Object'Class;
   Count   : out Natural;
   Verbose : in out Boolean;
   Report  : out Rose.Command_Line.Text;
   Note    : in out Rose.Command_Line.Text);
