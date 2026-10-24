with Ada.Characters.Handling;
with Ada.Containers.Indefinite_Vectors;
with Ada.Characters.Latin_1;

package body Idle.Lexer is

   use Ada.Strings.Unbounded;
   use Idle.Tokens;

   function Is_Identifier_Start (Ch : Character) return Boolean
   is (Ada.Characters.Handling.Is_Letter (Ch));

   function Is_Identifier_Body (Ch : Character) return Boolean
   is (Ada.Characters.Handling.Is_Alphanumeric (Ch) or else Ch = '_');

   function Keyword_Or_Identifier (Text : String) return Token;
   --  The keyword Text is, ignoring case, or Tok_Identifier.

   ---------------------------
   -- Keyword_Or_Identifier --
   ---------------------------

   function Keyword_Or_Identifier (Text : String) return Token is
      Lower : constant String := Ada.Characters.Handling.To_Lower (Text);
   begin
      for Keyword in Keyword_Token loop
         if Lower = Keyword_Text (Keyword) then
            return Keyword;
         end if;
      end loop;
      return Tok_Identifier;
   end Keyword_Or_Identifier;

   --------------
   -- Tokenize --
   --------------

   procedure Tokenize
     (Source   : String;
      Tokens   : out Token_Vectors.Vector;
      Problems : out Problem_Vectors.Vector)
   is
      Index  : Natural := Source'First;
      Line   : Positive := 1;
      Column : Positive := 1;

      function At_End return Boolean is (Index > Source'Last);

      function Peek (Ahead : Natural := 0) return Character
      is (if Index + Ahead <= Source'Last then Source (Index + Ahead)
          else Ada.Characters.Latin_1.NUL);

      procedure Advance (Count : Positive := 1);
      procedure Add
        (Kind        : Token;
         Text        : String;
         Line_Start  : Positive;
         Column_Start : Positive);
      procedure Report
        (Message      : String;
         Line_Start   : Positive;
         Column_Start : Positive);

      procedure Scan_Text_Block
        (Line_Start   : Positive;
         Column_Start : Positive);
      --  A text block: the opening quotes, a line break, any number of
      --  lines, and the closing quotes, first on their line, where other
      --  tokens can follow them. Its value is the lines, with the
      --  indentation common to every non-blank line removed, joined by
      --  line breaks.

      ---------
      -- Add --
      ---------

      procedure Add
        (Kind        : Token;
         Text        : String;
         Line_Start  : Positive;
         Column_Start : Positive)
      is
      begin
         Tokens.Append
           (Token_Info'(Kind, To_Unbounded_String (Text),
                        Line_Start, Column_Start));
      end Add;

      -------------
      -- Advance --
      -------------

      procedure Advance (Count : Positive := 1) is
      begin
         for I in 1 .. Count loop
            if not At_End then
               if Source (Index) = Ada.Characters.Latin_1.LF then
                  Line := Line + 1;
                  Column := 1;
               else
                  Column := Column + 1;
               end if;
               Index := Index + 1;
            end if;
         end loop;
      end Advance;

      ------------
      -- Report --
      ------------

      procedure Report
        (Message      : String;
         Line_Start   : Positive;
         Column_Start : Positive)
      is
      begin
         Problems.Append
           (Problem'(Line_Start, Column_Start,
                     To_Unbounded_String (Message)));
      end Report;

      ---------------------
      -- Scan_Text_Block --
      ---------------------

      procedure Scan_Text_Block
        (Line_Start   : Positive;
         Column_Start : Positive)
      is
         package Line_Vectors is
           new Ada.Containers.Indefinite_Vectors (Positive, String);

         Lines      : Line_Vectors.Vector;
         Terminated : Boolean := False;
         Common     : Natural := Natural'Last;
         Result     : Unbounded_String;

         function Is_Blank (Text : String) return Boolean
         is (for all Ch of Text => Ch = ' ');

         function Indent (Text : String) return Natural;
         --  The number of spaces at the start of Text.

         ------------
         -- Indent --
         ------------

         function Indent (Text : String) return Natural is
            Count : Natural := 0;
         begin
            for Ch of Text loop
               exit when Ch /= ' ';
               Count := Count + 1;
            end loop;
            return Count;
         end Indent;

      begin
         Advance (3);
         while not At_End and then Peek = ' ' loop
            Advance;
         end loop;
         if Peek = Ada.Characters.Latin_1.CR then
            Advance;
         end if;
         if Peek = Ada.Characters.Latin_1.LF then
            Advance;
         elsif not At_End then
            Report ("a text block starts on the line after its opening"
                    & " quotes", Line, Column);
         end if;

         while not At_End loop
            declare
               First : constant Positive := Index;
               Last  : Natural;
            begin
               while Peek = ' ' loop
                  Advance;
               end loop;
               if Peek = '"' and then Peek (1) = '"' and then Peek (2) = '"'
               then
                  Advance (3);
                  Terminated := True;
                  exit;
               end if;
               while not At_End
                 and then Peek /= Ada.Characters.Latin_1.LF
               loop
                  Advance;
               end loop;
               Last := Index - 1;
               if Last >= First
                 and then Source (Last) = Ada.Characters.Latin_1.CR
               then
                  Last := Last - 1;
               end if;
               Lines.Append (Source (First .. Last));
               Advance;
            end;
         end loop;

         if not Terminated then
            Report ("unterminated text block", Line_Start, Column_Start);
         end if;

         for Text of Lines loop
            if not Is_Blank (Text) then
               Common := Natural'Min (Common, Indent (Text));
            end if;
         end loop;

         for Index in 1 .. Lines.Last_Index loop
            declare
               Text : constant String := Lines (Index);
            begin
               if Index > 1 then
                  Append (Result, Ada.Characters.Latin_1.LF);
               end if;
               if not Is_Blank (Text) then
                  Append (Result, Text (Text'First + Common .. Text'Last));
               end if;
            end;
         end loop;

         Add (Tok_String_Literal, To_String (Result),
              Line_Start, Column_Start);
      end Scan_Text_Block;

   begin
      Tokens.Clear;
      Problems.Clear;

      while not At_End loop
         declare
            Ch           : constant Character := Peek;
            Start        : constant Positive := Index;
            Start_Line   : constant Positive := Line;
            Start_Column : constant Positive := Column;
         begin
            if Ch = ' ' or else Ch = Ada.Characters.Latin_1.HT
              or else Ch = Ada.Characters.Latin_1.LF
              or else Ch = Ada.Characters.Latin_1.CR
            then
               Advance;

            elsif Ch = '-' and then Peek (1) = '-' then
               while not At_End
                 and then Peek /= Ada.Characters.Latin_1.LF
               loop
                  Advance;
               end loop;

            elsif Is_Identifier_Start (Ch) then
               while not At_End and then Is_Identifier_Body (Peek) loop
                  Advance;
               end loop;
               declare
                  Text : constant String := Source (Start .. Index - 1);
               begin
                  Add (Keyword_Or_Identifier (Text), Text,
                       Start_Line, Start_Column);
               end;

            elsif Ada.Characters.Handling.Is_Digit (Ch) then
               while not At_End
                 and then (Ada.Characters.Handling.Is_Digit (Peek)
                           or else Peek = '_')
               loop
                  Advance;
               end loop;
               if Peek = '#' then
                  Advance;
                  while not At_End
                    and then (Ada.Characters.Handling.Is_Hexadecimal_Digit
                                (Peek)
                              or else Peek = '_')
                  loop
                     Advance;
                  end loop;
                  if Peek = '#' then
                     Advance;
                  else
                     Report ("missing '#' at end of based literal",
                             Start_Line, Start_Column);
                  end if;
               end if;
               Add (Tok_Integer_Literal, Source (Start .. Index - 1),
                    Start_Line, Start_Column);

            elsif Ch = '"' and then Peek (1) = '"' and then Peek (2) = '"'
            then
               Scan_Text_Block (Start_Line, Start_Column);

            elsif Ch = '"' then
               declare
                  Text       : Unbounded_String;
                  Terminated : Boolean := False;
               begin
                  Advance;
                  while not At_End
                    and then Peek /= Ada.Characters.Latin_1.LF
                  loop
                     if Peek = '"' then
                        if Peek (1) = '"' then
                           Append (Text, '"');
                           Advance (2);
                        else
                           Advance;
                           Terminated := True;
                           exit;
                        end if;
                     else
                        Append (Text, Peek);
                        Advance;
                     end if;
                  end loop;
                  if not Terminated then
                     Report ("unterminated string literal",
                             Start_Line, Start_Column);
                  end if;
                  Add (Tok_String_Literal, To_String (Text),
                       Start_Line, Start_Column);
               end;

            elsif Ch = '''
              and then Peek (2) = '''
              and then (Tokens.Is_Empty
                        or else Tokens.Last_Element.Kind
                          not in Tok_Identifier | Tok_Right_Paren)
            then
               --  A character literal, unless the apostrophe follows a
               --  name, where it introduces an attribute.
               Add (Tok_Character_Literal, [1 => Peek (1)],
                    Start_Line, Start_Column);
               Advance (3);

            else
               declare
                  Two  : constant String := [Ch, Peek (1)];
                  Kind : Token := Tok_Bad_Character;
                  Size : Positive := 2;
               begin
                  if Two = ".." then
                     Kind := Tok_Dot_Dot;
                  elsif Two = "=>" then
                     Kind := Tok_Arrow;
                  elsif Two = ":=" then
                     Kind := Tok_Becomes;
                  else
                     Size := 1;
                     case Ch is
                        when '(' => Kind := Tok_Left_Paren;
                        when ')' => Kind := Tok_Right_Paren;
                        when ';' => Kind := Tok_Semicolon;
                        when ':' => Kind := Tok_Colon;
                        when ',' => Kind := Tok_Comma;
                        when '.' => Kind := Tok_Dot;
                        when ''' => Kind := Tok_Apostrophe;
                        when '&' => Kind := Tok_Ampersand;
                        when others => null;
                     end case;
                  end if;

                  if Kind = Tok_Bad_Character then
                     Report ("unexpected character '" & Ch & "'",
                             Start_Line, Start_Column);
                  end if;

                  Add (Kind, Source (Start .. Start + Size - 1),
                       Start_Line, Start_Column);
                  Advance (Size);
               end;
            end if;
         end;
      end loop;

      Add (Tok_End_Of_File, "", Line, Column);
   end Tokenize;

end Idle.Lexer;
