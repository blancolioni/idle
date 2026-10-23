with Ada.Containers.Vectors;
with Ada.Strings.Unbounded;

with Idle.Tokens;

package Idle.Lexer is

   --  Turning source text into tokens. A whole source is tokenized at
   --  once; Idle.Lexical gives the parser its view of the result.

   type Token_Info is record
      Kind   : Idle.Tokens.Token;
      Text   : Ada.Strings.Unbounded.Unbounded_String;
      Line   : Positive;
      Column : Positive;
   end record;
   --  Text is the token as written. For a string literal it is the
   --  contents, with doubled quotation marks undoubled; for a character
   --  literal it is the character.

   package Token_Vectors is
     new Ada.Containers.Vectors (Positive, Token_Info);

   type Problem is record
      Line    : Positive;
      Column  : Positive;
      Message : Ada.Strings.Unbounded.Unbounded_String;
   end record;

   package Problem_Vectors is
     new Ada.Containers.Vectors (Positive, Problem);

   procedure Tokenize
     (Source   : String;
      Tokens   : out Token_Vectors.Vector;
      Problems : out Problem_Vectors.Vector);
   --  The tokens of Source, always ending with Tok_End_Of_File, and any
   --  lexical errors found.

end Idle.Lexer;
