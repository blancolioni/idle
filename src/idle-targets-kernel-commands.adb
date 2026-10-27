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
      Output_Directory : String;
      Target           : Idle.Targets.Target)
   is
      use all type Idle.Commands.Argument_Type;
      use all type Idle.Commands.Place_Kind;
      use all type Idle.Commands.Stream;
      use all type Idle.Commands.System_Cap;

      F             : Syn.Factory.Factory;
      Name          : constant String := To_String (Item.Name);
      Main_Name     : constant String := Name & "_Main";
      Metadata_Name : constant String := Name & "_Metadata";
      Signature     : constant Idle.Commands.Placed_Vectors.Vector :=
        Idle.Commands.Signature (Item);

      Parameters    : Node_List;
      Declarations  : Node_List;
      Statements    : Node_List;
      Arguments     : Node_List;
      Results       : Node_List;
      Serve         : Node_List;
      --  For a server, the call that serves after the reply.
      System_Args   : Node_List;
      Spec_Context  : Context_List;
      Main_Context  : Context_List;
      Lines         : Unbounded_String;

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

      procedure Add_Value (Placed : Idle.Commands.Placed_Argument);
      --  Pass the scalar, string or list argument Placed to the command,
      --  and, if it is out or in out, send its value back as a result.

      function Fill (Text : String) return String;
      --  Text, with {command} replaced by the registered name.

      procedure Line (Key, Value : String);
      --  Add a line to the metadata, unless Value is empty.

      ---------------
      -- Add_Value --
      ---------------

      procedure Add_Value (Placed : Idle.Commands.Placed_Argument) is
         use all type Idle.Syntax.Parameter_Mode;
         Argument      : Idle.Syntax.Argument renames Placed.Argument;
         Argument_Name : constant String := To_String (Argument.Name);
         Last_Name     : constant String := Argument_Name & "_Last";
         Where         : Idle.Commands.Place renames Placed.Where;
         Answer        : Idle.Commands.Place renames Placed.Result;
         Kind          : constant Idle.Commands.Argument_Type := Placed.Kind;
         Ada_Type      : constant String :=
           (case Kind is
               when Boolean_Argument     => "Boolean",
               when Natural_Argument     => "Natural",
               when Positive_Argument    => "Positive",
               when String_Argument      => "String",
               when String_List_Argument => "Rose.Command_Line.String_List",
               when Interface_Argument | Other_Argument => "");
         Mode          : constant Syn.Parameter_Mode :=
           (case Argument.Mode is
               when In_Mode     => Syn.In_Mode,
               when Out_Mode    => Syn.Out_Mode,
               when In_Out_Mode => Syn.In_Out_Mode);
         Value         : Syn.Node_Access := null;

         function Text return not null Syn.Node_Access
         is (F.New_Call
               (Argument_Name,
                [F.New_Binary (Literal (1), "..", F.New_Name (Last_Name))]));
         --  The text of a string result.

      begin
         if Where.Kind /= No_Place then
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
                  Spec_Context.Add ("Rose.Command_Line");
               when Interface_Argument | Other_Argument =>
                  raise Program_Error;
            end case;
         end if;

         --  Ada allows a default only for an in parameter; the shell
         --  supplies the default of an in out argument.

         Parameters.Append
           (F.New_Parameter
              (Argument_Name, F.New_Name (Ada_Type), Mode,
               Default =>
                 (if Argument.Mode /= In_Mode or else not Argument.Has_Default
                  then null
                  elsif Kind = String_Argument
                  then F.New_String_Literal
                         (To_String (Argument.Default.Text))
                  else F.New_Name (To_String (Argument.Default.Text)))));

         if Argument.Mode = In_Mode then
            Arguments.Append (F.New_Named (Argument_Name, Value));
            return;
         end if;

         --  An out or in out value is a local of the main, passed to the
         --  command and then sent back in the reply. An in out value is set
         --  after the launch invocation is received, so not in the
         --  local's declaration.

         if Kind = String_Argument then
            Parameters.Append
              (F.New_Parameter
                 (Last_Name, F.New_Name ("Natural"), Syn.Out_Mode));
            Declarations.Append
              (F.New_Object
                 (Argument_Name,
                  F.New_Call
                    ("String",
                     [F.New_Binary
                        (Literal (1), "..",
                         F.New_Name (Launch & "Max_Result_Length"))])));
            Declarations.Append
              (F.New_Object (Last_Name, F.New_Name ("Natural")));
            if Argument.Mode = In_Out_Mode then
               Statements.Append
                 (F.New_Block
                    (Declarations =>
                       [F.New_Object
                          (Argument_Name & "_Value", F.New_Name ("String"),
                           Value, Is_Constant => True)],
                     Statements   =>
                       [F.New_Assignment
                          (F.New_Name (Last_Name),
                           F.New_Attribute
                             (F.New_Name (Argument_Name & "_Value"),
                              "Length")),
                        F.New_Assignment
                          (Text, F.New_Name (Argument_Name & "_Value"))]));
            end if;
            Arguments.Append
              (F.New_Named (Argument_Name, F.New_Name (Argument_Name)));
            Arguments.Append
              (F.New_Named (Last_Name, F.New_Name (Last_Name)));
            Results.Append
              (F.New_Call_Statement
                 (F.New_Call
                    (Launch & "String_Result",
                     [Call_Node, Literal (Answer.Index), Text])));
         else
            Declarations.Append
              (F.New_Object (Argument_Name, F.New_Name (Ada_Type)));
            if Argument.Mode = In_Out_Mode then
               Statements.Append
                 (F.New_Assignment (F.New_Name (Argument_Name), Value));
            end if;
            Arguments.Append
              (F.New_Named (Argument_Name, F.New_Name (Argument_Name)));
            Results.Append
              (F.New_Call_Statement
                 (F.New_Call
                    (Launch
                     & (if Kind = Boolean_Argument then "Boolean_Result"
                        else "Natural_Result"),
                     [Call_Node, Literal (Answer.Index),
                      F.New_Name (Argument_Name)])));
         end if;
      end Add_Value;

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
            use all type Idle.Syntax.Parameter_Mode;
            Argument      : Idle.Syntax.Argument renames Placed.Argument;
            Argument_Name : constant String := To_String (Argument.Name);
            Where         : Idle.Commands.Place renames Placed.Where;
            Answer        : Idle.Commands.Place renames Placed.Result;
            Type_Name     : constant String :=
              To_String (Argument.Of_Type.Name);

            function Client_Unit return String
            is ("Rose.Interfaces." & Idle.Names.Ada_Name (Type_Name)
                & ".Client");

            function Client_Type return String
            is (Client_Unit & "." & Idle.Names.Ada_Name (Type_Name)
                & "_Client");

            function Object_Unit return String
            is ("Rose.Interfaces." & Idle.Names.Ada_Name (Type_Name));

            function Object_Class return String
            is (Object_Unit & "." & Idle.Names.Ada_Name (Type_Name)
                & "_Object'Class");
            --  For the user target, the type of the command's parameter.

            function Cap_Argument return not null Syn.Node_Access
            is (F.New_Call
                  (Launch & "Cap_Argument",
                   [Call_Node, Literal (Where.Index)]));

            procedure Return_Cap;
            --  Pass the command a cap to set, and send it back as the
            --  result. A server sets it to its own interface cap, which
            --  it could not open as a client before it serves.

            procedure Use_Client;
            --  Pass the cap of the argument to the command as a client of
            --  its interface.

            ----------------
            -- Return_Cap --
            ----------------

            procedure Return_Cap is
               Cap_Type : constant String := "Rose.Capabilities.Capability";
            begin
               Spec_Context.Add ("Rose.Capabilities");
               Main_Context.Add ("Rose.Capabilities");
               Declarations.Append
                 (F.New_Object (Argument_Name, F.New_Name (Cap_Type)));
               Arguments.Append
                 (F.New_Named (Argument_Name, F.New_Name (Argument_Name)));
               Parameters.Append
                 (F.New_Parameter
                    (Argument_Name, F.New_Name (Cap_Type), Syn.Out_Mode));
               Results.Append
                 (F.New_Call_Statement
                    (F.New_Call
                       (Launch & "Cap_Result",
                        [Call_Node, Literal (Answer.Index),
                         F.New_Name (Argument_Name)])));
            end Return_Cap;

            ----------------
            -- Use_Client --
            ----------------

            procedure Use_Client is
            begin
               if Target = User_Target then
                  Spec_Context.Add (Object_Unit);
               else
                  Spec_Context.Add (Client_Unit);
               end if;
               Main_Context.Add (Client_Unit);
               Declarations.Append
                 (F.New_Object (Argument_Name, F.New_Name (Client_Type)));
               Statements.Append
                 (F.New_Call_Statement
                    (F.New_Call
                       (Client_Unit & ".Open",
                        [F.New_Name (Argument_Name), Cap_Argument])));
               Arguments.Append
                 (F.New_Named (Argument_Name, F.New_Name (Argument_Name)));
               if Target = User_Target then
                  Parameters.Append
                    (F.New_Parameter
                       (Argument_Name, F.New_Name (Object_Class),
                        Syn.In_Out_Mode));
               else
                  Parameters.Append
                    (F.New_Parameter
                       (Argument_Name, F.New_Name (Client_Type)));
               end if;
            end Use_Client;

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

            elsif Placed.System /= No_System_Cap then
               Line ("system",
                     (case Placed.System is
                         when Create_Endpoint_Cap => "create-endpoint",
                         when Delete_Cap          => "delete-cap",
                         when Rescind_Cap         => "rescind-cap",
                         when No_System_Cap       => "")
                     & Natural'Image (Where.Index));
               System_Args.Append
                 (F.New_Named
                    ((case Placed.System is
                         when Create_Endpoint_Cap => "Create_Endpoint",
                         when Delete_Cap          => "Delete_Cap",
                         when Rescind_Cap         => "Rescind_Cap",
                         when No_System_Cap       => ""),
                     Cap_Argument));

            elsif Placed.Role /= Null_Unbounded_String then
               Line ("cap",
                     Argument_Name & " " & Type_Name
                     & Natural'Image (Where.Index));
               Use_Client;

            else
               Line ("argument", Argument_Name);
               Line ("type",
                     (if Placed.Kind = Interface_Argument
                      then "interface " & Type_Name
                      else Type_Name));
               if Argument.Mode /= In_Mode then
                  Line ("mode",
                        (if Argument.Mode = Out_Mode then "out"
                         else "in out"));
               end if;
               if Where.Kind /= No_Place then
                  Line ("place",
                        (case Where.Kind is
                            when Word_Place => "word",
                            when Cap_Place  => "cap",
                            when Item_Place => "item",
                            when List_Place => "list",
                            when No_Place   => "")
                        & Natural'Image (Where.Index)
                        & (if Where.Kind = List_Place
                           then " word" & Natural'Image (Where.Count)
                           else ""));
               end if;
               if Answer.Kind /= No_Place then
                  Line ("result",
                        (case Answer.Kind is
                            when Word_Place => "word",
                            when Cap_Place  => "cap",
                            when others     => "item")
                        & Natural'Image (Answer.Index));
               end if;
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

               if Placed.Kind = Interface_Argument
                 and then Answer.Kind = Cap_Place
               then
                  Return_Cap;
               elsif Placed.Kind = Interface_Argument then
                  --  The mode is the right that the shell grants to the
                  --  cap, so the command takes the client as in.
                  Use_Client;
               else
                  Add_Value (Placed);
               end if;
            end if;
         end;
      end loop;

      if System_Args.To_Array'Length > 0 then
         Main_Context.Add ("Rose.System_Calls");
         Statements.Append
           (F.New_Call_Statement
              (F.New_Call
                 ("Rose.System_Calls.Use_Capabilities",
                  System_Args.To_Array)));
      end if;

      --  The procedure spec.

      Syn.Units.Write
        (F.New_Compilation_Unit
           (Context => Spec_Context.To_Array (F),
            Item    => F.New_Procedure (Name, Parameters.To_Array)),
         Output_Directory);

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
      --  streams and system caps to the run-time system, open the
      --  interface arguments, call the command, and complete with its
      --  results. A server then calls the procedure that its Server
      --  aspect names, which serves and does not return. The main withs
      --  the metadata only to link it into the executable.

      Main_Context.Add ("Rose.Command_Line.Launch");
      Main_Context.Add (Name);
      Main_Context.Add (Metadata_Name);

      if Idle.Commands.Has_Aspect (Item.Aspects, "Server") then
         declare
            Server : constant String :=
              Idle.Commands.Aspect (Item.Aspects, "Server");
            Dot    : Natural := 0;
         begin
            for I in Server'Range loop
               if Server (I) = '.' then
                  Dot := I;
               end if;
            end loop;
            Main_Context.Add
              (if Dot = 0 then Server
               else Server (Server'First .. Dot - 1));
            Serve.Append (F.New_Call_Statement (F.New_Name (Server)));
         end;
      end if;

      Syn.Units.Write
        (F.New_Compilation_Unit
           (Context =>
              Main_Context.To_Array (F)
              & [F.New_Raw ("pragma Unreferenced (" & Metadata_Name & ");")],
            Item    =>
              F.New_Subprogram_Body
                (Specification => F.New_Procedure (Main_Name),
                 Declarations  =>
                   [F.New_Object
                      ("Call",
                       F.New_Name (Launch & "Launch_Call"))]
                   & Declarations.To_Array,
                 Statements    =>
                   [F.New_Call_Statement
                      (F.New_Call
                         (Launch & "Receive", [Call_Node]))]
                   & Statements.To_Array
                   & [F.New_Call_Statement
                        (if Arguments.To_Array'Length = 0
                         then F.New_Name (Name)
                         else F.New_Call (Name, Arguments.To_Array))]
                   & Results.To_Array
                   & [F.New_Call_Statement
                        (F.New_Call (Launch & "Complete", [Call_Node]))]
                   & Serve.To_Array)),
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
