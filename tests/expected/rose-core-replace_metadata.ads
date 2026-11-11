package Rose.Core.Replace_Metadata is

   Text : constant String :=
     "rose-command 1"
     & ASCII.LF
     & "command Rose.Core.Replace"
     & ASCII.LF
     & "name replace"
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
     & "help-footer Full documentation: help replace"
     & ASCII.LF
     & "summary Serve a name that a new version can take over."
     & ASCII.LF
     & "role Create_Endpoint"
     & ASCII.LF
     & "role Cap_Set_Service"
     & ASCII.LF
     & "system create-endpoint 0"
     & ASCII.LF
     & "cap Cap_Set_Service Constructor 1"
     & ASCII.LF
     & "argument Result"
     & ASCII.LF
     & "type interface Named"
     & ASCII.LF
     & "mode out"
     & ASCII.LF
     & "result cap 0"
     & ASCII.LF
     & "help the interface that is served"
     & ASCII.LF
     & "argument Previous"
     & ASCII.LF
     & "type interface Replaceable"
     & ASCII.LF
     & "place cap 2"
     & ASCII.LF
     & "help the version of the server that this one replaces, or "
     & "none"
     & ASCII.LF
     & "previous cap 2"
     & ASCII.LF
     with Linker_Section => ".rose_command";

end Rose.Core.Replace_Metadata;
