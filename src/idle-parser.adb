with Ada.Characters.Handling;
with Ada.Characters.Latin_1;
with Ada.Strings;
with Ada.Strings.Fixed;
with Ada.Strings.Unbounded;
with Ada.Text_IO;

with Idle.Diagnostics;
with Idle.Literals;
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
   procedure Parse_Aspects (Pinned_Id : in out Long_Long_Long_Integer);
   --  An aspect specification, if there is one: "with" and a list of
   --  aspects. Endpoint_Id, an integer literal, is the only aspect, and
   --  sets Pinned_Id.

   procedure Parse_Subprogram (Item : in out Interface_Declaration);

   procedure Parse_Argument (Item : in out Interface_Declaration);
   --  An argument of a command.

   procedure Parse_Aspect_List (Into : in out Aspect_Vectors.Vector);
   --  "with" and a list of aspects, if there is one.

   procedure Parse_Command (Item : in out Interface_Declaration);
   procedure Parse_Interface (Item : in out Interface_Declaration);
   procedure Parse_Package (Item : in out Interface_Declaration);
   procedure Parse_Role (Item : in out Interface_Declaration);
   --  The unit, up to the semicolon after its end name.

   procedure Parse_End_Name (Expected : String);
   --  The name after "end", which should be Expected, without regard to
   --  case. Expected can be qualified, as Rose.Core.Echo.

   procedure Parse_Parents (Item : in out Interface_Declaration);
   --  A colon and a list of parents, if there is one.

   function Parse_Qualified_Name (What : String) return Unbounded_String;
   --  A name, or names joined by dots, such as Rose.Core.Echo, or report
   --  What as missing.

   function Parse_Value return Aspect_Value;
   --  An aspect's value or an argument's default: an integer literal, a
   --  character literal, a name, which can be qualified, as in
   --  User.Server.Start_Server, or a string: string literals joined by
   --  "&", a text block, or Text_File ("name").

   function Read_Text_File (Name : String) return String;
   --  The contents of the file Name, relative to the directory of the
   --  file being parsed, without its final line break.
   procedure Parse_Type_Declaration (Item : in out Interface_Declaration);

   function Same_Name (Left, Right : String) return Boolean
   is (Ada.Characters.Handling.To_Lower (Left)
       = Ada.Characters.Handling.To_Lower (Right));

   --------------------
   -- Parse_Argument --
   --------------------

   procedure Parse_Argument (Item : in out Interface_Declaration) is
      Result : Argument;
   begin
      Result.Position := Current_Position;
      Result.Name := Parse_Name ("argument name");
      Expect (Tok_Colon, [Tok_Identifier, Tok_Semicolon]);

      if Tok = Tok_In then
         Scan;
         if Tok = Tok_Out then
            Scan;
            Result.Mode := In_Out_Mode;
         end if;
      elsif Tok = Tok_Out then
         Scan;
         Result.Mode := Out_Mode;
      end if;

      Result.Of_Type := Parse_Type_Reference;

      if Tok = Tok_Becomes then
         Scan;
         Result.Has_Default := True;
         Result.Default := Parse_Value;
      end if;

      Parse_Aspect_List (Result.Aspects);
      Expect (Tok_Semicolon, [Tok_Identifier, Tok_End]);
      Item.Arguments.Append (Result);
   end Parse_Argument;

   -----------------------
   -- Parse_Aspect_List --
   -----------------------

   procedure Parse_Aspect_List (Into : in out Aspect_Vectors.Vector) is
   begin
      if Tok /= Tok_With then
         return;
      end if;

      Scan;
      loop
         declare
            Result : Aspect;
         begin
            Result.Position := Current_Position;
            Result.Name := Parse_Name ("aspect name");
            Expect (Tok_Arrow, [Tok_Comma, Tok_Semicolon, Tok_Is]);
            Result.Value := Parse_Value;
            Into.Append (Result);
         end;
         exit when Tok /= Tok_Comma;
         Scan;
      end loop;
   end Parse_Aspect_List;

   -------------------
   -- Parse_Aspects --
   -------------------

   procedure Parse_Aspects (Pinned_Id : in out Long_Long_Long_Integer) is
   begin
      if Tok /= Tok_With then
         return;
      end if;

      Scan;
      loop
         declare
            Name  : constant String := To_String (Parse_Name ("aspect name"));
            Value : Long_Long_Long_Integer;
         begin
            Expect (Tok_Arrow, [Tok_Comma, Tok_Semicolon, Tok_Is]);
            if not Same_Name (Name, "Endpoint_Id") then
               Error ("unknown aspect " & Name
                      & "; the only aspect is Endpoint_Id");
               if Tok in Tok_Integer_Literal | Tok_Identifier then
                  Scan;
               end if;
            elsif Tok /= Tok_Integer_Literal then
               Error ("missing endpoint id (an integer literal)");
               if Tok = Tok_Identifier then
                  Scan;
               end if;
            else
               if Idle.Literals.Value (Tok_Text, Value, 2 ** 64 - 1)
                 and then Value /= 0
               then
                  Pinned_Id := Value;
               else
                  Error ("an endpoint id must be a non-zero integer that"
                         & " fits in 64 bits");
               end if;
               Scan;
            end if;
         end;
         exit when Tok /= Tok_Comma;
         Scan;
      end loop;
   end Parse_Aspects;

   -------------------
   -- Parse_Command --
   -------------------

   procedure Parse_Command (Item : in out Interface_Declaration) is
   begin
      Expect (Tok_Command, [Tok_Identifier]);
      Item.Kind := Command_Unit;
      Item.Name := Parse_Qualified_Name ("command name");
      Parse_Parents (Item);
      Parse_Aspect_List (Item.Aspects);
      Expect (Tok_Is, [Tok_Identifier, Tok_End]);

      while Tok not in Tok_End | Tok_End_Of_File loop
         if Tok = Tok_Identifier then
            Parse_Argument (Item);
         else
            Error ("unexpected " & Description (Tok)
                   & " in command declaration");
            Scan;
            Skip_To ([Tok_Identifier, Tok_End]);
         end if;
      end loop;

      Expect (Tok_End, [Tok_Semicolon]);
      Parse_End_Name (To_String (Item.Name));
   end Parse_Command;

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

   --------------------
   -- Parse_End_Name --
   --------------------

   procedure Parse_End_Name (Expected : String) is
   begin
      if Tok = Tok_Identifier then
         declare
            Line    : constant Natural := Tok_Line;
            Column  : constant Natural := Tok_Column;
            Written : constant String :=
              To_String (Parse_Qualified_Name ("end name"));
         begin
            if not Same_Name (Written, Expected) then
               Idle.Diagnostics.Error
                 (File_Name, Line, Column,
                  "end name should be " & Expected);
            end if;
         end;
      else
         Error ("missing " & Expected & " after 'end'");
      end if;
   end Parse_End_Name;

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

      case Tok is
         when Tok_Command =>
            Parse_Command (Result);
         when Tok_Package =>
            Parse_Package (Result);
         when Tok_Role =>
            Parse_Role (Result);
         when others =>
            Parse_Interface (Result);
      end case;

      Expect (Tok_Semicolon, [Tok_End_Of_File]);

      if Tok /= Tok_End_Of_File then
         Error ("unexpected " & Description (Tok)
                & " after the end of the declaration");
      end if;

      Close;
      return Result;
   end Parse_File;

   ---------------------
   -- Parse_Interface --
   ---------------------

   procedure Parse_Interface (Item : in out Interface_Declaration) is
   begin
      Expect (Tok_Interface, [Tok_Identifier]);
      Item.Name := Parse_Name ("interface name");
      Parse_Parents (Item);
      Parse_Aspects (Item.Pinned_Id);
      Expect (Tok_Is, Declaration_Start);
      Parse_Declarations (Item);
      Expect (Tok_End, [Tok_Semicolon]);
      Parse_End_Name (To_String (Item.Name));
   end Parse_Interface;

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

   -------------------
   -- Parse_Package --
   -------------------

   procedure Parse_Package (Item : in out Interface_Declaration) is
   begin
      Expect (Tok_Package, [Tok_Identifier]);
      Item.Kind := Package_Unit;
      Item.Name := Parse_Qualified_Name ("package name");
      Parse_Aspect_List (Item.Aspects);
      Expect (Tok_Is, [Tok_End]);

      if Tok not in Tok_End | Tok_End_Of_File then
         Error ("a package declares nothing between 'is' and 'end'");
         Skip_To ([Tok_End]);
      end if;

      Expect (Tok_End, [Tok_Semicolon]);
      Parse_End_Name (To_String (Item.Name));
   end Parse_Package;

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

   -------------------
   -- Parse_Parents --
   -------------------

   procedure Parse_Parents (Item : in out Interface_Declaration) is
   begin
      if Tok = Tok_Colon then
         Scan;
         loop
            Item.Parents.Append (To_String (Parse_Name ("parent name")));
            exit when Tok /= Tok_Comma;
            Scan;
         end loop;
      end if;
   end Parse_Parents;

   --------------------------
   -- Parse_Qualified_Name --
   --------------------------

   function Parse_Qualified_Name (What : String) return Unbounded_String is
      Result : Unbounded_String := Parse_Name (What);
   begin
      while Tok = Tok_Dot loop
         Scan;
         Append (Result, "." & To_String (Parse_Name (What)));
      end loop;
      return Result;
   end Parse_Qualified_Name;

   ----------------
   -- Parse_Role --
   ----------------

   procedure Parse_Role (Item : in out Interface_Declaration) is
   begin
      Expect (Tok_Role, [Tok_Identifier]);
      Item.Kind := Role_Unit;
      Item.Name := Parse_Name ("role name");
      Parse_Parents (Item);

      --  role Standard_Output : Stream_Writer; is a role with one member,
      --  named after the role, whose type is the interface after the
      --  colon.

      if Tok = Tok_Semicolon and then Natural (Item.Parents.Length) = 1 then
         Item.Arguments.Append
           (Argument'
              (Name     => Item.Name,
               Of_Type  =>
                 (Name         =>
                    To_Unbounded_String (Item.Parents.First_Element),
                  Is_Interface => True),
               Position => Item.Position,
               others   => <>));
         Item.Parents.Clear;
         return;
      end if;

      Expect (Tok_Is, [Tok_Identifier, Tok_End]);

      while Tok = Tok_Identifier loop
         declare
            Member : Argument;
         begin
            Member.Position := Current_Position;
            Member.Name := Parse_Name ("member name");
            Expect (Tok_Colon, [Tok_Identifier, Tok_Semicolon]);

            if Tok in Tok_In | Tok_Out then
               Error ("a role member has no mode");
               while Tok in Tok_In | Tok_Out loop
                  Scan;
               end loop;
            end if;

            if Tok = Tok_Interface then
               Error ("a role member's type is always an interface, so it"
                      & " is written without 'interface'");
               Scan;
            end if;

            Member.Of_Type :=
              (Name         => Parse_Name ("interface name"),
               Is_Interface => True);

            if Tok in Tok_Becomes | Tok_With then
               Error ("a role member has no default or aspects");
               Skip_To ([Tok_Semicolon, Tok_End]);
            end if;

            Expect (Tok_Semicolon, [Tok_Identifier, Tok_End]);
            Item.Arguments.Append (Member);
         end;
      end loop;

      Expect (Tok_End, [Tok_Semicolon]);
      Parse_End_Name (To_String (Item.Name));
   end Parse_Role;

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

      Parse_Aspects (Result.Pinned_Id);
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
            if Tok in Tok_Integer_Literal | Tok_Identifier then
               Result.Low := To_Unbounded_String (Tok_Text);
               Scan;
            else
               Error ("missing lower bound (an integer literal or a name)");
            end if;
            Expect (Tok_Dot_Dot, Declaration_Start);
            if Tok in Tok_Integer_Literal | Tok_Identifier then
               Result.High := To_Unbounded_String (Tok_Text);
               Scan;
            else
               Error ("missing upper bound (an integer literal or a name)");
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

   -----------------
   -- Parse_Value --
   -----------------

   function Parse_Value return Aspect_Value is
      Result : Aspect_Value;
   begin
      Result.Position := Current_Position;

      case Tok is
         when Tok_Integer_Literal =>
            Result.Kind := Integer_Value;
            Result.Text := To_Unbounded_String (Tok_Text);
            Scan;

         when Tok_Character_Literal =>
            Result.Kind := Character_Value;
            Result.Text := To_Unbounded_String (Tok_Text);
            Scan;

         when Tok_String_Literal =>
            Result.Kind := String_Value;
            Result.Text := To_Unbounded_String (Tok_Text);
            Scan;
            while Tok = Tok_Ampersand loop
               Scan;
               if Tok = Tok_String_Literal then
                  Append (Result.Text, Tok_Text);
                  Scan;
               else
                  Error ("missing string after '&'");
                  exit;
               end if;
            end loop;

         when Tok_Identifier =>
            if Same_Name (Tok_Text, "Text_File")
              and then Next_Tok = Tok_Left_Paren
            then
               Scan;
               Scan;
               Result.Kind := String_Value;
               if Tok = Tok_String_Literal then
                  Result.Text :=
                    To_Unbounded_String (Read_Text_File (Tok_Text));
                  Scan;
               else
                  Error ("missing file name (a string literal)");
               end if;
               Expect (Tok_Right_Paren, [Tok_Comma, Tok_Semicolon, Tok_Is]);
            else
               Result.Kind := Name_Value;
               Result.Text := Parse_Qualified_Name ("value");
            end if;

         when others =>
            Error ("missing value");
      end case;

      return Result;
   end Parse_Value;

   --------------------
   -- Read_Text_File --
   --------------------

   function Read_Text_File (Name : String) return String is
      Current   : constant String := File_Name;
      Slash     : constant Natural :=
        Ada.Strings.Fixed.Index (Current, "/", Ada.Strings.Backward);
      Path      : constant String :=
        (if Name'Length > 0 and then Name (Name'First) = '/'
         then Name
         elsif Slash = 0 then Name
         else Current (Current'First .. Slash) & Name);
      File      : Ada.Text_IO.File_Type;
      Result    : Unbounded_String;
      First     : Boolean := True;
   begin
      begin
         Ada.Text_IO.Open (File, Ada.Text_IO.In_File, Path);
      exception
         when Ada.Text_IO.Name_Error | Ada.Text_IO.Use_Error =>
            Error ("cannot read text file " & Path);
            return "";
      end;

      while not Ada.Text_IO.End_Of_File (File) loop
         if not First then
            Append (Result, Ada.Characters.Latin_1.LF);
         end if;
         Append (Result, Ada.Text_IO.Get_Line (File));
         First := False;
      end loop;
      Ada.Text_IO.Close (File);
      return To_String (Result);
   end Read_Text_File;

end Idle.Parser;
