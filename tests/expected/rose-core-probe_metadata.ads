package Rose.Core.Probe_Metadata is

   Text : constant String :=
     "rose-command 1"
     & ASCII.LF
     & "command Rose.Core.Probe"
     & ASCII.LF
     & "name probe"
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
     & "help-footer Full documentation: help probe"
     & ASCII.LF
     & "summary Show what a command's roles need."
     & ASCII.LF
     & "role Probe_Roles"
     & ASCII.LF
     & "role Standard_Error"
     & ASCII.LF
     & "cap Time_Log Stream_Writer 0"
     & ASCII.LF
     & "category Time_Log time"
     & ASCII.LF
     & "cap Port_Log Stream_Writer 1"
     & ASCII.LF
     & "category Port_Log hardware.ports"
     & ASCII.LF
     & "stream output 2"
     & ASCII.LF
     & "stream error 3"
     & ASCII.LF
     with Linker_Section => ".rose_command";

end Rose.Core.Probe_Metadata;
