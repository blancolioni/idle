package Rose.Core.Head_Metadata is

   Text : constant String :=
     "rose-command 1"
     & ASCII.LF
     & "command Rose.Core.Head"
     & ASCII.LF
     & "name first"
     & ASCII.LF
     & "package Rose.Core"
     & ASCII.LF
     & "title Rose core utilities"
     & ASCII.LF
     & "version 0.1.0"
     & ASCII.LF
     & "copyright Copyright (C) 2026 The Rose authors"
     & ASCII.LF
     & "authors Someone Else"
     & ASCII.LF
     & "license License GPLv3+: GNU GPL version 3 or later.\nThis "
     & "is free software: you are free to change and redistribute "
     & "it.\nThere is NO WARRANTY, to the extent permitted by law."
     & ASCII.LF
     & "help-footer Full documentation: help first"
     & ASCII.LF
     & "summary Copy the first lines of standard input."
     & ASCII.LF
     & "role Standard_IO"
     & ASCII.LF
     & "stream input 0"
     & ASCII.LF
     & "stream output 1"
     & ASCII.LF
     & "stream error 2"
     & ASCII.LF
     & "argument Lines"
     & ASCII.LF
     & "type Positive"
     & ASCII.LF
     & "place word 0"
     & ASCII.LF
     & "default 10"
     & ASCII.LF
     & "short n"
     & ASCII.LF
     & "help the number of lines to copy"
     & ASCII.LF
     & "argument Skip"
     & ASCII.LF
     & "type Natural"
     & ASCII.LF
     & "place word 1"
     & ASCII.LF
     & "default 0"
     & ASCII.LF
     & "help the number of lines to skip first"
     & ASCII.LF
     & "argument Quiet"
     & ASCII.LF
     & "type Boolean"
     & ASCII.LF
     & "place word 2"
     & ASCII.LF
     & "default False"
     & ASCII.LF
     & "short q"
     & ASCII.LF
     & "help never write headers"
     & ASCII.LF
     & "argument Header"
     & ASCII.LF
     & "type String"
     & ASCII.LF
     & "place item 1"
     & ASCII.LF
     & "default ==> ""input"" <=="
     & ASCII.LF
     & "help the header to write before the lines"
     & ASCII.LF
     & "argument Prefix"
     & ASCII.LF
     & "type String"
     & ASCII.LF
     & "place item 2"
     & ASCII.LF
     & "help a prefix for each line"
     & ASCII.LF
     & "argument Names"
     & ASCII.LF
     & "type String_List"
     & ASCII.LF
     & "place list 3 word 3"
     & ASCII.LF
     & "help names for the input"
     & ASCII.LF
     with Linker_Section => ".rose_command";

end Rose.Core.Head_Metadata;
