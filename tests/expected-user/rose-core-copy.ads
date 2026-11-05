with Rose.Capabilities;
with Rose.Command_Line;
with Rose.Interfaces.File;
with Rose.Interfaces.Journal;
with Rose.Interfaces.Stream_Writer;
with Rose.Interfaces.Transactional;
with Rose.Interfaces.Transactional_Writable_File;
with Rose.Interfaces.Writable_Directory;
with Rose.Interfaces.Writable_File;

procedure Rose.Core.Copy
  (Logging : in out Rose.Interfaces.Stream_Writer.Stream_Writer_Object'Class;
   Source  : in out Rose.Interfaces.File.File_Object'Class;
   Target  : in out Rose.Interfaces.Writable_File.Writable_File_Object'Class;
   Root    : in out
     Rose.Interfaces.Writable_Directory.Writable_Directory_Object'Class;
   Batch   : in out Rose.Interfaces.Transactional.Transactional_Object'Class;
   Draft   : in out
     Rose.Interfaces.Transactional_Writable_File
       .Transactional_Writable_File_Object'Class;
   Ledger  : in out Rose.Interfaces.Journal.Journal_Object'Class;
   Copied  : out Rose.Capabilities.Capability;
   Count   : out Natural;
   Verbose : Boolean := False;
   Report  : out Rose.Command_Line.Text;
   Note    : String := "none");
