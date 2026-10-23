with Ada.Characters.Handling;

package body Idle.Tokens is

   -----------------
   -- Description --
   -----------------

   function Description (Item : Token) return String is
   begin
      case Item is
         when Tok_End_Of_File       => return "end of file";
         when Tok_Bad_Character     => return "bad character";
         when Tok_Identifier        => return "identifier";
         when Tok_Integer_Literal   => return "integer literal";
         when Tok_String_Literal    => return "string literal";
         when Tok_Character_Literal => return "character literal";
         when Keyword_Token         => return "'" & Keyword_Text (Item) & "'";
         when Tok_Left_Paren        => return "'('";
         when Tok_Right_Paren       => return "')'";
         when Tok_Semicolon         => return "';'";
         when Tok_Colon             => return "':'";
         when Tok_Comma             => return "','";
         when Tok_Dot               => return "'.'";
         when Tok_Dot_Dot           => return "'..'";
         when Tok_Arrow             => return "'=>'";
         when Tok_Becomes           => return "':='";
         when Tok_Apostrophe        => return "''''";
         when Tok_Ampersand         => return "'&'";
      end case;
   end Description;

   ------------------
   -- Keyword_Text --
   ------------------

   function Keyword_Text (Item : Keyword_Token) return String is
      Image : constant String := Token'Image (Item);
   begin
      --  Strip the "TOK_" prefix.
      return Ada.Characters.Handling.To_Lower
        (Image (Image'First + 4 .. Image'Last));
   end Keyword_Text;

end Idle.Tokens;
