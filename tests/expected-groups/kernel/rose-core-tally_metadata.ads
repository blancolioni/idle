package Rose.Core.Tally_Metadata is

   Text : constant String :=
     "rose-command 1"
     & ASCII.LF
     & "command Rose.Core.Tally"
     & ASCII.LF
     & "name tally"
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
     & "help-footer Full documentation: help tally"
     & ASCII.LF
     & "summary Count a label."
     & ASCII.LF
     & "role Measures.Counter_Service"
     & ASCII.LF
     & "cap Counter_Service Measures.Counter 0"
     & ASCII.LF
     & "category Measures.Counter_Service measures"
     & ASCII.LF
     & "argument Label"
     & ASCII.LF
     & "type interface Common.Named"
     & ASCII.LF
     & "place cap 1"
     & ASCII.LF
     & "help what to count"
     & ASCII.LF
     with Linker_Section => ".rose_command";

end Rose.Core.Tally_Metadata;
