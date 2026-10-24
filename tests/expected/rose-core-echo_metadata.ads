package Rose.Core.Echo_Metadata is

   Text : constant String :=
     "rose-command 1"
     & ASCII.LF
     & "command Rose.Core.Echo"
     & ASCII.LF
     & "name echo"
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
     & "help-footer Full documentation: help echo"
     & ASCII.LF
     & "summary Write the arguments to standard output."
     & ASCII.LF
     & "description Echo writes its arguments to standard output, "
     & "separated by\nsingle spaces and followed by a line break."
     & ASCII.LF
     & "role Standard_Output"
     & ASCII.LF
     & "stream output 0"
     & ASCII.LF
     & "argument New_Line"
     & ASCII.LF
     & "type Boolean"
     & ASCII.LF
     & "place word 0"
     & ASCII.LF
     & "default True"
     & ASCII.LF
     & "short n"
     & ASCII.LF
     & "short-value False"
     & ASCII.LF
     & "help end the output with a line break (-n: do not)"
     & ASCII.LF
     & "argument Arguments"
     & ASCII.LF
     & "type String_List"
     & ASCII.LF
     & "place list 1 word 1"
     & ASCII.LF
     & "help the words to write"
     & ASCII.LF
     with Linker_Section => ".rose_command";

end Rose.Core.Echo_Metadata;
