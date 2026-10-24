with Ada.Characters.Handling;
with Ada.Strings.Fixed;

with Idle.Diagnostics;
with Idle.Hierarchy;
with Idle.Literals;
with Idle.Names;

package body Idle.Commands is

   use type Idle.Syntax.Value_Kind;

   function Same (Left, Right : String) return Boolean
   is (Idle.Names.Key (Left) = Idle.Names.Key (Right));

   function Is_One_Of (Name : String; Names : String) return Boolean;
   --  True if Name is one of the space-separated names in Names, without
   --  regard to case.

   ------------
   -- Aspect --
   ------------

   function Aspect
     (Aspects : Idle.Syntax.Aspect_Vectors.Vector;
      Name    : String;
      Default : String := "")
      return String
   is
   begin
      for Item of Aspects loop
         if Same (To_String (Item.Name), Name) then
            return To_String (Item.Value.Text);
         end if;
      end loop;
      return Default;
   end Aspect;

   -----------
   -- Check --
   -----------

   function Check (Item : Idle.Syntax.Interface_Declaration) return Boolean
   is
      use all type Idle.Syntax.Unit_Kind;

      Errors_Before : constant Natural := Idle.Diagnostics.Error_Count;
      File_Name     : constant String := To_String (Item.File_Name);

      procedure Error
        (Position : Idle.Syntax.Source_Position;
         Message  : String);

      procedure Check_Aspects
        (Aspects : Idle.Syntax.Aspect_Vectors.Vector;
         Strings : String;
         Names   : String;
         What    : String);
      --  Report an aspect in Aspects that is neither one of the
      --  string-valued aspects Strings nor one of Names, a string aspect
      --  whose value is not a string, and an aspect given twice. What
      --  names the declaration, as in "a command".

      procedure Check_Arguments;
      procedure Check_Members;
      procedure Check_Package;
      procedure Check_Roles;

      ---------------------
      -- Check_Arguments --
      ---------------------

      procedure Check_Arguments is
         Lists       : Natural := 0;
         List_Seen   : Boolean := False;
         Short_Names : Idle.Syntax.String_Vectors.Vector;
         Names       : Idle.Syntax.String_Vectors.Vector;
      begin
         for Placed of Signature (Item) loop
            Names.Append (Idle.Names.Key (To_String (Placed.Argument.Name)));
         end loop;

         for Argument of Item.Arguments loop
            declare
               use all type Idle.Syntax.Parameter_Mode;
               Name       : constant String := To_String (Argument.Name);
               Kind       : constant Argument_Type := Type_Of (Argument);
               Short_Name : constant String :=
                 Commands.Aspect (Argument.Aspects, "Short_Name");
               Count      : Natural := 0;
            begin
               for Other of Names loop
                  if Other = Idle.Names.Key (Name) then
                     Count := Count + 1;
                  end if;
               end loop;
               if Count > 1 then
                  Error (Argument.Position,
                         "there is more than one argument called " & Name);
               end if;

               if Is_One_Of (Name, "help version") then
                  Error (Argument.Position,
                         Name & " is reserved: the shell handles --help and"
                         & " --version itself");
               end if;

               if Argument.Mode /= In_Mode then
                  Error (Argument.Position,
                         "out and in out arguments are not yet supported");
               end if;

               case Kind is
                  when Other_Argument =>
                     Error (Argument.Position,
                            "arguments of type "
                            & To_String (Argument.Of_Type.Name)
                            & " are not yet supported");
                  when String_List_Argument =>
                     Lists := Lists + 1;
                     if Lists > 1 then
                        Error (Argument.Position,
                               "only one argument can be a String_List");
                     end if;
                     if Short_Name /= "" then
                        Error (Argument.Position,
                               "a String_List argument takes the remaining"
                               & " positional words, so it has no short"
                               & " name");
                     end if;
                     if Argument.Has_Default then
                        Error (Argument.Default.Position,
                               "a String_List argument has no default");
                     end if;
                     List_Seen := True;
                  when others =>
                     if List_Seen and then Short_Name = "" then
                        Error (Argument.Position,
                               "a positional argument cannot follow the"
                               & " String_List argument, which takes the"
                               & " remaining words");
                     end if;
               end case;

               if Argument.Has_Default then
                  declare
                     Default : Idle.Syntax.Aspect_Value renames
                       Argument.Default;
                     Text    : constant String := To_String (Default.Text);
                     Value   : Long_Long_Long_Integer;
                  begin
                     case Kind is
                        when Boolean_Argument =>
                           if Default.Kind /= Idle.Syntax.Name_Value
                             or else not Is_One_Of (Text, "true false")
                           then
                              Error (Default.Position,
                                     "the default of a Boolean argument is"
                                     & " True or False");
                           end if;
                        when Natural_Argument | Positive_Argument =>
                           if Default.Kind /= Idle.Syntax.Integer_Value
                             or else not Idle.Literals.Value
                                           (Text, Value,
                                            Long_Long_Long_Integer
                                              (Integer'Last))
                             or else (Kind = Positive_Argument
                                      and then Value = 0)
                           then
                              Error (Default.Position,
                                     "the default of a "
                                     & (if Kind = Natural_Argument
                                        then "Natural" else "Positive")
                                     & " argument is an integer literal in"
                                     & " its range");
                           end if;
                        when String_Argument =>
                           if Default.Kind /= Idle.Syntax.String_Value then
                              Error (Default.Position,
                                     "the default of a String argument is"
                                     & " a string");
                           end if;
                        when String_List_Argument | Other_Argument =>
                           null;
                     end case;
                  end;
               end if;

               Check_Aspects
                 (Argument.Aspects, "Help", "Short_Name Short_Value",
                  "an argument");

               for Aspect of Argument.Aspects loop
                  declare
                     Aspect_Name : constant String := To_String (Aspect.Name);
                     Text        : constant String :=
                       To_String (Aspect.Value.Text);
                  begin
                     if Same (Aspect_Name, "Short_Name") then
                        if Aspect.Value.Kind /= Idle.Syntax.Character_Value
                          or else not Ada.Characters.Handling.Is_Alphanumeric
                                        (Text (Text'First))
                        then
                           Error (Aspect.Value.Position,
                                  "a short name is a letter or a digit, as"
                                  & " in 'n'");
                        elsif Short_Names.Contains (Text) then
                           Error (Aspect.Value.Position,
                                  "another argument has the short name '"
                                  & Text & "'");
                        else
                           Short_Names.Append (Text);
                        end if;
                     elsif Same (Aspect_Name, "Short_Value") then
                        if Kind /= Boolean_Argument then
                           Error (Aspect.Position,
                                  "only a Boolean argument has a short"
                                  & " value");
                        elsif Short_Name = "" then
                           Error (Aspect.Position,
                                  "a short value needs a short name");
                        elsif Aspect.Value.Kind /= Idle.Syntax.Name_Value
                          or else not Is_One_Of (Text, "true false")
                        then
                           Error (Aspect.Value.Position,
                                  "a short value is True or False");
                        end if;
                     end if;
                  end;
               end loop;
            end;
         end loop;
      end Check_Arguments;

      -------------------
      -- Check_Aspects --
      -------------------

      procedure Check_Aspects
        (Aspects : Idle.Syntax.Aspect_Vectors.Vector;
         Strings : String;
         Names   : String;
         What    : String)
      is
         Seen : Idle.Syntax.String_Vectors.Vector;
      begin
         for Aspect of Aspects loop
            declare
               Name : constant String := To_String (Aspect.Name);
            begin
               if Seen.Contains (Idle.Names.Key (Name)) then
                  Error (Aspect.Position, "the aspect " & Name
                         & " is given more than once");
               end if;
               Seen.Append (Idle.Names.Key (Name));

               if Is_One_Of (Name, Strings) then
                  if Aspect.Value.Kind /= Idle.Syntax.String_Value then
                     Error (Aspect.Value.Position,
                            "the value of " & Name & " is a string");
                  end if;
               elsif not Is_One_Of (Name, Names) then
                  Error (Aspect.Position,
                         "unknown aspect " & Name & " of " & What);
               end if;
            end;
         end loop;
      end Check_Aspects;

      -------------------
      -- Check_Members --
      -------------------

      procedure Check_Members is
         Names : Idle.Syntax.String_Vectors.Vector;
      begin
         for Member of Item.Arguments loop
            declare
               Name  : constant String := To_String (Member.Name);
               Found : Idle.Syntax.Interface_Declaration;
               Type_Name : constant String :=
                 To_String (Member.Of_Type.Name);
            begin
               if Names.Contains (Idle.Names.Key (Name)) then
                  Error (Member.Position,
                         "there is more than one member called " & Name);
               end if;
               Names.Append (Idle.Names.Key (Name));

               if not Idle.Hierarchy.Find (Item, Type_Name, Found)
                 or else Found.Kind /= Interface_Unit
               then
                  Error (Member.Position,
                         "unknown interface " & Type_Name);
               end if;
            end;
         end loop;
      end Check_Members;

      -------------------
      -- Check_Package --
      -------------------

      procedure Check_Package is
         Name  : constant String := Package_Name (Item);
         Found : Idle.Syntax.Interface_Declaration;
      begin
         if Name = "" then
            Error (Item.Position,
                   "a command is named as a child of its package, as in"
                   & " Rose.Core.Echo");
         elsif not Idle.Hierarchy.Find (Item, Name, Found) then
            Error (Item.Position,
                   "package " & Name & " not found: no "
                   & Idle.Hierarchy.Declaration_File (Item, Name)
                   & " declares it");
         elsif Found.Kind /= Package_Unit then
            Error (Item.Position, Name & " is not a package");
         end if;
      end Check_Package;

      -----------------
      -- Check_Roles --
      -----------------

      procedure Check_Roles is
      begin
         for Ancestor of Idle.Hierarchy.Ancestors (Item) loop
            if Ancestor.Kind /= Role_Unit then
               Error (Item.Position,
                      To_String (Ancestor.Name)
                      & " is not a role, so it cannot be inherited by a "
                      & (if Item.Kind = Command_Unit
                         then "command" else "role"));
            end if;
         end loop;

         if Item.Kind = Command_Unit then
            for Placed of Signature (Item) loop
               if Placed.Role /= Null_Unbounded_String
                 and then Placed.Stream = No_Stream
               then
                  Error (Item.Position,
                         "the member " & To_String (Placed.Argument.Name)
                         & " of the role " & To_String (Placed.Role)
                         & " is not yet supported: only the standard"
                         & " streams are");
               end if;
            end loop;
         end if;
      end Check_Roles;

      -----------
      -- Error --
      -----------

      procedure Error
        (Position : Idle.Syntax.Source_Position;
         Message  : String)
      is
      begin
         Idle.Diagnostics.Error
           (File_Name, Position.Line, Position.Column, Message);
      end Error;

   begin
      case Item.Kind is
         when Command_Unit =>
            Check_Package;
            Check_Roles;
            Check_Aspects
              (Item.Aspects,
               "Summary Description Name Authors Version Copyright", "",
               "a command");
            Check_Arguments;
         when Package_Unit =>
            Check_Aspects
              (Item.Aspects,
               "Title Version Copyright Authors Summary License Help_Footer",
               "", "a package");
         when Role_Unit =>
            Check_Roles;
            Check_Members;
         when Interface_Unit =>
            null;
      end case;
      return Idle.Diagnostics.Error_Count = Errors_Before;
   end Check;

   ------------
   -- Detail --
   ------------

   function Detail
     (Item : Idle.Syntax.Interface_Declaration;
      Name : String)
      return String
   is
      Name_Text : constant String := To_String (Item.Name);
      Dot       : constant Natural :=
        Ada.Strings.Fixed.Index (Name_Text, ".", Ada.Strings.Backward);
      Enclosing : Idle.Syntax.Interface_Declaration;
   begin
      if Has_Aspect (Item.Aspects, Name) then
         return Aspect (Item.Aspects, Name);
      elsif not Is_One_Of (Name, "version copyright authors license"
                                 & " help_footer")
      then
         return "";
      end if;

      --  The nearest enclosing package that is declared in IDL; ancestors
      --  that are Ada packages, such as Rose, have no file.

      declare
         Prefix : Natural := Dot;
      begin
         while Prefix > 0 loop
            declare
               Outer : constant String :=
                 Name_Text (Name_Text'First .. Prefix - 1);
            begin
               if Idle.Hierarchy.Find (Item, Outer, Enclosing)
                 and then Enclosing.Kind in Idle.Syntax.Package_Unit
               then
                  return Detail (Enclosing, Name);
               end if;
               Prefix :=
                 Ada.Strings.Fixed.Index (Outer, ".", Ada.Strings.Backward);
            end;
         end loop;
      end;
      return "";
   end Detail;

   ----------------
   -- Has_Aspect --
   ----------------

   function Has_Aspect
     (Aspects : Idle.Syntax.Aspect_Vectors.Vector;
      Name    : String)
      return Boolean
   is (for some Item of Aspects => Same (To_String (Item.Name), Name));

   ---------------
   -- Is_One_Of --
   ---------------

   function Is_One_Of (Name : String; Names : String) return Boolean is
      Key   : constant String := Idle.Names.Key (Name);
      First : Positive := Names'First;
   begin
      for Index in Names'Range loop
         if Names (Index) = ' ' or else Index = Names'Last then
            declare
               Last : constant Natural :=
                 (if Names (Index) = ' ' then Index - 1 else Index);
            begin
               if Idle.Names.Key (Names (First .. Last)) = Key then
                  return True;
               end if;
               First := Index + 1;
            end;
         end if;
      end loop;
      return False;
   end Is_One_Of;

   ------------------
   -- Package_Name --
   ------------------

   function Package_Name
     (Item : Idle.Syntax.Interface_Declaration)
      return String
   is
      Name : constant String := To_String (Item.Name);
      Dot  : constant Natural :=
        Ada.Strings.Fixed.Index (Name, ".", Ada.Strings.Backward);
   begin
      return (if Dot = 0 then "" else Name (Name'First .. Dot - 1));
   end Package_Name;

   ---------------
   -- Signature --
   ---------------

   function Signature
     (Item : Idle.Syntax.Interface_Declaration)
      return Placed_Vectors.Vector
   is
      Result      : Placed_Vectors.Vector;
      Next_Word   : Natural := 0;
      Next_Cap    : Natural := 0;
      String_Args : Natural := 0;
      Next_Item   : Positive := 1;
   begin
      for Role of Idle.Hierarchy.Ancestors (Item) loop
         for Member of Role.Arguments loop
            declare
               Name : constant String := To_String (Member.Name);
            begin
               Result.Append
                 (Placed_Argument'
                    (Argument => Member,
                     Role     => Role.Name,
                     Stream   =>
                       (if Same (Name, "Standard_Input") then Input_Stream
                        elsif Same (Name, "Standard_Output")
                        then Output_Stream
                        elsif Same (Name, "Standard_Error") then Error_Stream
                        else No_Stream),
                     Where    => (Cap_Place, Next_Cap, 0)));
               Next_Cap := Next_Cap + 1;
            end;
         end loop;
      end loop;

      for Argument of Item.Arguments loop
         if Type_Of (Argument) = String_Argument then
            String_Args := String_Args + 1;
         end if;
      end loop;

      for Argument of Item.Arguments loop
         declare
            Where : Place;
         begin
            case Type_Of (Argument) is
               when Boolean_Argument | Natural_Argument | Positive_Argument
                  | Other_Argument
               =>
                  Where := (Word_Place, Next_Word, 0);
                  Next_Word := Next_Word + 1;
               when String_Argument =>
                  Where := (Item_Place, Next_Item, 0);
                  Next_Item := Next_Item + 1;
               when String_List_Argument =>
                  Where := (List_Place, String_Args + 1, Next_Word);
                  Next_Word := Next_Word + 1;
            end case;
            Result.Append
              (Placed_Argument'
                 (Argument => Argument,
                  Role     => Null_Unbounded_String,
                  Stream   => No_Stream,
                  Where    => Where));
         end;
      end loop;

      return Result;
   end Signature;

   -----------------
   -- Simple_Name --
   -----------------

   function Simple_Name (Name : String) return String is
      Dot : constant Natural :=
        Ada.Strings.Fixed.Index (Name, ".", Ada.Strings.Backward);
   begin
      return (if Dot = 0 then Name else Name (Dot + 1 .. Name'Last));
   end Simple_Name;

   -------------
   -- Type_Of --
   -------------

   function Type_Of (Item : Idle.Syntax.Argument) return Argument_Type is
      Name : constant String := To_String (Item.Of_Type.Name);
   begin
      if Item.Of_Type.Is_Interface then
         return Other_Argument;
      elsif Same (Name, "Boolean") then
         return Boolean_Argument;
      elsif Same (Name, "Natural") then
         return Natural_Argument;
      elsif Same (Name, "Positive") then
         return Positive_Argument;
      elsif Same (Name, "String") then
         return String_Argument;
      elsif Same (Name, "String_List") then
         return String_List_Argument;
      else
         return Other_Argument;
      end if;
   end Type_Of;

end Idle.Commands;
