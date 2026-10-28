package Rose.Core.Touch_Metadata is

   Text : constant String :=
     "rose-command 1"
     & ASCII.LF
     & "command Rose.Core.Touch"
     & ASCII.LF
     & "name touch"
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
     & "help-footer Full documentation: help touch"
     & ASCII.LF
     & "summary Create an empty file."
     & ASCII.LF
     & "live true"
     & ASCII.LF
     & "argument Name"
     & ASCII.LF
     & "type String"
     & ASCII.LF
     & "place item 1"
     & ASCII.LF
     & "help the name of the new file"
     & ASCII.LF
     & "argument Directory"
     & ASCII.LF
     & "type interface Writable_Directory"
     & ASCII.LF
     & "versioned true"
     & ASCII.LF
     & "place cap 0"
     & ASCII.LF
     & "help the directory to create it in"
     & ASCII.LF
     with Linker_Section => ".rose_command";

end Rose.Core.Touch_Metadata;
