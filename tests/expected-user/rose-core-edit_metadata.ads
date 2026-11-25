package Rose.Core.Edit_Metadata is

   Text : constant String :=
     "rose-command 1"
     & ASCII.LF
     & "command Rose.Core.Edit"
     & ASCII.LF
     & "name edit"
     & ASCII.LF
     & "package Rose.Core"
     & ASCII.LF
     & "title Rose core utilities"
     & ASCII.LF
     & "version 0.1.0"
     & ASCII.LF
     & "copyright Copyright (C) 2026 The Rose authors"
     & ASCII.LF
     & "authors Fraser Wilson"
     & ASCII.LF
     & "license License GPLv3+: GNU GPL version 3 or later.\nThis "
     & "is free software: you are free to change and redistribute "
     & "it.\nThere is NO WARRANTY, to the extent permitted by law."
     & ASCII.LF
     & "help-footer Full documentation: help edit"
     & ASCII.LF
     & "summary Edit or view a file."
     & ASCII.LF
     & "role Standard_Error"
     & ASCII.LF
     & "stream error 0"
     & ASCII.LF
     & "argument Doc"
     & ASCII.LF
     & "type interface File"
     & ASCII.LF
     & "accepts Writable_File"
     & ASCII.LF
     & "versioned true"
     & ASCII.LF
     & "accepts Transactional_Writable_File"
     & ASCII.LF
     & "versioned true"
     & ASCII.LF
     & "transactional true"
     & ASCII.LF
     & "place cap 1"
     & ASCII.LF
     & "selector word 0"
     & ASCII.LF
     & "help the file"
     & ASCII.LF
     & "argument Lines"
     & ASCII.LF
     & "type Natural"
     & ASCII.LF
     & "place word 1"
     & ASCII.LF
     & "default 0"
     & ASCII.LF
     & "help the number of lines to show"
     & ASCII.LF
     & "argument Input"
     & ASCII.LF
     & "type interface Stream_Reader"
     & ASCII.LF
     & "accepts Seekable_File_Reader"
     & ASCII.LF
     & "place cap 2"
     & ASCII.LF
     & "selector word 2"
     & ASCII.LF
     & "default Standard_Input"
     & ASCII.LF
     & "help where the commands come from"
     & ASCII.LF
     with Linker_Section => ".rose_command";

end Rose.Core.Edit_Metadata;
