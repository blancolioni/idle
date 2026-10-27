package Rose.Core.Show_Metadata is

   Text : constant String :=
     "rose-command 1"
     & ASCII.LF
     & "command Rose.Core.Show"
     & ASCII.LF
     & "name show"
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
     & "help-footer Full documentation: help show"
     & ASCII.LF
     & "summary Show a file."
     & ASCII.LF
     & "role Standard_Output"
     & ASCII.LF
     & "role Logging"
     & ASCII.LF
     & "role Delete_Cap"
     & ASCII.LF
     & "stream output 0"
     & ASCII.LF
     & "cap Logging Stream_Writer 1"
     & ASCII.LF
     & "system delete-cap 2"
     & ASCII.LF
     & "argument Source"
     & ASCII.LF
     & "type interface File"
     & ASCII.LF
     & "place cap 3"
     & ASCII.LF
     & "help the file to show"
     & ASCII.LF
     & "argument Count"
     & ASCII.LF
     & "type Natural"
     & ASCII.LF
     & "mode out"
     & ASCII.LF
     & "result word 1"
     & ASCII.LF
     & "help the number of bytes shown"
     & ASCII.LF
     with Linker_Section => ".rose_command";

end Rose.Core.Show_Metadata;
