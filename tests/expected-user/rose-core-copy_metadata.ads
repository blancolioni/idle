package Rose.Core.Copy_Metadata is

   Text : constant String :=
     "rose-command 1"
     & ASCII.LF
     & "command Rose.Core.Copy"
     & ASCII.LF
     & "name copy"
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
     & "help-footer Full documentation: help copy"
     & ASCII.LF
     & "summary Copy a file."
     & ASCII.LF
     & "role Standard_Error"
     & ASCII.LF
     & "role Logging"
     & ASCII.LF
     & "role Create_Endpoint"
     & ASCII.LF
     & "role Delete_Cap"
     & ASCII.LF
     & "stream error 0"
     & ASCII.LF
     & "cap Logging Stream_Writer 1"
     & ASCII.LF
     & "system create-endpoint 2"
     & ASCII.LF
     & "system delete-cap 3"
     & ASCII.LF
     & "argument Source"
     & ASCII.LF
     & "type interface File"
     & ASCII.LF
     & "place cap 4"
     & ASCII.LF
     & "help the file to copy"
     & ASCII.LF
     & "argument Target"
     & ASCII.LF
     & "type interface Writable_File"
     & ASCII.LF
     & "versioned true"
     & ASCII.LF
     & "place cap 5"
     & ASCII.LF
     & "help the new file"
     & ASCII.LF
     & "argument Root"
     & ASCII.LF
     & "type interface Writable_Directory"
     & ASCII.LF
     & "versioned true"
     & ASCII.LF
     & "place cap 6"
     & ASCII.LF
     & "help where the new file goes"
     & ASCII.LF
     & "argument Copied"
     & ASCII.LF
     & "type interface Writable_File"
     & ASCII.LF
     & "mode out"
     & ASCII.LF
     & "result cap 0"
     & ASCII.LF
     & "help the copy"
     & ASCII.LF
     & "argument Count"
     & ASCII.LF
     & "type Natural"
     & ASCII.LF
     & "mode out"
     & ASCII.LF
     & "result word 1"
     & ASCII.LF
     & "help the number of bytes copied"
     & ASCII.LF
     & "argument Verbose"
     & ASCII.LF
     & "type Boolean"
     & ASCII.LF
     & "place word 0"
     & ASCII.LF
     & "default False"
     & ASCII.LF
     & "short v"
     & ASCII.LF
     & "help report progress"
     & ASCII.LF
     & "argument Report"
     & ASCII.LF
     & "type String"
     & ASCII.LF
     & "mode out"
     & ASCII.LF
     & "result item 1"
     & ASCII.LF
     & "help a summary of the copy"
     & ASCII.LF
     & "argument Note"
     & ASCII.LF
     & "type String"
     & ASCII.LF
     & "place item 1"
     & ASCII.LF
     & "default none"
     & ASCII.LF
     & "help a note"
     & ASCII.LF
     with Linker_Section => ".rose_command";

end Rose.Core.Copy_Metadata;
