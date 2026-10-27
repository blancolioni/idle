package Rose.Core.Serve_Metadata is

   Text : constant String :=
     "rose-command 1"
     & ASCII.LF
     & "command Rose.Core.Serve"
     & ASCII.LF
     & "name serve"
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
     & "help-footer Full documentation: help serve"
     & ASCII.LF
     & "summary Serve a name."
     & ASCII.LF
     & "role Create_Endpoint"
     & ASCII.LF
     & "system create-endpoint 0"
     & ASCII.LF
     & "argument Name"
     & ASCII.LF
     & "type String"
     & ASCII.LF
     & "place item 1"
     & ASCII.LF
     & "help the name to serve"
     & ASCII.LF
     & "argument Home"
     & ASCII.LF
     & "type interface Directory"
     & ASCII.LF
     & "place cap 1"
     & ASCII.LF
     & "help a directory, whose mode is a right"
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
     with Linker_Section => ".rose_command";

end Rose.Core.Serve_Metadata;
