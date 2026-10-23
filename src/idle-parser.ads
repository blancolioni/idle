with Idle.Syntax;

package Idle.Parser is

   function Parse_File
     (Path : String)
      return Idle.Syntax.Interface_Declaration;
   --  Parse the interface declared in Path. Errors are reported through
   --  Idle.Diagnostics, and the result may then be incomplete.

end Idle.Parser;
