package Idle.Tokens is

   type Token is
     (Tok_End_Of_File, Tok_Bad_Character,

      Tok_Identifier, Tok_Integer_Literal, Tok_String_Literal,
      Tok_Character_Literal,

      --  Keywords

      Tok_Command, Tok_Constant, Tok_End, Tok_Function, Tok_In,
      Tok_Interface, Tok_Is, Tok_New, Tok_Out, Tok_Package, Tok_Procedure,
      Tok_Range, Tok_Record, Tok_Return, Tok_Role, Tok_Type, Tok_With,

      --  Symbols

      Tok_Left_Paren, Tok_Right_Paren, Tok_Semicolon, Tok_Colon, Tok_Comma,
      Tok_Dot, Tok_Dot_Dot, Tok_Arrow, Tok_Becomes, Tok_Apostrophe,
      Tok_Ampersand);

   subtype Keyword_Token is Token range Tok_Command .. Tok_With;

   function Keyword_Text (Item : Keyword_Token) return String;
   --  The keyword as it is written, in lower case: "interface" for
   --  Tok_Interface.

   function Description (Item : Token) return String;
   --  How Item is named in error messages, such as "';'" or "identifier".

end Idle.Tokens;
