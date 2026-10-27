with Ada.Strings.Unbounded;

with Syn;
with Syn.Factory;
with Syn.Units;

with Idle.Hierarchy;
with Idle.Names;
with Idle.Targets.Kernel.Support;
with Idle.Targets.Kernel.Types;

package body Idle.Targets.Kernel.Client is

   use Ada.Strings.Unbounded;
   use Idle.Targets.Kernel.Support;
   use type Syn.Node_Array;

   System_Calls : constant String := "Rose.System_Calls.";

   --------------
   -- Generate --
   --------------

   procedure Generate
     (Item             : Idle.Syntax.Interface_Declaration;
      Output_Directory : String;
      Target           : Idle.Targets.Target)
   is
      User         : constant Boolean := Target = User_Target;
      --  The user target, whose client type implements the interface's
      --  object type, and raises an exception when a call fails.
      Ada_Name     : constant String :=
        Idle.Names.Ada_Name (To_String (Item.Name));
      Package_Name : constant String :=
        "Rose.Interfaces." & Ada_Name & ".Client";
      Client_Type  : constant String := Ada_Name & "_Client";
      Subprograms  : constant Idle.Syntax.Subprogram_Vectors.Vector :=
        Support.Subprograms (Item);
      Ancestors    : constant Idle.Hierarchy.Interface_Vectors.Vector :=
        Idle.Hierarchy.Ancestors (Item);

      F            : Syn.Factory.Factory;
      Spec_Context : Context_List;
      Body_Context : Context_List;
      Uses_Words   : Boolean := False;
      --  True if the body converts values to Rose.Words types.
      Public_Part  : Node_List;
      Components   : Node_List;
      Body_Specs   : Node_List;
      --  For the user target, the specs of the body's own subprograms.
      Bodies       : Body_List;

      function Call
        (Name      : String;
         Arguments : Syn.Node_Array := Syn.No_Nodes)
         return not null Syn.Node_Access;
      --  A procedure call statement.

      function Cap_Getter (Name : String) return String
      is ("Get_" & Name & "_Cap");
      --  The function that returns the cap of the subprogram Name.

      function Ancestor_Cap
        (Ancestor : Idle.Syntax.Interface_Declaration)
         return String
      is (Idle.Names.Ada_Name (To_String (Ancestor.Name)) & "_Interface_Cap");
      --  For the user target, the component that keeps the interface cap
      --  of Ancestor, once it has been asked for.

      function Load_If_Closed return not null Syn.Node_Access
      is (F.New_If
            (Condition => F.New_Unary ("not", F.New_Name ("Item.Is_Open")),
             Then_Part => [Call ("Load", [F.New_Name ("Item")])]));
      --  For the user target: get the caps of the subprograms, if Item
      --  does not have them yet.

      function Raise_On_Error (What : String) return not null Syn.Node_Access
      is (F.New_If
            (Condition =>
               F.New_Call ("Params.Control.Flags",
                           [F.New_Name ("Rose.Invocation.Error")]),
             Then_Part =>
               [F.New_Raise
                  (F.New_Name ("Rose.Interfaces.Objects.Invocation_Error"),
                   F.New_String_Literal (Ada_Name & "." & What))]));
      --  For the user target: raise Invocation_Error if the invocation
      --  in Params failed.

      function Client_Package (Info : Types.Type_Info) return String;
      --  The client package of the interface Info, or "" if it is this
      --  interface.

      function Client_Type_Of (Info : Types.Type_Info) return String;
      --  The Ada type of Info in the client: the type itself, or for an
      --  interface its client type.

      function Client_Components return Syn.Node_Array;
      --  The components of the client type: whether it is open, its
      --  interface cap, and a cap for each subprogram.

      function Client_Parameter
        (Mode : Syn.Parameter_Mode := Syn.In_Mode)
         return not null Syn.Node_Access;
      --  The client object as the first parameter of a subprogram.

      function Item_Parameter return not null Syn.Node_Access;
      --  The client object as the first parameter of the subprogram of a
      --  member: Item, or for the user target an in out Item, as the
      --  object type declares it.

      procedure Add_Cap_Functions;
      procedure Add_Close;
      procedure Add_Error_Functions;
      procedure Add_From_Cap;
      procedure Add_Getters;
      procedure Add_Load;
      procedure Add_Open;
      procedure Add_Open_Cap_Set;
      procedure Add_Subprogram (Member : Idle.Hierarchy.Member);

      procedure Use_Type
        (Info      : Types.Type_Info;
         Is_Out    : Boolean := False;
         Is_Result : Boolean := False);
      --  Add what the client needs to name values of type Info, an out
      --  parameter if Is_Out, or the function result if Is_Result. For
      --  the user target, the spec names an interface by its object
      --  type, or for an out interface by its client, through a limited
      --  with clause, so that two clients can name each other; the body
      --  opens a client of the interface for an out interface or a
      --  result.

      procedure Write_Conversions;

      -----------------------
      -- Add_Cap_Functions --
      -----------------------

      --  For the user target: the client's cap for each interface that
      --  its object type implements. Its own is its interface cap. That of
      --  the Nth ancestor is asked for with the word N, as the kernel
      --  target's conversions ask for it, the first time it is needed,
      --  and kept.

      procedure Add_Cap_Functions is

         function Specification
           (Interface_Name : String)
            return not null Syn.Node_Access
         is (F.New_Function
               (Cap_Function (Interface_Name), F.New_Name (Capability_Name),
                [F.New_Parameter
                   ("Item", F.New_Name (Client_Type), Syn.In_Out_Mode)],
                Indicator => Syn.Is_Overriding));

         Own   : constant not null Syn.Node_Access :=
           Specification (To_String (Item.Name));
         Index : Natural := 0;

      begin
         Public_Part.Append (Own);
         Bodies.Add
           (Cap_Function (To_String (Item.Name)),
            F.New_Expression_Function
              (Own, F.New_Name ("Item.Interface_Cap")));

         for Ancestor of Ancestors loop
            Index := Index + 1;
            declare
               Ancestor_Name : constant String := To_String (Ancestor.Name);
               Component     : constant not null Syn.Node_Access :=
                 F.New_Name ("Item." & Ancestor_Cap (Ancestor));
               Ancestor_Spec : constant not null Syn.Node_Access :=
                 Specification (Ancestor_Name);
               Params        : constant not null Syn.Node_Access :=
                 F.New_Name ("Params");
               Null_Cap      : constant not null Syn.Node_Access :=
                 F.New_Name ("Rose.Capabilities.Null_Capability");
            begin
               Public_Part.Append (Ancestor_Spec);
               Bodies.Add
                 (Cap_Function (Ancestor_Name),
                  F.New_Subprogram_Body
                    (Specification => Ancestor_Spec,
                     Declarations  =>
                       [F.New_Use
                          ("Rose.Capabilities.Capability", Use_Type => True),
                        F.New_Object
                          ("Params", F.New_Name (Record_Name),
                           Is_Aliased => True)],
                     Statements    =>
                       [F.New_If
                          (Condition =>
                             F.New_Binary
                               (F.New_Binary (Component, "=", Null_Cap),
                                "and then",
                                F.New_Binary
                                  (F.New_Name ("Item.Interface_Cap"), "/=",
                                   Null_Cap)),
                           Then_Part =>
                             [Call (System_Calls & "Initialize_Send",
                                    [Params,
                                     F.New_Name ("Item.Interface_Cap")]),
                              Call (System_Calls & "Send_Word",
                                    [Params,
                                     F.New_Call
                                       ("Natural",
                                        [F.New_Integer_Literal
                                           (Long_Long_Long_Integer
                                              (Index))])]),
                              Call (System_Calls & "Receive_Caps",
                                    [Params, F.New_Integer_Literal (1)]),
                              Call (System_Calls & "Invoke_Capability",
                                    [Params]),
                              Raise_On_Error (Cap_Function (Ancestor_Name)),
                              F.New_Assignment
                                (Component,
                                 F.New_Call
                                   ("Params.Caps",
                                    [F.New_Integer_Literal (0)]))]),
                        F.New_Return (Component)]));
            end;
         end loop;
      end Add_Cap_Functions;

      ---------------
      -- Add_Close --
      ---------------

      procedure Add_Close is
         Specification : constant not null Syn.Node_Access :=
           F.New_Procedure ("Close", [Client_Parameter (Syn.In_Out_Mode)]);

         function Delete (Cap : String) return Syn.Node_Array
         is ([Call (System_Calls & "Initialize_Send",
                    [F.New_Name ("Params"),
                     F.New_Name (System_Calls & "Delete_Cap_Capability")]),
              Call (System_Calls & "Send_Cap",
                    [F.New_Name ("Params"), F.New_Name ("Client." & Cap)]),
              Call (System_Calls & "Invoke_Capability",
                    [F.New_Name ("Params")])]);
         --  Delete the cap Client.Cap. The invocation is made here, and not
         --  through Rose.System_Calls.Delete_Cap, whose call to
         --  Invoke_Capability can be inlined, which breaks the invocation.

         Statements : Node_List;
         Own_Caps   : Node_List;
      begin
         for Subprogram of Subprograms loop
            for Statement of Delete (Name (Subprogram)) loop
               Own_Caps.Append (Statement);
            end loop;
         end loop;

         if User then
            --  The caps of the subprograms, and of the ancestors, are
            --  there only if they were asked for.
            Statements.Append
              (F.New_If
                 (Condition => F.New_Name ("Client.Is_Open"),
                  Then_Part => Own_Caps.To_Array));
            Statements.Append
              (F.New_Assignment
                 (F.New_Name ("Client.Is_Open"), F.New_Name ("False")));
            for Ancestor of Ancestors loop
               Statements.Append
                 (F.New_If
                    (Condition =>
                       F.New_Binary
                         (F.New_Name ("Client." & Ancestor_Cap (Ancestor)),
                          "/=",
                          F.New_Name ("Rose.Capabilities.Null_Capability")),
                     Then_Part =>
                       Delete (Ancestor_Cap (Ancestor))
                       & [F.New_Assignment
                            (F.New_Name
                               ("Client." & Ancestor_Cap (Ancestor)),
                             F.New_Name
                               ("Rose.Capabilities.Null_Capability"))]));
            end loop;
         else
            Statements.Append
              (F.New_Assignment
                 (F.New_Name ("Client.Is_Open"), F.New_Name ("False")));
            for Statement of Own_Caps.To_Array loop
               Statements.Append (Statement);
            end loop;
         end if;
         for Statement of Delete ("Interface_Cap") loop
            Statements.Append (Statement);
         end loop;

         Public_Part.Append (Specification);
         Bodies.Add
           ("Close",
            F.New_Subprogram_Body
              (Specification => Specification,
               Declarations  =>
                 (if User and then not Ancestors.Is_Empty
                  then [F.New_Use ("Rose.Capabilities.Capability",
                                   Use_Type => True)]
                  else Syn.No_Nodes)
                 & [F.New_Object
                      ("Params", F.New_Name (Record_Name),
                       Is_Aliased => True)],
               Statements    => Statements.To_Array));
      end Add_Close;

      -------------------------
      -- Add_Error_Functions --
      -------------------------

      procedure Add_Error_Functions is
         Has_Error : constant not null Syn.Node_Access :=
           F.New_Function ("Has_Error", F.New_Name ("Boolean"));
         Get_Last_Error : constant not null Syn.Node_Access :=
           F.New_Function ("Get_Last_Error",
                           F.New_Name ("Rose.Invocation.Invocation_Error"));
      begin
         Spec_Context.Add ("Rose.Invocation");
         Public_Part.Append (Has_Error);
         Public_Part.Append (Get_Last_Error);
         Bodies.Add
           ("Has_Error",
            F.New_Expression_Function
              (Has_Error,
               F.New_Binary (F.New_Name ("Last_Error"), "/=",
                             F.New_Name ("Rose.Invocation.OK"))));
         Bodies.Add
           ("Get_Last_Error",
            F.New_Expression_Function
              (Get_Last_Error, F.New_Name ("Last_Error")));
      end Add_Error_Functions;

      ------------------
      -- Add_From_Cap --
      ------------------

      --  For the user target: a client opened from an interface cap, as
      --  Open opens one, which an interface result is built from.

      procedure Add_From_Cap is
         Specification : constant not null Syn.Node_Access :=
           F.New_Function
             ("From_Cap", F.New_Name (Client_Type),
              [F.New_Parameter ("Cap", F.New_Name (Capability_Name))]);
      begin
         Public_Part.Append (Specification);
         Bodies.Add
           ("From_Cap",
            F.New_Expression_Function
              (Specification,
               F.New_Raw
                 (Client_Type
                  & "'(Interface_Cap => Cap, others => <>)")));
      end Add_From_Cap;

      -----------------
      -- Add_Getters --
      -----------------

      procedure Add_Getters is

         procedure Add_Getter (Name, Component : String);

         ----------------
         -- Add_Getter --
         ----------------

         procedure Add_Getter (Name, Component : String) is
            Loads : constant Boolean :=
              User and then Component /= "Interface_Cap";
            --  For the user target, the caps of the subprograms are got
            --  first, if the client does not have them yet.
            Specification : constant not null Syn.Node_Access :=
              F.New_Function
                (Name, F.New_Name (Capability_Name),
                 [(if Loads
                   then F.New_Parameter
                          ("Item", F.New_Name (Client_Type),
                           Syn.In_Out_Mode)
                   else Client_Parameter)]);
         begin
            Public_Part.Append (Specification);
            if Loads then
               Bodies.Add
                 (Name,
                  F.New_Subprogram_Body
                    (Specification => Specification,
                     Statements    =>
                       [Load_If_Closed,
                        F.New_Return (F.New_Name ("Item." & Component))]));
            else
               Bodies.Add
                 (Name,
                  F.New_Expression_Function
                    (Specification, F.New_Name ("Item." & Component)));
            end if;
         end Add_Getter;

      begin
         Add_Getter ("Get_Interface_Cap", "Interface_Cap");
         for Subprogram of Subprograms loop
            Add_Getter (Cap_Getter (Name (Subprogram)), Name (Subprogram));
         end loop;
      end Add_Getters;

      --------------
      -- Add_Load --
      --------------

      --  For the user target: get the caps of the subprograms from the
      --  interface cap, which Add_Open does for the kernel target. A
      --  client gets them on its first call, so that opening one is not
      --  an invocation: a server that receives an object of its caller
      --  cannot invoke it while the caller waits for the reply.

      procedure Add_Load is
         Specification : constant not null Syn.Node_Access :=
           F.New_Procedure
             ("Load",
              [F.New_Parameter
                 ("Item", F.New_Name (Client_Type), Syn.In_Out_Mode)]);
         Params : constant not null Syn.Node_Access := F.New_Name ("Params");
      begin
         Body_Specs.Append (Specification);
         Bodies.Add
           ("Load",
            F.New_Subprogram_Body
              (Specification => Specification,
               Declarations  =>
                 [F.New_Object
                    ("Params", F.New_Name (Record_Name),
                     Is_Aliased => True)],
               Statements    =>
                 [Call (System_Calls & "Initialize_Send",
                        [Params, F.New_Name ("Item.Interface_Cap")]),
                  Call (System_Calls & "Receive_Caps",
                        [Params, F.New_Name (Count_Name)]),
                  Call (System_Calls & "Invoke_Capability", [Params]),
                  Raise_On_Error ("Open")]
                 & [for Subprogram of Subprograms =>
                      F.New_Assignment
                        (F.New_Name ("Item." & Name (Subprogram)),
                         F.New_Call
                           ("Params.Caps",
                            [F.New_Name (Index_Name (Subprogram))]))]
                 & [F.New_Assignment
                      (F.New_Name ("Item.Is_Open"), F.New_Name ("True"))]));
      end Add_Load;

      --------------
      -- Add_Open --
      --------------

      --  Invoking the interface cap returns a cap for each subprogram, at
      --  the position given by its index constant in the interface
      --  package.

      procedure Add_Open is
         Specification : constant not null Syn.Node_Access :=
           F.New_Procedure
             ("Open",
              [Client_Parameter (Syn.Out_Mode),
               F.New_Parameter ("Interface_Cap",
                                F.New_Name (Capability_Name))]);
         Caps : constant Syn.Node_Array :=
           [for Subprogram of Subprograms =>
              F.New_Assignment
                (F.New_Name ("Client." & Name (Subprogram)),
                 F.New_Call
                   ("Params.Caps", [F.New_Name (Index_Name (Subprogram))]))];
      begin
         Public_Part.Append (Specification);
         if User then
            Bodies.Add
              ("Open",
               F.New_Subprogram_Body
                 (Specification => Specification,
                  Statements    =>
                    [F.New_Assignment
                       (F.New_Name ("Client.Is_Open"), F.New_Name ("False")),
                     F.New_Assignment
                       (F.New_Name ("Client.Interface_Cap"),
                        F.New_Name ("Interface_Cap"))]
                    & [for Ancestor of Ancestors =>
                         F.New_Assignment
                           (F.New_Name ("Client." & Ancestor_Cap (Ancestor)),
                            F.New_Name
                              ("Rose.Capabilities.Null_Capability"))]));
            return;
         end if;
         Bodies.Add
           ("Open",
            F.New_Subprogram_Body
              (Specification => Specification,
               Declarations  =>
                 [F.New_Object
                    ("Params", F.New_Name (Record_Name),
                     Is_Aliased => True)],
               Statements    =>
                 [F.New_Assignment
                    (F.New_Name ("Client.Is_Open"), F.New_Name ("False")),
                  F.New_Assignment
                    (F.New_Name ("Client.Interface_Cap"),
                     F.New_Name ("Interface_Cap")),
                  Call (System_Calls & "Initialize_Send",
                        [F.New_Name ("Params"),
                         F.New_Name ("Interface_Cap")]),
                  Call (System_Calls & "Receive_Caps",
                        [F.New_Name ("Params"), F.New_Name (Count_Name)]),
                  Call (System_Calls & "Invoke_Capability",
                        [F.New_Name ("Params")])]
                 & Caps
                 & [F.New_Assignment
                      (F.New_Name ("Client.Is_Open"),
                       F.New_Name ("True"))]));
      end Add_Open;

      ----------------------
      -- Add_Open_Cap_Set --
      ----------------------

      --  Open a client from caps that the caller already has, one for
      --  each subprogram, without an interface cap.

      procedure Add_Open_Cap_Set is
         Specification : constant not null Syn.Node_Access :=
           F.New_Procedure
             ("Open_Cap_Set",
              [Client_Parameter (Syn.Out_Mode)]
              & [for Subprogram of Subprograms =>
                   F.New_Parameter
                     (Name (Subprogram), F.New_Name (Capability_Name))]);
      begin
         Public_Part.Append (Specification);
         Bodies.Add
           ("Open_Cap_Set",
            F.New_Subprogram_Body
              (Specification => Specification,
               Statements    =>
                 [for Subprogram of Subprograms =>
                    F.New_Assignment
                      (F.New_Name ("Client." & Name (Subprogram)),
                       F.New_Name (Name (Subprogram)))]
                 & [F.New_Assignment
                      (F.New_Name ("Client.Is_Open"),
                       F.New_Name ("True"))]));
      end Add_Open_Cap_Set;

      --------------------
      -- Add_Subprogram --
      --------------------

      --  Words are sent in data words and caps in cap slots, each in the
      --  order of the parameters; a string or array travels in the
      --  invocation buffer. The reply holds the out values, in order,
      --  then the function result: words and string lengths in data
      --  words, and caps and interfaces in cap slots. An interface is
      --  opened as a client of that interface. A string is copied from
      --  the buffer, and its length is its data word in the reply.

      procedure Add_Subprogram (Member : Idle.Hierarchy.Member) is
         use all type Types.Category;
         use type Idle.Syntax.Parameter_Mode;

         Subprogram      : Idle.Syntax.Subprogram renames Member.Subprogram;
         Subprogram_Name : constant String := Name (Subprogram);
         Result          : constant Types.Type_Info :=
           (if Subprogram.Is_Function
            then Types.Resolve (Member.Owner, Subprogram.Result)
            else (others => <>));
         Returns_String  : constant Boolean :=
           Subprogram.Is_Function and then Result.Category = String_Value;

         function Info
           (Parameter : Idle.Syntax.Parameter)
            return Types.Type_Info
         is (Types.Resolve (Member.Owner, Parameter.Of_Type));

         function Mode
           (Parameter : Idle.Syntax.Parameter)
            return Syn.Parameter_Mode
         is (case Parameter.Mode is
                when Idle.Syntax.In_Mode     => Syn.In_Mode,
                when Idle.Syntax.Out_Mode    => Syn.Out_Mode,
                when Idle.Syntax.In_Out_Mode => Syn.In_Out_Mode);

         function Params return not null Syn.Node_Access
         is (F.New_Name ("Params"));

         function Reply_Word (Index : Natural) return not null Syn.Node_Access
         is (F.New_Call
               ("Natural",
                [F.New_Call
                   (System_Calls & "Get_Word_32",
                    [Params,
                     F.New_Integer_Literal
                       (Long_Long_Long_Integer (Index))])]));
         --  The data word Index of the reply, as a length.

         function Profile return Syn.Node_Array;
         --  The parameters, with a length after each out or in out
         --  string.

         -------------
         -- Profile --
         -------------

         function Profile return Syn.Node_Array is
            Result : Node_List;
         begin
            for Parameter of Subprogram.Parameters loop
               if User and then Info (Parameter).Category = Interface_Value
               then
                  --  An object of the interface, or a client for an out
                  --  interface, which is opened from the cap in the reply.
                  Result.Append
                    (F.New_Parameter
                       (Name (Parameter),
                        F.New_Name
                          (if Parameter.Mode = Idle.Syntax.Out_Mode
                           then Client_Type_Of (Info (Parameter))
                           else Types.Object_Class (Info (Parameter))),
                        Syn.In_Out_Mode));
               elsif User
                 and then Info (Parameter).Category = String_Value
                 and then Parameter.Mode /= Idle.Syntax.In_Mode
               then
                  --  A text, which the client sets from the reply.
                  Result.Append
                    (F.New_Parameter
                       (Name (Parameter), F.New_Name (Text_Name),
                        Mode (Parameter)));
               else
                  Result.Append
                    (F.New_Parameter
                       (Name (Parameter),
                        F.New_Name (Client_Type_Of (Info (Parameter))),
                        Mode (Parameter)));
               end if;
               if Info (Parameter).Category = String_Value
                 and then Parameter.Mode /= Idle.Syntax.In_Mode
                 and then not User
               then
                  Result.Append
                    (F.New_Parameter
                       (Name (Parameter) & "_Last", F.New_Name ("Natural"),
                        Syn.Out_Mode));
               end if;
            end loop;
            return Result.To_Array;
         end Profile;

         Parameters : constant Syn.Node_Array :=
           [Item_Parameter]
           & Profile
           & (if Returns_String and then not User
              then [F.New_Parameter
                      ("Result", F.New_Name ("String"), Syn.Out_Mode),
                    F.New_Parameter
                      ("Last", F.New_Name ("Natural"), Syn.Out_Mode)]
              else Syn.No_Nodes);

         Indicator     : constant Syn.Overriding_Kind :=
           (if User then Syn.Is_Overriding else Syn.No_Indicator);

         Specification : constant not null Syn.Node_Access :=
           (if Subprogram.Is_Function
              and then (User or else not Returns_String)
            then F.New_Function
                   (Subprogram_Name,
                    F.New_Name
                      (if User and then Result.Category = Interface_Value
                       then Types.Object_Class (Result)
                       else Client_Type_Of (Result)),
                    Parameters,
                    Indicator => Indicator)
            else F.New_Procedure
                   (Subprogram_Name, Parameters, Indicator => Indicator));

         Statements  : Node_List;
         Reply_Words : Natural := 0;
         Reply_Caps  : Natural := 0;
         Index       : Natural := 0;
         Cap_Index   : Natural := 0;

      begin
         Public_Part.Append (Specification);
         Components.Append
           (F.New_Component
              (Subprogram_Name, F.New_Name (Capability_Name),
               F.New_Name ("Rose.Capabilities.Null_Capability")));

         if User then
            Statements.Append (Load_If_Closed);
         end if;
         Statements.Append
           (Call (System_Calls & "Initialize_Send",
                  [Params, F.New_Name ("Item." & Subprogram_Name)]));

         for Parameter of Subprogram.Parameters loop
            declare
               Parameter_Info : constant Types.Type_Info := Info (Parameter);
               Value          : constant not null Syn.Node_Access :=
                 F.New_Name (Name (Parameter));
            begin
               Use_Type
                 (Parameter_Info,
                  Is_Out => Parameter.Mode = Idle.Syntax.Out_Mode);

               if Parameter.Mode /= Idle.Syntax.Out_Mode then
                  case Parameter_Info.Category is
                     when Word_Value | Double_Word_Value =>
                        Statements.Append
                          (Types.Send
                             (F, Parameter_Info, "Params", Name (Parameter)));
                     when Capability_Value =>
                        Statements.Append
                          (Call (System_Calls & "Send_Cap", [Params, Value]));
                     when Interface_Value =>
                        Statements.Append
                          (Call (System_Calls & "Send_Cap",
                                 [Params,
                                  (if User
                                   then F.New_Name
                                          (Name (Parameter) & "."
                                           & Types.Cap_Function
                                               (Parameter_Info))
                                   else F.New_Call
                                          (Qualified
                                             (Client_Package (Parameter_Info),
                                              "Get_Interface_Cap"),
                                           [Value]))]));
                     when Capability_Array_Value =>
                        Statements.Append
                          (F.New_For_Of_Loop
                             ("Cap", Value,
                              [Call (System_Calls & "Send_Cap",
                                     [Params, F.New_Name ("Cap")])]));
                     when String_Value =>
                        Statements.Append
                          (Call (System_Calls & "Send_Text",
                                 [Params,
                                  (if User
                                     and then Parameter.Mode
                                              = Idle.Syntax.In_Out_Mode
                                   then F.New_Call
                                          ("Rose.Texts.To_String", [Value])
                                   else Value)]));
                        if Parameter.Mode = Idle.Syntax.In_Out_Mode then
                           --  The server writes the new text in place.
                           Statements.Append
                             (F.New_Assignment
                                (F.New_Call
                                   ("Params.Control.Flags",
                                    [F.New_Name
                                       ("Rose.Invocation.Writable_Buffer")]),
                                 F.New_Name ("True")));
                        end if;
                     when Storage_Value =>
                        Statements.Append
                          (Call (System_Calls & "Send_Storage_Array",
                                 [Params, Value,
                                  F.New_Name
                                    (if Parameter.Mode = Idle.Syntax.In_Mode
                                     then "False" else "True")]));
                     when Unknown =>
                        raise Program_Error;
                  end case;
               elsif User and then Parameter_Info.Category = String_Value then
                  Statements.Append
                    (Call (System_Calls & "Receive_Buffer",
                           [Params,
                            F.New_Name ("Rose.Texts.Max_Length")]));
               elsif Types.Is_Buffer (Parameter_Info) then
                  Statements.Append
                    (Call (System_Calls & "Receive_Buffer",
                           [Params, F.New_Attribute (Value, "Length")]));
               end if;

               if User
                 and then Parameter_Info.Category = String_Value
                 and then Parameter.Mode /= Idle.Syntax.In_Mode
               then
                  Spec_Context.Add ("Rose.Texts");
               end if;

               if Parameter.Mode /= Idle.Syntax.In_Mode then
                  Reply_Words :=
                    Reply_Words + Types.Words (Parameter_Info)
                    + (if Parameter_Info.Category = String_Value
                       then 1 else 0);
                  if Parameter_Info.Category in
                    Capability_Value | Interface_Value
                  then
                     Reply_Caps := Reply_Caps + 1;
                  end if;
               end if;
            end;
         end loop;

         if Subprogram.Is_Function then
            Use_Type (Result, Is_Result => True);
            Reply_Words :=
              Reply_Words
              + (if Returns_String then 1 else Types.Words (Result));
         end if;

         if Reply_Words > 0 then
            Statements.Append
              (Call (System_Calls & "Receive_Words",
                     [Params,
                      F.New_Integer_Literal
                        (Long_Long_Long_Integer (Reply_Words))]));
         end if;
         if Subprogram.Is_Function
           and then Result.Category in Capability_Value | Interface_Value
         then
            Reply_Caps := Reply_Caps + 1;
         end if;
         if Reply_Caps > 0 then
            Statements.Append
              (Call (System_Calls & "Receive_Caps",
                     [Params,
                      F.New_Integer_Literal
                        (Long_Long_Long_Integer (Reply_Caps))]));
         end if;
         if Returns_String then
            Statements.Append
              (Call (System_Calls & "Receive_Buffer", [Params]));
         end if;

         Statements.Append
           (Call (System_Calls & "Invoke_Capability", [Params]));
         if User then
            Statements.Append (Raise_On_Error (Subprogram_Name));
         else
            Statements.Append
              (F.New_Assignment
                 (F.New_Name ("Last_Error"),
                  F.New_Name ("Rose.Invocation.OK")));
            Statements.Append
              (F.New_If
                 (Condition =>
                    F.New_Call ("Params.Control.Flags",
                                [F.New_Name ("Rose.Invocation.Error")]),
                  Then_Part =>
                    [F.New_Assignment
                       (F.New_Name ("Last_Error"),
                        F.New_Name ("Params.Error"))]));
         end if;

         for Parameter of Subprogram.Parameters loop
            if Parameter.Mode /= Idle.Syntax.In_Mode then
               declare
                  Parameter_Info : constant Types.Type_Info :=
                    Info (Parameter);
                  Value          : constant not null Syn.Node_Access :=
                    F.New_Name (Name (Parameter));
               begin
                  if Parameter_Info.Category = String_Value and then User then
                     --  The text is copied from the reply.
                     Statements.Append
                       (F.New_Block
                          (Declarations =>
                             [F.New_Object
                                ("Received",
                                 F.New_Call
                                   ("String",
                                    [F.New_Binary
                                       (F.New_Integer_Literal (1), "..",
                                        F.New_Name
                                          ("Rose.Texts.Max_Length"))])),
                              F.New_Object
                                ("Received_Last", F.New_Name ("Natural"))],
                           Statements   =>
                             [Call (System_Calls & "Copy_Text",
                                    [Params,
                                     Reply_Word (Index),
                                     F.New_Name ("Received"),
                                     F.New_Name ("Received_Last")]),
                              F.New_Assignment
                                (Value,
                                 F.New_Call
                                   ("Rose.Texts.To_Text",
                                    [F.New_Call
                                       ("Received",
                                        [F.New_Binary
                                           (F.New_Integer_Literal (1), "..",
                                            F.New_Name
                                              ("Received_Last"))])]))]));
                     Index := Index + 1;
                  elsif Parameter_Info.Category = String_Value then
                     Statements.Append
                       (Call (System_Calls & "Copy_Text",
                              [Params,
                               F.New_Call
                                 ("Natural",
                                  [F.New_Call
                                     (System_Calls & "Get_Word_32",
                                      [Params,
                                       F.New_Integer_Literal
                                         (Long_Long_Long_Integer (Index))])]),
                               Value,
                               F.New_Name (Name (Parameter) & "_Last")]));
                     Index := Index + 1;
                  elsif Types.Is_Buffer (Parameter_Info) then
                     Statements.Append
                       (Call (System_Calls & "Copy_Received_Buffer",
                              [F.New_Attribute (Value, "Length"),
                               F.New_Attribute (Value, "Address")]));
                  elsif Parameter_Info.Category = Capability_Value then
                     Statements.Append
                       (F.New_Assignment
                          (Value,
                           F.New_Call
                             ("Params.Caps",
                              [F.New_Integer_Literal
                                 (Long_Long_Long_Integer (Cap_Index))])));
                     Cap_Index := Cap_Index + 1;
                  elsif Parameter_Info.Category = Interface_Value
                    and then User
                    and then Parameter.Mode = Idle.Syntax.In_Out_Mode
                  then
                     --  The object was passed by reference, and is still
                     --  the caller's: the cap that the server sends back
                     --  is not used.
                     Cap_Index := Cap_Index + 1;
                  elsif Parameter_Info.Category = Interface_Value then
                     Statements.Append
                       (Call (Qualified (Client_Package (Parameter_Info),
                                         "Open"),
                              [Value,
                               F.New_Call
                                 ("Params.Caps",
                                  [F.New_Integer_Literal
                                     (Long_Long_Long_Integer (Cap_Index))])]));
                     Cap_Index := Cap_Index + 1;
                  else
                     Statements.Append
                       (F.New_Assignment
                          (Value,
                           Types.Decode (F, Parameter_Info, "Params", Index)));
                     Index := Index + Types.Words (Parameter_Info);
                  end if;
               end;
            end if;
         end loop;

         if Subprogram.Is_Function then
            case Result.Category is
               when Word_Value | Double_Word_Value =>
                  Statements.Append
                    (F.New_Return (Types.Decode (F, Result, "Params", Index)));
               when Capability_Value =>
                  Statements.Append
                    (F.New_Return
                       (F.New_Call
                          ("Params.Caps",
                           [F.New_Integer_Literal
                              (Long_Long_Long_Integer (Cap_Index))])));
               when Interface_Value =>
                  Statements.Append
                    (if User
                     then F.New_Return
                            (F.New_Call
                               (Qualified (Client_Package (Result),
                                           "From_Cap"),
                                [F.New_Call
                                   ("Params.Caps",
                                    [F.New_Integer_Literal
                                       (Long_Long_Long_Integer
                                          (Cap_Index))])]))
                     else F.New_Block
                       (Declarations =>
                          [F.New_Object
                             ("Result",
                              F.New_Name (Client_Type_Of (Result)))],
                        Statements   =>
                          [Call (Qualified (Client_Package (Result), "Open"),
                                 [F.New_Name ("Result"),
                                  F.New_Call
                                    ("Params.Caps",
                                     [F.New_Integer_Literal
                                        (Long_Long_Long_Integer
                                           (Cap_Index))])]),
                           F.New_Return (F.New_Name ("Result"))]));
               when String_Value =>
                  if User then
                     --  A string of the length in the reply, copied from
                     --  it.
                     Statements.Append
                       (F.New_Block
                          (Declarations =>
                             [F.New_Object
                                ("Result",
                                 F.New_Call
                                   ("String",
                                    [F.New_Binary
                                       (F.New_Integer_Literal (1), "..",
                                        Reply_Word (Index))])),
                              F.New_Object ("Last", F.New_Name ("Natural"))],
                           Statements   =>
                             [Call (System_Calls & "Copy_Text",
                                    [Params,
                                     F.New_Attribute
                                       (F.New_Name ("Result"), "Length"),
                                     F.New_Name ("Result"),
                                     F.New_Name ("Last")]),
                              F.New_Return
                                (F.New_Call
                                   ("Result",
                                    [F.New_Binary
                                       (F.New_Integer_Literal (1), "..",
                                        F.New_Name ("Last"))]))]));
                  else
                     Statements.Append
                       (Call (System_Calls & "Copy_Text",
                              [Params, Reply_Word (Index),
                               F.New_Name ("Result"),
                               F.New_Name ("Last")]));
                  end if;
               when Capability_Array_Value | Storage_Value | Unknown =>
                  raise Program_Error;
            end case;
         end if;

         Bodies.Add
           (Subprogram_Name,
            F.New_Subprogram_Body
              (Specification => Specification,
               Declarations  =>
                 [F.New_Object
                    ("Params", F.New_Name (Record_Name),
                     Is_Aliased => True)],
               Statements    => Statements.To_Array));
      end Add_Subprogram;

      ----------
      -- Call --
      ----------

      function Call
        (Name      : String;
         Arguments : Syn.Node_Array := Syn.No_Nodes)
         return not null Syn.Node_Access
      is
      begin
         if Arguments'Length = 0 then
            return F.New_Call_Statement (F.New_Name (Name));
         else
            return F.New_Call_Statement (F.New_Call (Name, Arguments));
         end if;
      end Call;

      -----------------------
      -- Client_Components --
      -----------------------

      function Client_Components return Syn.Node_Array is
      begin
         return [F.New_Component
                   ("Is_Open", F.New_Name ("Boolean"), F.New_Name ("False")),
                 F.New_Component
                   ("Interface_Cap", F.New_Name (Capability_Name),
                    F.New_Name ("Rose.Capabilities.Null_Capability"))]
           & (if User
              then [for Ancestor of Ancestors =>
                      F.New_Component
                        (Ancestor_Cap (Ancestor),
                         F.New_Name (Capability_Name),
                         F.New_Name ("Rose.Capabilities.Null_Capability"))]
              else Syn.No_Nodes)
           & Components.To_Array;
      end Client_Components;

      --------------------
      -- Client_Package --
      --------------------

      function Client_Package (Info : Types.Type_Info) return String is
      begin
         if Idle.Names.Key (To_String (Info.Interface_Name))
           = Idle.Names.Key (Ada_Name)
         then
            return "";
         else
            return To_String (Info.Unit);
         end if;
      end Client_Package;

      ----------------------
      -- Client_Parameter --
      ----------------------

      function Client_Parameter
        (Mode : Syn.Parameter_Mode := Syn.In_Mode)
         return not null Syn.Node_Access
      is
      begin
         return F.New_Parameter
           ((if Mode in Syn.In_Mode then "Item" else "Client"),
            F.New_Name (Client_Type), Mode);
      end Client_Parameter;

      --------------------
      -- Client_Type_Of --
      --------------------

      function Client_Type_Of (Info : Types.Type_Info) return String is
      begin
         if Info.Category in Types.Interface_Value
           and then Client_Package (Info) = ""
         then
            return Client_Type;
         else
            return To_String (Info.Ada_Name);
         end if;
      end Client_Type_Of;

      --------------------
      -- Item_Parameter --
      --------------------

      function Item_Parameter return not null Syn.Node_Access is
      begin
         if User then
            --  For functions too: the client gets its caps on its first
            --  call.
            return F.New_Parameter
              ("Item", F.New_Name (Client_Type), Syn.In_Out_Mode);
         else
            return Client_Parameter;
         end if;
      end Item_Parameter;

      --------------
      -- Use_Type --
      --------------

      procedure Use_Type
        (Info      : Types.Type_Info;
         Is_Out    : Boolean := False;
         Is_Result : Boolean := False)
      is
         Unit : constant String := To_String (Info.Unit);
      begin
         if User and then Info.Category in Types.Interface_Value then
            if Unit /= Package_Name then
               if Is_Out then
                  Spec_Context.Add_Limited (Unit);
               end if;
               if Is_Out or else Is_Result then
                  Body_Context.Add (Unit);
               end if;
            end if;
            if not Is_Out
              and then Types.Object_Unit (Info)
                         /= "Rose.Interfaces." & Ada_Name
            then
               Spec_Context.Add (Types.Object_Unit (Info));
            end if;
         elsif Unit /= ""
           and then Unit /= "Rose.Interfaces." & Ada_Name
           and then Unit /= Package_Name
         then
            Spec_Context.Add (Unit);
         end if;
         if Types.Uses_Words_Unit (Info) then
            Uses_Words := True;
         end if;
      end Use_Type;

      -----------------------
      -- Write_Conversions --
      -----------------------

      --  A client of each ancestor, which can call only the ancestor's
      --  subprograms. If the client has an interface cap, the server is
      --  asked for the interface cap of the ancestor (the word sent is
      --  its position in Idle.Hierarchy.Ancestors), and the result is
      --  opened from it, so it can be sent to another process. A
      --  writable directory is passed as a read-only one this way.
      --  Otherwise the result is opened from the caps of the ancestor's
      --  subprograms, and has no interface cap. Neither can be used to
      --  get this interface's caps back.
      --
      --  The conversions are a child of the client, written only for an
      --  interface with ancestors, so that only a program that converts
      --  depends on the ancestors' clients.

      procedure Write_Conversions is
         Ancestors           : constant Idle.Hierarchy.Interface_Vectors.Vector
           := Idle.Hierarchy.Ancestors (Item);
         Conversions_Context : Context_List;
         Conversions_Body    : Context_List;
         Conversions_Part    : Node_List;
         Conversions_Bodies  : Body_List;
         Index               : Natural := 0;
      begin
         if Ancestors.Is_Empty then
            return;
         end if;

         for Ancestor of Ancestors loop
            Index := Index + 1;
            declare
               Ancestor_Name : constant String :=
                 Idle.Names.Ada_Name (To_String (Ancestor.Name));
               Ancestor_Package : constant String :=
                 "Rose.Interfaces." & Ancestor_Name & ".Client";
               Ancestor_Type : constant String :=
                 Ancestor_Package & "." & Ancestor_Name & "_Client";
               Specification : constant not null Syn.Node_Access :=
                 F.New_Function
                   ("To_" & Ancestor_Name, F.New_Name (Ancestor_Type),
                    [Client_Parameter]);
               Params : constant not null Syn.Node_Access :=
                 F.New_Name ("Params");
            begin
               Conversions_Context.Add (Ancestor_Package);
               Conversions_Part.Append (Specification);
               Conversions_Bodies.Add
                 ("To_" & Ancestor_Name,
                  F.New_Subprogram_Body
                    (Specification => Specification,
                     Declarations  =>
                       [F.New_Use
                          ("Rose.Capabilities.Capability", Use_Type => True),
                        F.New_Object
                          ("Params", F.New_Name (Record_Name),
                           Is_Aliased => True),
                        F.New_Object
                          ("Result", F.New_Name (Ancestor_Type))],
                     Statements    =>
                       [F.New_If
                          (Condition =>
                             F.New_Binary
                               (F.New_Name ("Item.Interface_Cap"), "=",
                                F.New_Name
                                  ("Rose.Capabilities.Null_Capability")),
                           Then_Part =>
                             [Call
                                (Ancestor_Package & ".Open_Cap_Set",
                                 [F.New_Name ("Result")]
                                 & [for Subprogram of Support.Subprograms
                                                        (Ancestor) =>
                                      F.New_Name
                                        ("Item." & Name (Subprogram))])],
                           Else_Part =>
                             [Call (System_Calls & "Initialize_Send",
                                    [Params,
                                     F.New_Name ("Item.Interface_Cap")]),
                              Call (System_Calls & "Send_Word",
                                    [Params,
                                     F.New_Call
                                       ("Natural",
                                        [F.New_Integer_Literal
                                           (Long_Long_Long_Integer
                                              (Index))])]),
                              Call (System_Calls & "Receive_Caps",
                                    [Params, F.New_Integer_Literal (1)]),
                              Call (System_Calls & "Invoke_Capability",
                                    [Params]),
                              Call (Ancestor_Package & ".Open",
                                    [F.New_Name ("Result"),
                                     F.New_Call
                                       ("Params.Caps",
                                        [F.New_Integer_Literal (0)])])]),
                        F.New_Return (F.New_Name ("Result"))]));
            end;
         end loop;

         Conversions_Body.Add ("Rose.Invocation");
         Conversions_Body.Add ("Rose.System_Calls");

         Syn.Units.Write
           (F.New_Compilation_Unit
              (Context => Conversions_Context.To_Array (F),
               Item    =>
                 F.New_Package
                   (Name        => Package_Name & ".Conversions",
                    Public_Part => Conversions_Part.To_Array)),
            Output_Directory);

         Syn.Units.Write
           (F.New_Compilation_Unit
              (Context => Conversions_Body.To_Array (F),
               Item    =>
                 F.New_Package_Body
                   (Name         => Package_Name & ".Conversions",
                    Declarations => Conversions_Bodies.To_Array)),
            Output_Directory);
      end Write_Conversions;

   begin
      if User then
         Public_Part.Append
           (F.New_Private_Extension
              (Client_Type, F.New_Name (Object_Type (To_String (Item.Name))),
               Is_Limited => True));
      else
         Public_Part.Append (F.New_Private_Type (Client_Type));
      end if;
      Spec_Context.Add ("Rose.Capabilities");

      Add_Open_Cap_Set;
      Add_Open;
      if User then
         Add_From_Cap;
         Add_Load;
      end if;
      Add_Close;
      for Member of Idle.Hierarchy.Members (Item) loop
         Add_Subprogram (Member);
      end loop;
      if User then
         Add_Cap_Functions;
      end if;
      Add_Getters;
      if not User then
         Add_Error_Functions;
      end if;

      Body_Context.Add ("Rose.System_Calls");
      if User then
         Body_Context.Add ("Rose.Interfaces.Objects");
         Body_Context.Add ("Rose.Invocation");
      end if;
      if Uses_Words and then not Spec_Context.Contains ("Rose.Words") then
         Body_Context.Add ("Rose.Words");
      end if;

      Syn.Units.Write
        (F.New_Compilation_Unit
           (Context => Spec_Context.To_Array (F),
            Item    =>
              F.New_Package
                (Name         => Package_Name,
                 Public_Part  => Public_Part.To_Array,
                 Private_Part =>
                   [(if User
                     then F.New_Record_Extension
                            (Client_Type,
                             F.New_Name (Object_Type (To_String (Item.Name))),
                             Components => Client_Components,
                             Is_Limited => True)
                     else F.New_Record_Type
                            (Client_Type, Client_Components))])),
         Output_Directory);

      Syn.Units.Write
        (F.New_Compilation_Unit
           (Context => Body_Context.To_Array (F),
            Item    =>
              F.New_Package_Body
                (Name         => Package_Name,
                 Declarations =>
                   (if User
                    then Body_Specs.To_Array
                    else [F.New_Use ("Rose.Invocation.Invocation_Error",
                                     Use_Type => True),
                          F.New_Object
                            ("Last_Error",
                             F.New_Name ("Rose.Invocation.Invocation_Error"),
                             F.New_Name ("Rose.Invocation.OK"))])
                   & Bodies.To_Array)),
         Output_Directory);

      if not User then
         Write_Conversions;
      end if;
   end Generate;

end Idle.Targets.Kernel.Client;
