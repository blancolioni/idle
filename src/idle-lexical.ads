with Idle.Tokens; use Idle.Tokens;

package Idle.Lexical is

   --  The parser's view of the token stream: the current token, some
   --  lookahead, and diagnostics against the current token's position.
   --
   --  Sources nest, since a declaration's parents and packages are read
   --  while its own file is still open, so Open and Close keep a stack and
   --  every query is about the innermost source. Each source is tokenized
   --  in full when it is opened, and its lexical errors reported then.
   --
   --  With no source open, Tok is Tok_End_Of_File.

   type Token_Set is array (Positive range <>) of Token;

   function "<=" (Left : Token; Right : Token_Set) return Boolean
   is (for some T of Right => T = Left);

   procedure Open (Path : String);
   --  Open the source file Path. If it cannot be read, report an error
   --  and open an empty source.

   procedure Close;

   function Tok return Token;
   function Tok_Text return String;
   function Tok_Line return Natural;
   function Tok_Column return Natural;
   function File_Name return String;

   function Next_Tok (Ahead : Positive := 1) return Token;

   procedure Scan;
   --  Move past the current token. At the end of the source, stay there.

   procedure Expect
     (T          : Token;
      Skip_Up_To : Token_Set);
   --  If T is the current token, scan past it. Otherwise report it as
   --  missing and skip to T or anything in Skip_Up_To, scanning past T if
   --  that is where it stopped.

   procedure Skip_To (Stop : Token_Set);
   --  Skip to the next token in Stop, or the end of the source.

   procedure Error (Message : String);
   --  Report Message at the current token.

end Idle.Lexical;
