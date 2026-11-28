package Idle.Names is

   function Ada_Name (Name : String) return String;
   --  Name with the first letter of each word in upper case and the rest
   --  in lower case, where words are separated by "_" or ".": Set_Timer
   --  stays Set_Timer, and ATA becomes Ata. This is the rule the current
   --  IDL compiler uses, so generated names stay the same.

   function Simple_Name (Name : String) return String;
   --  The last part of a dotted name, as an Ada name: Storage.Bank gives
   --  Bank. Generated identifiers, such as Bank_Client, are made from it,
   --  and units, such as Rose.Interfaces.Storage.Bank, from the whole
   --  name (Rose ADR 0034).

   function Group_Name (Name : String) return String;
   --  The part of a dotted name before its last dot, as an Ada name:
   --  Storage.Bank gives Storage, and a name without a dot gives "".

   function Versioned (Name : String; Version : Natural) return String;
   --  Name, followed by "@" and Version if Version is not zero, as a type
   --  is written in IDL: File_Info@2 (idle#114).

   function Key (Name : String) return String;
   --  Name in lower case, for comparing names, which IDL does without
   --  regard to case.

   function File_Key (Name : String) return String;
   --  The base name of the file that declares Name, as GNAT names Ada
   --  units: Name in lower case with each "." replaced by "-", so
   --  Rose.Core.Echo is in rose-core-echo.idl.

end Idle.Names;
