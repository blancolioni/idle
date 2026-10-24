package Idle.Names is

   function Ada_Name (Name : String) return String;
   --  Name with the first letter of each word in upper case and the rest
   --  in lower case, where words are separated by "_" or ".": Set_Timer
   --  stays Set_Timer, and ATA becomes Ata. This is the rule the current
   --  IDL compiler uses, so generated names stay the same.

   function Key (Name : String) return String;
   --  Name in lower case, for comparing names, which IDL does without
   --  regard to case.

   function File_Key (Name : String) return String;
   --  The base name of the file that declares Name, as GNAT names Ada
   --  units: Name in lower case with each "." replaced by "-", so
   --  Rose.Core.Echo is in rose-core-echo.idl.

end Idle.Names;
