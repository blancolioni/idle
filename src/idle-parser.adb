with Ada.Characters.Handling;
with Ada.Strings.Unbounded;

with Idle.Lexical; use Idle.Lexical;
with Idle.Tokens;  use Idle.Tokens;

package body Idle.Parser is

   use Ada.Strings.Unbounded;
   use Idle.Syntax;

   Declaration_Start : constant Token_Set :=
                         [Tok_Function, Tok_Procedure, Tok_Type,
                          Tok_Identifier, Tok_End];
   --  Where error recovery restarts inside an interface.

   function Current_Position return Source_Position
   is ((Tok_Line, Tok_Column));

   function Parse_Name (What : String) return Unbounded_String;
   --  An identifier, or report What as missing.

   function Parse_Type_Reference return Type_Reference;

   procedure Parse_Constant (Item : in out Interface_Declaration);
   procedure Parse_Declarations (Item : in out Interface_Declaration);
   procedure Parse_Parameters (Into : in out Subprogram);
   procedure Parse_Subprogram (Item : in out Interface_Declaration);
   procedure Parse_Type_Declaration (Item : in out Interface_Declaration);

   function Same_Name (Left, Right : String) return Boolean
   is (Ada.Characters.Handling.To_Lower (Left)
       = Ada.Characters.Handling.To_Lower (Right));

   --------------------
   -- Parse_Constant --
   --------------------

   procedure Parse_Constant (Item : in out Interface_Declaration) is
      Result : Constant_Declaration;
   begin
      Result.Position := Current_Position;
      Result.Name := Parse_Name ("constant name");
      Expect (Tok_Colon, Declaration_Start);
      Expect (Tok_Constant, Declaration_Start);
      Expect (Tok_Becomes, Declaration_Start);

      if Tok in Tok_Integer_Literal | Tok_Identifier then
         Result.Value := To_Unbounded_String (Tok_Text);
         Scan;
      else
         Error ("missing value (an integer literal or a name)");
      end if;

      Expect (Tok_Semicolon, Declaration_Start);
      Item.Constants.Append (Result);
   end Parse_Constant;

   ------------------------
   -- Parse_Declarations --
   ------------------------

   procedure Parse_Declarations (Item : in out Interface_Declaration) is
   begin
      loop
         case Tok is
            when Tok_Function | Tok_Procedure =>
               Parse_Subprogram (Item);
            when Tok_Type =>
               Parse_Type_Declaration (Item);
            when Tok_Identifier =>
               Parse_Constant (Item);
            when Tok_End | Tok_End_Of_File =>
               exit;
            when others =>
               Error ("unexpected " & Description (Tok)
                      & " in interface declaration");
               Scan;
               Skip_To (Declaration_Start);
         end case;
      end loop;
   end Parse_Declarations;

   ----------------
   -- Parse_File --
   ----------------

   function Parse_File
     (Path : String)
      return Idle.Syntax.Interface_Declaration
   is
      Result : Interface_Declaration;
   begin
      Open (Path);
      Result.File_Name := To_Unbounded_String (Path);
      Result.Position := Current_Position;

      Expect (Tok_Interface, [Tok_Identifier]);
      Result.Name := Parse_Name ("interface name");

      if Tok = Tok_Colon then
         Scan;
         loop
            Result.Parents.Append (To_String (Parse_Name ("parent name")));
            exit when Tok /= Tok_Comma;
            Scan;
         end loop;
      end if;

      Expect (Tok_Is, Declaration_Start);
      Parse_Declarations (Result);
      Expect (Tok_End, [Tok_Semicolon]);

      if Tok = Tok_Identifier then
         if not Same_Name (Tok_Text, To_String (Result.Name)) then
            Error ("end name should be " & To_String (Result.Name));
         end if;
         Scan;
      else
         Error ("missing " & To_String (Result.Name) & " after 'end'");
      end if;

      Expect (Tok_Semicolon, [Tok_End_Of_File]);

      if Tok /= Tok_End_Of_File then
         Error ("unexpected " & Description (Tok)
                & " after the end of the interface");
      end if;

      Close;
      return Result;
   end Parse_File;

   ----------------
   -- Parse_Name --
   ----------------

   function Parse_Name (What : String) return Unbounded_String is
   begin
      if Tok = Tok_Identifier then
         return Result : constant Unbounded_String :=
           To_Unbounded_String (Tok_Text)
         do
            Scan;
         end return;
      else
         Error ("missing " & What);
         return Null_Unbounded_String;
      end if;
   end Parse_Name;

   ----------------------
   -- Parse_Parameters --
   ----------------------

   procedure Parse_Parameters (Into : in out Subprogram) is
   begin
      Expect (Tok_Left_Paren, [Tok_Identifier]);
      loop
         declare
            Item : Parameter;
         begin
            Item.Position := Current_Position;
            Item.Name := Parse_Name ("parameter name");
            Expect (Tok_Colon, [Tok_Identifier, Tok_Semicolon]);

            if Tok = Tok_In then
               Scan;
               if Tok = Tok_Out then
                  Scan;
                  Item.Mode := In_Out_Mode;
               end if;
            elsif Tok = Tok_Out then
               Scan;
               Item.Mode := Out_Mode;
            end if;

            Item.Of_Type := Parse_Type_Reference;
            Into.Parameters.Append (Item);
         end;

         exit when Tok /= Tok_Semicolon;
         Scan;
      end loop;
      Expect (Tok_Right_Paren, [Tok_Return, Tok_Semicolon]);
   end Parse_Parameters;

   ----------------------
   -- Parse_Subprogram --
   ----------------------

   procedure Parse_Subprogram (Item : in out Interface_Declaration) is
      Result : Subprogram;
   begin
      Result.Is_Function := Tok = Tok_Function;
      Result.Position := Current_Position;
      Scan;
      Result.Name := Parse_Name ("subprogram name");

      if Tok = Tok_Left_Paren then
         Parse_Parameters (Result);
      end if;

      if Tok = Tok_Return then
         if not Result.Is_Function then
            Error ("a procedure cannot return a value");
         end if;
         Scan;
         Result.Result := Parse_Type_Reference;
      elsif Result.Is_Function then
         Error ("missing 'return' and result type");
      end if;

      Expect (Tok_Semicolon, Declaration_Start);
      Item.Subprograms.Append (Result);
   end Parse_Subprogram;

   ----------------------------
   -- Parse_Type_Declaration --
   ----------------------------

   procedure Parse_Type_Declaration (Item : in out Interface_Declaration) is
      Result : Type_Declaration;
   begin
      Result.Position := Current_Position;
      Scan;
      Result.Name := Parse_Name ("type name");
      Expect (Tok_Is, Declaration_Start);

      case Tok is
         when Tok_Range =>
            Scan;
            Result.Kind := Range_Type;
            if Tok = Tok_Integer_Literal then
               Result.Low := To_Unbounded_String (Tok_Text);
               Scan;
            else
               Error ("missing lower bound");
            end if;
            Expect (Tok_Dot_Dot, Declaration_Start);
            if Tok = Tok_Integer_Literal then
               Result.High := To_Unbounded_String (Tok_Text);
               Scan;
            else
               Error ("missing upper bound");
            end if;

         when Tok_New =>
            Scan;
            Result.Kind := Derived_Type;
            Result.Parent := Parse_Type_Reference;

         when Tok_Left_Paren =>
            Scan;
            Result.Kind := Enumeration_Type;
            loop
               Result.Literals.Append (To_String (Parse_Name ("literal")));
               exit when Tok /= Tok_Comma;
               Scan;
            end loop;
            Expect (Tok_Right_Paren, [Tok_Semicolon]);

         when others =>
            Error ("missing type definition");
            Skip_To ([Tok_Semicolon]);
      end case;

      Expect (Tok_Semicolon, Declaration_Start);
      Item.Types.Append (Result);
   end Parse_Type_Declaration;

   --------------------------
   -- Parse_Type_Reference --
   --------------------------

   function Parse_Type_Reference return Type_Reference is
      Result : Type_Reference;
   begin
      if Tok = Tok_Interface then
         Scan;
         Result.Is_Interface := True;
      end if;
      Result.Name := Parse_Name ("type name");
      return Result;
   end Parse_Type_Reference;

end Idle.Parser;
