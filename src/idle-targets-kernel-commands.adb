with Ada.Characters.Latin_1;
with Ada.Strings.Fixed;
with Ada.Strings.Unbounded;

with Syn;
with Syn.Factory;
with Syn.Units;

with Idle.Commands;
with Idle.Hierarchy;
with Idle.Names;
with Idle.Targets.Kernel.Support;

package body Idle.Targets.Kernel.Commands is

   use Ada.Strings.Unbounded;
   use Idle.Targets.Kernel.Support;
   use type Syn.Node_Array;

   Launch : constant String := "Rose.Command_Line.Launch.";

   Chunk_Length : constant := 60;
   --  The longest string literal written in one piece; longer strings
   --  are joined from several, so that lines stay short.

   function Escape (Text : String) return String;
   --  Text, with each "\" written "\\" and each line break "\n", for a
   --  value in the metadata.

   function String_Value
     (F    : in out Syn.Factory.Factory;
      Text : String)
      return not null Syn.Node_Access;
   --  An expression for the string Text: literals of at most Chunk_Length
   --  characters, broken after a space where there is one, joined by "&",
   --  with ASCII.LF for each line break.

   ------------
   -- Escape --
   ------------

   function Escape (Text : String) return String is
      Result : Unbounded_String;
   begin
      for Ch of Text loop
         if Ch = '\' then
            Append (Result, "\\");
         elsif Ch = Ada.Characters.Latin_1.LF then
            Append (Result, "\n");
         else
            Append (Result, Ch);
         end if;
      end loop;
      return To_String (Result);
   end Escape;

   ----------------------
   -- Generate_Command --
   ----------------------

   procedure Generate_Command
     (Item             : Idle.Syntax.Interface_Declaration;
      Output_Directory : String)
   is
      use all type Idle.Commands.Argument_Type;
      use all type Idle.Commands.Place_Kind;
      use all type Idle.Commands.Stream;

      F             : Syn.Factory.Factory;
      Name          : constant String := To_String (Item.Name);
      Main_Name     : constant String := Name & "_Main";
      Metadata_Name : constant String := Name & "_Metadata";
      Signature     : constant Idle.Commands.Placed_Vectors.Vector :=
        Idle.Commands.Signature (Item);

      Parameters    : Node_List;
      Statements    : Node_List;
      Arguments     : Node_List;
      Lines         : Unbounded_String;
      Uses_Lists    : Boolean := False;

      function Call_Node return not null Syn.Node_Access
      is (F.New_Name ("Call"));

      function Literal (Value : Natural) return not null Syn.Node_Access
      is (F.New_Integer_Literal (Long_Long_Long_Integer (Value)));

      Package_Item : Idle.Syntax.Interface_Declaration;
      Found        : constant Boolean :=
        Idle.Hierarchy.Find
          (Item, Idle.Commands.Package_Name (Item), Package_Item);
      pragma Assert (Found);

      function Detail (Aspect_Name : String) return String
      is (if Idle.Commands.Has_Aspect (Item.Aspects, Aspect_Name)
          then Idle.Commands.Aspect (Item.Aspects, Aspect_Name)
          else Idle.Commands.Detail (Package_Item, Aspect_Name));
      --  A detail of the command, which can override its package's.

      Registered : constant String :=
        Idle.Commands.Aspect
          (Item.Aspects, "Name",
           Idle.Names.Key (Idle.Commands.Simple_Name (Name)));

      function Fill (Text : String) return String;
      --  Text, with {command} replaced by the registered name.

      procedure Line (Key, Value : String);
      --  Add a line to the metadata, unless Value is empty.

      ----------
      -- Fill --
      ----------

      function Fill (Text : String) return String is
         Marker : constant String := "{command}";
         Result : Unbounded_String := To_Unbounded_String (Text);
         Index  : Natural;
      begin
         loop
            Index := Ada.Strings.Unbounded.Index (Result, Marker);
            exit when Index = 0;
            Replace_Slice (Result, Index, Index + Marker'Length - 1,
                           Registered);
         end loop;
         return To_String (Result);
      end Fill;

      ----------
      -- Line --
      ----------

      procedure Line (Key, Value : String) is
      begin
         if Value /= "" then
            Append (Lines, Key & " " & Escape (Value)
                    & Ada.Characters.Latin_1.LF);
         end if;
      end Line;

   begin
      --  The metadata, which the shell's registry reads at install time.

      Line ("rose-command", "1");
      Line ("command", Name);
      Line ("name", Registered);
      Line ("package", Idle.Commands.Package_Name (Item));
      Line ("title",
            Idle.Commands.Aspect
              (Package_Item.Aspects, "Title",
               Idle.Commands.Package_Name (Item)));
      Line ("version",
            (if Detail ("Version") = "" then "0.0.0"
             else Detail ("Version")));
      Line ("copyright", Detail ("Copyright"));
      Line ("authors", Detail ("Authors"));
      Line ("license", Idle.Commands.Detail (Package_Item, "License"));
      Line ("help-footer",
            Fill (Idle.Commands.Detail (Package_Item, "Help_Footer")));
      Line ("summary",
            Idle.Commands.Aspect
              (Item.Aspects, "Summary", Name & " (no summary)"));
      Line ("description", Idle.Commands.Aspect (Item.Aspects, "Description"));
      for Parent of Item.Parents loop
         Line ("role", Parent);
      end loop;

      for Placed of Signature loop
         declare
            Argument : Idle.Syntax.Argument renames Placed.Argument;
            Argument_Name : constant String := To_String (Argument.Name);
            Where    : Idle.Commands.Place renames Placed.Where;
         begin
            if Placed.Stream /= No_Stream then
               Line ("stream",
                     (case Placed.Stream is
                         when Input_Stream  => "input",
                         when Output_Stream => "output",
                         when Error_Stream  => "error",
                         when No_Stream     => "")
                     & Natural'Image (Where.Index));
               Statements.Append
                 (F.New_Call_Statement
                    (F.New_Call
                       (Launch & "Use_"
                        & (case Placed.Stream is
                              when Input_Stream  => "Standard_Input",
                              when Output_Stream => "Standard_Output",
                              when Error_Stream  => "Standard_Error",
                              when No_Stream     => ""),
                        [Call_Node, Literal (Where.Index)])));
            else
               Line ("argument", Argument_Name);
               Line ("type", To_String (Argument.Of_Type.Name));
               Line ("place",
                     (case Where.Kind is
                         when Word_Place => "word",
                         when Cap_Place  => "cap",
                         when Item_Place => "item",
                         when List_Place => "list")
                     & Natural'Image (Where.Index)
                     & (if Where.Kind = List_Place
                        then " word" & Natural'Image (Where.Count)
                        else ""));
               if Argument.Has_Default then
                  Line ("default", To_String (Argument.Default.Text));
               end if;
               if Idle.Commands.Has_Aspect (Argument.Aspects, "Short_Name")
               then
                  Line ("short",
                        Idle.Commands.Aspect (Argument.Aspects, "Short_Name"));
               end if;
               if Idle.Commands.Has_Aspect (Argument.Aspects, "Short_Value")
               then
                  Line ("short-value",
                        Idle.Commands.Aspect
                          (Argument.Aspects, "Short_Value"));
               end if;
               Line ("help",
                     Idle.Commands.Aspect
                       (Argument.Aspects, "Help",
                        Argument_Name & " (no help)"));

               declare
                  Kind  : constant Idle.Commands.Argument_Type :=
                    Idle.Commands.Type_Of (Argument);
                  Value : Syn.Node_Access;
                  Ada_Type : constant String :=
                    (case Kind is
                        when Boolean_Argument     => "Boolean",
                        when Natural_Argument     => "Natural",
                        when Positive_Argument    => "Positive",
                        when String_Argument      => "String",
                        when String_List_Argument =>
                          "Rose.Command_Line.String_List",
                        when Other_Argument       => "");
               begin
                  case Kind is
                     when Boolean_Argument =>
                        Value := F.New_Call
                          (Launch & "Boolean_Argument",
                           [Call_Node, Literal (Where.Index)]);
                     when Natural_Argument =>
                        Value := F.New_Call
                          (Launch & "Natural_Argument",
                           [Call_Node, Literal (Where.Index)]);
                     when Positive_Argument =>
                        Value := F.New_Call
                          ("Positive",
                           [F.New_Call
                              (Launch & "Natural_Argument",
                               [Call_Node, Literal (Where.Index)])]);
                     when String_Argument =>
                        Value := F.New_Call
                          (Launch & "String_Argument",
                           [Call_Node, Literal (Where.Index)]);
                     when String_List_Argument =>
                        Value := F.New_Call
                          (Launch & "String_List_Argument",
                           [Call_Node, Literal (Where.Index),
                            Literal (Where.Count)]);
                        Uses_Lists := True;
                     when Other_Argument =>
                        raise Program_Error;
                  end case;
                  Arguments.Append (F.New_Named (Argument_Name, Value));

                  Parameters.Append
                    (F.New_Parameter
                       (Argument_Name, F.New_Name (Ada_Type),
                        Default =>
                          (if not Argument.Has_Default then null
                           elsif Kind = String_Argument
                           then F.New_String_Literal
                                  (To_String (Argument.Default.Text))
                           else F.New_Name
                                  (To_String (Argument.Default.Text)))));
               end;
            end if;
         end;
      end loop;

      --  The procedure spec.

      declare
         Context : Context_List;
      begin
         if Uses_Lists then
            Context.Add ("Rose.Command_Line");
         end if;
         Syn.Units.Write
           (F.New_Compilation_Unit
              (Context => Context.To_Array (F),
               Item    => F.New_Procedure (Name, Parameters.To_Array)),
            Output_Directory);
      end;

      --  The metadata.

      declare
         Text : constant not null Syn.Node_Access :=
           String_Value (F, To_String (Lines));
      begin
         Syn.Units.Write
           (F.New_Compilation_Unit
              (Item =>
                 F.New_Package
                   (Metadata_Name,
                    [F.New_Object
                       ("Text", F.New_Name ("String"), Text,
                        Is_Constant => True,
                        Aspects     =>
                          [F.New_Aspect
                             ("Linker_Section",
                              F.New_String_Literal (".rose_command"))])])),
            Output_Directory);
      end;

      --  The main: receive the launch invocation, give the standard
      --  streams to the run-time system, call the command, and complete.
      --  It withs the metadata only to link it into the executable.

      Syn.Units.Write
        (F.New_Compilation_Unit
           (Context =>
              [F.New_With ("Rose.Command_Line.Launch"),
               F.New_With (Name),
               F.New_With (Metadata_Name),
               F.New_Raw ("pragma Unreferenced (" & Metadata_Name & ");")],
            Item    =>
              F.New_Subprogram_Body
                (Specification => F.New_Procedure (Main_Name),
                 Declarations  =>
                   [F.New_Object
                      ("Call",
                       F.New_Name (Launch & "Launch_Call"))],
                 Statements    =>
                   [F.New_Call_Statement
                      (F.New_Call
                         (Launch & "Receive", [Call_Node]))]
                   & Statements.To_Array
                   & [F.New_Call_Statement
                        (if Arguments.To_Array'Length = 0
                         then F.New_Name (Name)
                         else F.New_Call (Name, Arguments.To_Array)),
                      F.New_Call_Statement
                        (F.New_Call (Launch & "Complete", [Call_Node]))])),
         Output_Directory);
   end Generate_Command;

   ----------------------
   -- Generate_Package --
   ----------------------

   procedure Generate_Package
     (Item             : Idle.Syntax.Interface_Declaration;
      Output_Directory : String)
   is
      F       : Syn.Factory.Factory;
      Name    : constant String := To_String (Item.Name);
      Details : Node_List;

      procedure Add (Constant_Name, Aspect_Name, Default : String);

      ---------
      -- Add --
      ---------

      procedure Add (Constant_Name, Aspect_Name, Default : String) is
         Value : constant String :=
           Idle.Commands.Detail (Item, Aspect_Name);
         Text  : constant not null Syn.Node_Access :=
           String_Value (F, (if Value = "" then Default else Value));
      begin
         Details.Append
           (F.New_Object
              (Constant_Name, F.New_Name ("String"), Text,
               Is_Constant => True));
      end Add;

   begin
      Add ("Title", "Title", Name);
      Add ("Version", "Version", "0.0.0");
      Add ("Copyright", "Copyright", "");
      Add ("Authors", "Authors", "");
      Add ("Summary", "Summary", Name & " (no summary)");
      Add ("License", "License", "");
      Add ("Help_Footer", "Help_Footer", "");

      Syn.Units.Write
        (F.New_Compilation_Unit
           (Item => F.New_Package (Name, Details.To_Array)),
         Output_Directory);
   end Generate_Package;

   ------------------
   -- String_Value --
   ------------------

   function String_Value
     (F    : in out Syn.Factory.Factory;
      Text : String)
      return not null Syn.Node_Access
   is
      Parts : Node_List;
      First : Positive := Text'First;
   begin
      while First <= Text'Last loop
         declare
            Break : constant Natural :=
              Ada.Strings.Fixed.Index
                (Text (First .. Text'Last), [1 => Ada.Characters.Latin_1.LF]);
            Last  : constant Natural :=
              (if Break = 0 then Text'Last else Break - 1);
            Start : Positive := First;
         begin
            while Start <= Last loop
               declare
                  Stop : Natural :=
                    Natural'Min (Last, Start + Chunk_Length - 1);
               begin
                  if Stop < Last then
                     for Space in reverse Start + Chunk_Length / 2 .. Stop
                     loop
                        if Text (Space) = ' ' then
                           Stop := Space;
                           exit;
                        end if;
                     end loop;
                  end if;
                  Parts.Append (F.New_String_Literal (Text (Start .. Stop)));
                  Start := Stop + 1;
               end;
            end loop;
            if Break /= 0 then
               Parts.Append (F.New_Name ("ASCII.LF"));
               First := Break + 1;
            else
               First := Text'Last + 1;
            end if;
         end;
      end loop;

      if Parts.To_Array'Length = 0 then
         return F.New_String_Literal ("");
      else
         return F.New_Concatenation (Parts.To_Array);
      end if;
   end String_Value;

end Idle.Targets.Kernel.Commands;
