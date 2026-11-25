with Rose.Interfaces.File;
with Rose.Interfaces.Stream_Reader;

procedure Rose.Core.Edit
  (Doc   : in out Rose.Interfaces.File.File_Object'Class;
   Lines : Natural := 0;
   Input : in out Rose.Interfaces.Stream_Reader.Stream_Reader_Object'Class);
