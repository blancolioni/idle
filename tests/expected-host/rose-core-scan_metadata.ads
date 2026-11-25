package Rose.Core.Scan_Metadata is

   Text : constant String :=
     "rose-command 1"
     & ASCII.LF
     & "command Rose.Core.Scan"
     & ASCII.LF
     & "name scan"
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
     & "help-footer Full documentation: help scan"
     & ASCII.LF
     & "summary Scan a file."
     & ASCII.LF
     & "role Standard_Output"
     & ASCII.LF
     & "role Logging"
     & ASCII.LF
     & "stream output 0"
     & ASCII.LF
     & "cap Logging Stream_Writer 1"
     & ASCII.LF
     & "argument Source"
     & ASCII.LF
     & "type interface File"
     & ASCII.LF
     & "place cap 2"
     & ASCII.LF
     & "help the file to scan"
     & ASCII.LF
     & "argument Input"
     & ASCII.LF
     & "type interface Stream_Reader"
     & ASCII.LF
     & "place cap 3"
     & ASCII.LF
     & "default Standard_Input"
     & ASCII.LF
     & "help what to scan after the file"
     & ASCII.LF
     & "argument Root"
     & ASCII.LF
     & "type interface Writable_Directory"
     & ASCII.LF
     & "place cap 4"
     & ASCII.LF
     & "help where to look"
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
     & ASCII.LF;

end Rose.Core.Scan_Metadata;
