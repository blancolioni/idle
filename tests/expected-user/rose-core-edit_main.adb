with Rose.Command_Line.Launch;
with Rose.Core.Edit;
with Rose.Core.Edit_Metadata;
with Rose.Interfaces.File.Client;
with Rose.Interfaces.Seekable_File_Reader.Client;
with Rose.Interfaces.Stream_Reader.Client;
with Rose.Interfaces.Transactional_Writable_File.Client;
with Rose.Interfaces.Writable_File.Client;
pragma Unreferenced (Rose.Core.Edit_Metadata);

procedure Rose.Core.Edit_Main is
   Call                            : Rose.Command_Line.Launch.Launch_Call;
   type Doc_Access is access all Rose.Interfaces.File.File_Object'Class;
   Doc_File                        : aliased Rose.Interfaces.File.Client
     .File_Client;
   Doc_Writable_File               : aliased Rose.Interfaces.Writable_File
     .Client
     .Writable_File_Client;
   Doc_Transactional_Writable_File : aliased Rose.Interfaces
     .Transactional_Writable_File
     .Client
     .Transactional_Writable_File_Client;
   Doc                             : Doc_Access;
   type Input_Access is
     access all Rose.Interfaces.Stream_Reader.Stream_Reader_Object'Class;
   Input_Stream_Reader             : aliased Rose.Interfaces.Stream_Reader
     .Client
     .Stream_Reader_Client;
   Input_Seekable_File_Reader      : aliased Rose.Interfaces
     .Seekable_File_Reader
     .Client
     .Seekable_File_Reader_Client;
   Input                           : Input_Access;
begin
   Rose.Command_Line.Launch.Receive (Call);
   Rose.Command_Line.Launch.Use_Standard_Error (Call, 0);
   if Rose.Command_Line.Launch.Natural_Argument (Call, 0) = 0 then
      Rose.Interfaces.File.Client.Open
        (Doc_File,
         Rose.Command_Line.Launch.Cap_Argument (Call, 1));
      Doc := Doc_File'Access;
   else
      if Rose.Command_Line.Launch.Natural_Argument (Call, 0) = 1 then
         Rose.Interfaces.Writable_File.Client.Open
           (Doc_Writable_File,
            Rose.Command_Line.Launch.Cap_Argument (Call, 1));
         Doc := Doc_Writable_File'Access;
      else
         if Rose.Command_Line.Launch.Natural_Argument (Call, 0) = 2 then
            Rose.Interfaces.Transactional_Writable_File.Client.Open
              (Doc_Transactional_Writable_File,
               Rose.Command_Line.Launch.Cap_Argument (Call, 1));
            Doc := Doc_Transactional_Writable_File'Access;
         else
            raise Constraint_Error with "Doc: no such interface in its list";
         end if;
      end if;
   end if;
   if Rose.Command_Line.Launch.Natural_Argument (Call, 2) = 0 then
      Rose.Interfaces.Stream_Reader.Client.Open_Cap_Set
        (Input_Stream_Reader,
         Rose.Command_Line.Launch.Cap_Argument (Call, 2));
      Input := Input_Stream_Reader'Access;
   else
      if Rose.Command_Line.Launch.Natural_Argument (Call, 2) = 1 then
         Rose.Interfaces.Seekable_File_Reader.Client.Open
           (Input_Seekable_File_Reader,
            Rose.Command_Line.Launch.Cap_Argument (Call, 2));
         Input := Input_Seekable_File_Reader'Access;
      else
         raise Constraint_Error with "Input: no such interface in its list";
      end if;
   end if;
   Rose.Command_Line.Launch.Set_Command_Line ("Rose.Core.Edit");
   Rose.Core.Edit
     (Doc => Doc.all,
      Lines => Rose.Command_Line.Launch.Natural_Argument (Call, 1),
      Input => Input.all);
   Rose.Command_Line.Launch.Complete (Call);
end Rose.Core.Edit_Main;
