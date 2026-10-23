package Idle.Diagnostics is

   --  Errors and warnings, written to standard error as
   --  "file:line:column: error: message".

   procedure Error
     (File_Name : String;
      Line      : Natural;
      Column    : Natural;
      Message   : String);
   --  Line and Column are omitted from the message when zero.

   procedure Warning
     (File_Name : String;
      Line      : Natural;
      Column    : Natural;
      Message   : String);

   function Error_Count return Natural;

end Idle.Diagnostics;
