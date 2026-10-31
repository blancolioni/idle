with Ada.Strings.Unbounded;

with Syn;
with Syn.Factory;
with Syn.Units;

with Idle.Endpoints;
with Idle.Hierarchy;
with Idle.Names;
with Idle.Targets.Kernel.Support;
with Idle.Targets.Kernel.Types;

package body Idle.Targets.Kernel.Server is

   use Ada.Strings.Unbounded;
   use type Idle.Hierarchy.Interface_Vectors.Vector;
   use Idle.Targets.Kernel.Support;
   use type Syn.Node_Access;
   use type Syn.Node_Array;

   System_Calls : constant String := "Rose.System_Calls.";
   Server       : constant String := "Rose.Server.";

   --------------
   -- Generate --
   --------------

   procedure Generate
     (Item             : Idle.Syntax.Interface_Declaration;
      Output_Directory : String;
      Target           : Idle.Targets.Target)
   is
      User           : constant Boolean := Target = User_Target;
      --  The user target, whose server dispatches each call to an object
      --  that the program attached, instead of to a handler.
      Ada_Name       : constant String :=
        Idle.Names.Ada_Name (To_String (Item.Name));
      Package_Name   : constant String :=
        "Rose.Interfaces." & Ada_Name & ".Server";
      Interface_Id   : constant String := Interface_Name (Item);
      Subprograms    : constant Idle.Syntax.Subprogram_Vectors.Vector :=
        Support.Subprograms (Item);
      Interfaces     : constant Idle.Hierarchy.Interface_Vectors.Vector :=
        Idle.Hierarchy.Ancestors (Item) & Item;
      --  The server handles the interface id of each ancestor as well as
      --  its own.

      F              : Syn.Factory.Factory;
      Spec_Context   : Context_List;
      Body_Context   : Context_List;
      Compares_Words : Boolean := False;
      --  True if the body compares a data word with zero.
      Uses_Words     : Boolean := False;
      --  True if the body converts values to Rose.Words types.
      Public_Part    : Node_List;
      Objects        : Node_List;
      Result_Types   : Context_List;
      --  For the user target, the interfaces of the results that have a
      --  subtype for their class-wide object type (see Result_Subtype).
      Handler_Specs  : Node_List;
      Bodies         : Body_List;

      function Call
        (Name      : String;
         Arguments : Syn.Node_Array := Syn.No_Nodes)
         return not null Syn.Node_Access;
      --  A procedure call statement.

      function Cap_Object (Subprogram : Idle.Syntax.Subprogram) return String
      is (Name (Subprogram) & "_Cap");
      --  The object that holds the cap of the endpoint of Subprogram, if
      --  the server is not instanced.

      function Get_Interface
        (For_Interface : Idle.Syntax.Interface_Declaration)
         return String
      is ("Handle_Get_" & Idle.Names.Ada_Name (To_String (For_Interface.Name))
          & "_Interface");

      function Id (For_Interface : Idle.Syntax.Interface_Declaration)
        return String
      is (if User
          then "Rose.Interfaces." & Ada_Name & "."
               & Interface_Name (For_Interface)
          else Interface_Name (For_Interface));
      --  The interface id of For_Interface. The user target's server
      --  package declares a type with the name of the interface id of
      --  Item, so it names the ids by their package.

      Interface_Type : constant String := Ada_Name & "_Interface";
      Resource       : constant Boolean := Is_Resource (Item);
      --  True if Item's objects are released (Rose ADR 0010).
      --  For the user target, the interface that a served object
      --  implements.
      --  The procedure that replies to an invocation of the interface id
      --  of For_Interface.

      function Handle (Subprogram : Idle.Syntax.Subprogram) return String
      is ("Handle_" & Name (Subprogram));
      --  The procedure that decodes an invocation of Subprogram.

      function Handler_Type (Subprogram : Idle.Syntax.Subprogram)
        return String
      is (Name (Subprogram) & "_Handler");
      --  The access type of the server's handler for Subprogram.

      function Local (Subprogram : Idle.Syntax.Subprogram) return String
      is ("Local_" & Name (Subprogram));
      --  The object that holds the server's handler for Subprogram.

      procedure Add_Attach;
      procedure Add_Attached_Objects;
      procedure Add_Release_Support;
      procedure Add_Get_Interface
        (For_Interface : Idle.Syntax.Interface_Declaration);
      procedure Add_Getters;
      procedure Add_Handler (Member : Idle.Hierarchy.Member);
      procedure Add_Handler_Type (Member : Idle.Hierarchy.Member);
      procedure Add_Publish;
      procedure Add_Remove_Instance;

      function Server_Type_Of (Info : Types.Type_Info) return String
      is (if Info.Category in Types.Interface_Value
          then Capability_Name
          else To_String (Info.Ada_Name));
      --  The Ada type of Info in the server, where an interface is a cap.

      function Uses_Text (Member : Idle.Hierarchy.Member) return Boolean
      is ((Member.Subprogram.Is_Function
           and then Types.Resolve (Member.Owner, Member.Subprogram.Result)
                      .Category in Types.String_Value)
          or else
            (for some Parameter of Member.Subprogram.Parameters =>
               Types.Resolve (Member.Owner, Parameter.Of_Type).Category
                 in Types.String_Value
               and then Parameter.Mode not in Idle.Syntax.In_Mode));
      --  For the user target: True if the handler of Member copies a
      --  string or text to the buffer with Rose.Texts.Copy.

      function Result_Subtype (Info : Types.Type_Info) return String;
      --  For the user target: a subtype, declared in the body, for the
      --  class-wide object type of the interface result Info, whose name
      --  can be too long for a line with the local that holds it.

      procedure Use_Type
        (Info      : Types.Type_Info;
         Is_Result : Boolean := False);
      --  Add what the server needs to name values of type Info, or the
      --  function result if Is_Result. For the user target, an interface
      --  argument is a client of the interface, and an interface result
      --  is an object of it.

      function Handler_Parameters return Syn.Node_Array;
      --  A parameter for the handler of each subprogram.

      function Keep_Handlers return Syn.Node_Array;
      --  Statements that save each handler in its Local object.

      function Register (Endpoint, Handler : String)
        return not null Syn.Node_Access;
      --  Register Handler for invocations of Endpoint.

      function Registrations return Syn.Node_Array;
      --  Register the handler of each interface id, and of each
      --  subprogram.

      ----------------
      -- Add_Attach --
      ----------------

      --  Create_Server and Attach_Interface do the same: register the
      --  handlers and, unless the server is instanced, create a single
      --  endpoint for each subprogram, and an anonymous endpoint for each
      --  interface id. An instanced server creates an endpoint for each
      --  identifier when it is first asked for the interface (see
      --  Add_Get_Interface).

      procedure Add_Attach is

         function Parameters return Syn.Node_Array
         is ([F.New_Parameter
                ("Server_Context",
                 F.New_Name ("Rose.Server.Server_Context"),
                 Syn.In_Out_Mode)]
             & Handler_Parameters
             & [F.New_Parameter
                  ("Instanced", F.New_Name ("Boolean"),
                   Default => F.New_Name ("False"))]);

         Create_Server : constant not null Syn.Node_Access :=
           F.New_Procedure ("Create_Server", Parameters);
         Attach        : constant not null Syn.Node_Access :=
           F.New_Procedure ("Attach_Interface", Parameters);

      begin
         Public_Part.Append (Create_Server);
         Public_Part.Append (Attach);

         Bodies.Add
           ("Attach_Interface",
            F.New_Subprogram_Body
              (Specification => Attach,
               Statements    =>
                 Keep_Handlers
                 & [for For_Interface of Interfaces =>
                      Register (Id (For_Interface),
                                Get_Interface (For_Interface))]
                 & [F.New_If
                      (Condition =>
                         F.New_Unary ("not", F.New_Name ("Instanced")),
                       Then_Part =>
                         [for Subprogram of Subprograms =>
                            F.New_Assignment
                              (F.New_Name (Cap_Object (Subprogram)),
                               F.New_Call
                                 (Server & "Create_Endpoint",
                                  [F.New_Name (Endpoint_Name (Subprogram))]))]
                         & [for For_Interface of Interfaces =>
                              Call (Server & "Create_Anonymous_Endpoint",
                                    [F.New_Name
                                       (Interface_Name (For_Interface))])])]
                 & [for Subprogram of Subprograms =>
                      Register (Endpoint_Name (Subprogram),
                                Handle (Subprogram))]));

         Bodies.Add
           ("Create_Server",
            F.New_Subprogram_Body
              (Specification => Create_Server,
               Statements    =>
                 [Call ("Attach_Interface",
                        [F.New_Name ("Server_Context")]
                        & [for Subprogram of Subprograms =>
                             F.New_Name (Name (Subprogram))]
                        & [F.New_Name ("Instanced")])]));
      end Add_Attach;

      --------------------------
      -- Add_Attached_Objects --
      --------------------------

      --  For the user target: the interface of a served object, and a
      --  table of the attached objects. An object's identifier is its
      --  position in the table, so the first is 0, which is the
      --  identifier of a cap that is not instanced, and of a restore
      --  notice. Each object has an interface cap for its identifier.

      procedure Add_Attached_Objects is
         Object_Parameter : constant not null Syn.Node_Access :=
           F.New_Parameter
             ("Object", F.New_Name ("not null access " & Interface_Type
                                    & "'Class"));
         Context_Parameter : constant not null Syn.Node_Access :=
           F.New_Parameter
             ("Server_Context", F.New_Name ("Rose.Server.Server_Context"),
              Syn.In_Out_Mode);
         Attach : constant not null Syn.Node_Access :=
           F.New_Procedure ("Attach", [Context_Parameter, Object_Parameter]);
         Publish : constant not null Syn.Node_Access :=
           F.New_Procedure ("Publish", [Context_Parameter, Object_Parameter]);
         Interface_Cap : constant not null Syn.Node_Access :=
           F.New_Function
             ("Interface_Cap", F.New_Name (Capability_Name),
              [Object_Parameter]);
         Find : constant not null Syn.Node_Access :=
           F.New_Function
             ("Find", F.New_Name ("Object_Access"),
              [F.New_Parameter
                 ("Identifier",
                  F.New_Name ("Rose.Objects.Capability_Identifier"))]);
         Count : constant not null Syn.Node_Access :=
           F.New_Name ("Attached_Count");
         Cap_Of : constant not null Syn.Node_Access :=
           F.New_Function
             ("Cap_Of", F.New_Name (Capability_Name),
              [F.New_Parameter
                 ("Object", F.New_Name (Interface_Type & "'Class")),
               F.New_Parameter
                 ("Interface_Id", F.New_Name ("Rose.Objects.Endpoint_Id"),
                  Default => F.New_Name (Id (Item)))]);
         Ancestors : constant Idle.Hierarchy.Interface_Vectors.Vector :=
           Idle.Hierarchy.Ancestors (Item);

         function Is_Ancestor (Last : Positive)
           return not null Syn.Node_Access
         is (if Last = 1
             then F.New_Binary
                    (F.New_Name ("Interface_Id"), "=",
                     F.New_Name (Id (Ancestors (Last))))
             else F.New_Binary
                    (Is_Ancestor (Last - 1), "or else",
                     F.New_Binary
                       (F.New_Name ("Interface_Id"), "=",
                        F.New_Name (Id (Ancestors (Last))))));
         --  Interface_Id is that of one of the ancestors up to Last, as
         --  "A or else B or else C", which needs no parentheses.

         Instance : constant Syn.Node_Array :=
           [F.New_Name ("Server_Instance"),
            F.New_Name ("Interface_Id"),
            F.New_Name ("Identifier")];
         Ancestor_Cap : constant Syn.Node_Array :=
           [Call (Server & "Set_Instance_Cap",
                  Instance
                  & [F.New_Call
                       (Server & "Create_Endpoint",
                        [F.New_Name ("Interface_Id"),
                         F.New_Name ("Identifier")])])];
         --  The ancestor's interface cap for the object, made the first
         --  time, as the handler of the object's interface cap makes it.
      begin
         Public_Part.Append
           (F.New_Interface_Type
              (Interface_Type,
               [F.New_Name (Object_Type (To_String (Item.Name)))],
               Is_Limited => True));
         Public_Part.Append (Attach);
         Public_Part.Append (Publish);
         Public_Part.Append (Interface_Cap);
         Public_Part.Append (Cap_Of);

         Objects.Append
           (F.New_Access_Type
              ("Object_Access", F.New_Name (Interface_Type & "'Class"),
               Is_All => True));
         Objects.Append
           (F.New_Record_Type
              ("Attached_Object",
               [F.New_Component ("Object", F.New_Name ("Object_Access")),
                F.New_Component
                  ("Cap", F.New_Name (Capability_Name),
                   F.New_Name ("Rose.Capabilities.Null_Capability"))]
               & (if Resource
                  then [F.New_Component
                          ("Retired", F.New_Name ("Boolean"),
                           F.New_Name ("False"))]
                  else Syn.No_Nodes)));
         Objects.Append
           (F.New_Object
              ("Max_Attached", Initial_Value => F.New_Integer_Literal (16),
               Is_Constant => True));
         Objects.Append
           (F.New_Array_Type
              ("Attached_Array",
               F.New_Binary
                 (F.New_Integer_Literal (0), "..",
                  F.New_Binary
                    (F.New_Name ("Max_Attached"), "-",
                     F.New_Integer_Literal (1))),
               F.New_Name ("Attached_Object")));
         Objects.Append
           (F.New_Object ("Attached", F.New_Name ("Attached_Array")));
         Objects.Append
           (F.New_Object
              ("Attached_Count", F.New_Name ("Natural"),
               F.New_Integer_Literal (0)));
         Objects.Append
           (F.New_Object
              ("Registered", F.New_Name ("Boolean"), F.New_Name ("False")));

         Handler_Specs.Append (Find);

         --  An object is attached at the next slot, or for a resource at
         --  the first free one, since a released object frees its slot.

         declare
            Slot     : constant String :=
              (if Resource then "Slot" else "Attached_Count");
            Next     : constant not null Syn.Node_Access :=
              F.New_Assignment
                (Count, F.New_Binary (Count, "+", F.New_Integer_Literal (1)));
         begin
            Bodies.Add
              ("Attach",
               F.New_Subprogram_Body
                 (Specification => Attach,
                  Declarations  =>
                    (if Resource
                     then [F.New_Object
                             ("Slot", F.New_Name ("Natural"),
                              F.New_Name ("Free_Slot"),
                              Is_Constant => True)]
                     else Syn.No_Nodes),
                  Statements    =>
                    [F.New_If
                       (Condition =>
                          F.New_Unary ("not", F.New_Name ("Registered")),
                        Then_Part =>
                          Registrations
                          & [F.New_Assignment
                               (F.New_Name ("Registered"),
                                F.New_Name ("True"))]),
                     F.New_If
                       (Condition =>
                          F.New_Binary
                            (F.New_Name (Slot), "=",
                             F.New_Name ("Max_Attached")),
                        Then_Part =>
                          [F.New_Raise
                             (F.New_Name ("Constraint_Error"),
                              F.New_String_Literal
                                (Ada_Name & ".Server: too many objects"))]),
                     F.New_Assignment
                       (F.New_Name ("Attached (" & Slot & ").Object"),
                        F.New_Call
                          ("Object_Access", [F.New_Name ("Object")])),
                     F.New_Assignment
                       (F.New_Name ("Attached (" & Slot & ").Cap"),
                        F.New_Call
                          (Server & "Create_Endpoint",
                           [F.New_Name (Id (Item)),
                            F.New_Call
                              ("Rose.Objects.Capability_Identifier",
                               [F.New_Name (Slot)])])),
                     (if Resource
                      then F.New_If
                             (Condition =>
                                F.New_Binary
                                  (F.New_Name ("Slot"), "=", Count),
                              Then_Part => [Next])
                      else Next)]));
         end;

         if Resource then
            Add_Release_Support;
         end if;

         --  Cap_Of gives an object's cap for the interface, or for one of
         --  its ancestors, for the cap functions of a served object. It
         --  finds the object by its address, since the object is passed
         --  by reference.

         Bodies.Add
           ("Cap_Of",
            F.New_Subprogram_Body
              (Specification => Cap_Of,
               Declarations  =>
                 [F.New_Use ("System.Address", Use_Type => True),
                  F.New_Use ("Rose.Objects.Capability_Identifier",
                             Use_Type => True),
                  F.New_Use ("Rose.Objects.Endpoint_Id", Use_Type => True),
                  F.New_Object
                      ("Identifier",
                       F.New_Name ("Rose.Objects.Capability_Identifier"),
                       F.New_Integer_Literal (0))],
               Statements    =>
                 [F.New_For_Of_Loop
                    ("Item", F.New_Name ("Attached"),
                     [F.New_If
                        (Condition =>
                           F.New_Binary
                             (F.New_Binary
                                (F.New_Name ("Item.Object"), "/=",
                                 F.New_Name ("null")),
                              "and then",
                              F.New_Binary
                                (F.New_Attribute
                                   (F.New_Name ("Item.Object.all"),
                                    "Address"),
                                 "=",
                                 F.New_Attribute
                                   (F.New_Name ("Object"), "Address"))),
                         Then_Part =>
                           [F.New_If
                              (Condition =>
                                 F.New_Binary
                                   (F.New_Name ("Interface_Id"), "=",
                                    F.New_Name (Id (Item))),
                               Then_Part =>
                                 [F.New_Return (F.New_Name ("Item.Cap"))],
                               Else_Part =>
                                 (if Ancestors.Is_Empty
                                  then Syn.No_Nodes
                                  else
                                    [F.New_If
                                       (Condition =>
                                          Is_Ancestor (Ancestors.Last_Index),
                                        Then_Part =>
                                          [F.New_If
                                             (Condition =>
                                                F.New_Unary
                                                  ("not",
                                                   F.New_Call
                                                     (Server & "Has_Instance",
                                                      Instance)),
                                              Then_Part => Ancestor_Cap),
                                           F.New_Return
                                             (F.New_Call
                                                (Server & "Get_Instance_Cap",
                                                 Instance))])]))]),
                      F.New_Assignment
                        (F.New_Name ("Identifier"),
                         F.New_Binary
                           (F.New_Name ("Identifier"), "+",
                            F.New_Integer_Literal (1)))]),
                  F.New_Raise
                    (F.New_Name ("Rose.Interfaces.Objects.Not_Served"),
                     F.New_String_Literal (Package_Name & ".Cap_Of"))]));

         Bodies.Add
           ("Find",
            F.New_Subprogram_Body
              (Specification => Find,
               Declarations  =>
                 [F.New_Use ("Rose.Objects.Capability_Identifier",
                             Use_Type => True)],
               Statements    =>
                 [F.New_If
                    (Condition =>
                       F.New_Binary
                         (F.New_Name ("Identifier"), ">=",
                          F.New_Call
                            ("Rose.Objects.Capability_Identifier", [Count])),
                     Then_Part => [F.New_Return (F.New_Name ("null"))]),
                  F.New_Return
                    (F.New_Name ("Attached (Natural (Identifier)).Object"))]));

         Bodies.Add
           ("Interface_Cap",
            F.New_Subprogram_Body
              (Specification => Interface_Cap,
               Statements    =>
                 [F.New_For_Of_Loop
                    ("Item", F.New_Name ("Attached"),
                     [F.New_If
                        (Condition =>
                           F.New_Binary
                             (F.New_Name ("Item.Object"), "=",
                              F.New_Call
                                ("Object_Access", [F.New_Name ("Object")])),
                         Then_Part =>
                           [F.New_Return (F.New_Name ("Item.Cap"))])]),
                  F.New_Return
                    (F.New_Name ("Rose.Capabilities.Null_Capability"))]));

         Bodies.Add
           ("Publish",
            F.New_Subprogram_Body
              (Specification => Publish,
               Statements    =>
                 [Call ("Attach",
                        [F.New_Name ("Server_Context"),
                         F.New_Name ("Object")]),
                  Call (Server & "Publish_Interface",
                        [F.New_Call
                           ("Interface_Cap", [F.New_Name ("Object")])])]));
      end Add_Attached_Objects;

      -----------------------
      -- Add_Get_Interface --
      -----------------------

      --  Invoking the interface cap of For_Interface returns a cap for each
      --  of its subprograms, including those it inherits. They are sent in
      --  the order of Support.Subprograms (For_Interface), which is the
      --  order of the index constants in its interface package. An
      --  instanced server has one endpoint for each subprogram and
      --  identifier, which it creates the first time it is needed.
      --
      --  An invocation with a word N > 0 asks instead for the interface
      --  cap of the Nth of Idle.Hierarchy.Ancestors (For_Interface). That
      --  cap gives only the ancestor's subprograms, so a client narrowed
      --  to the ancestor (see the client's conversions) can be sent to
      --  another process.

      procedure Add_Get_Interface
        (For_Interface : Idle.Syntax.Interface_Declaration)
      is
         Sent : constant Idle.Syntax.Subprogram_Vectors.Vector :=
           Support.Subprograms (For_Interface);

         Specification : constant not null Syn.Node_Access :=
           F.New_Procedure
             (Get_Interface (For_Interface),
              [F.New_Parameter
                 ("Parameters", F.New_Name (Record_Name), Syn.In_Out_Mode)]);

         Ancestors : constant Idle.Hierarchy.Interface_Vectors.Vector :=
           Idle.Hierarchy.Ancestors (For_Interface);

         function Send_Ancestor_Cap
           (Ancestor : Idle.Syntax.Interface_Declaration)
            return Syn.Node_Array;
         --  Send the interface cap of Ancestor, for the same identifier.

         -----------------------
         -- Send_Ancestor_Cap --
         -----------------------

         function Send_Ancestor_Cap
           (Ancestor : Idle.Syntax.Interface_Declaration)
            return Syn.Node_Array
         is
            Instance : constant Syn.Node_Array :=
              [F.New_Name ("Server_Instance"),
               F.New_Name (Interface_Name (Ancestor)),
               F.New_Name ("Identifier")];
         begin
            return
              [F.New_If
                 (Condition =>
                    F.New_Unary
                      ("not", F.New_Call (Server & "Has_Instance", Instance)),
                  Then_Part =>
                    [Call (Server & "Set_Instance_Cap",
                           Instance
                           & [F.New_Call
                                (Server & "Create_Endpoint",
                                 [F.New_Name (Interface_Name (Ancestor)),
                                  F.New_Name ("Identifier")])])]),
               Call (System_Calls & "Send_Cap",
                     [F.New_Name ("Parameters"),
                      F.New_Call (Server & "Get_Instance_Cap", Instance)])];
         end Send_Ancestor_Cap;

         function Send_Cap
           (Subprogram : Idle.Syntax.Subprogram)
            return Syn.Node_Array;
         --  Send the cap of the endpoint of Subprogram.

         --------------
         -- Send_Cap --
         --------------

         function Send_Cap
           (Subprogram : Idle.Syntax.Subprogram)
            return Syn.Node_Array
         is
            Instance : constant Syn.Node_Array :=
              [F.New_Name ("Server_Instance"),
               F.New_Name (Endpoint_Name (Subprogram)),
               F.New_Name ("Identifier")];
            Instance_Cap : constant Syn.Node_Array :=
              [F.New_If
                 (Condition =>
                    F.New_Unary
                      ("not",
                       F.New_Call (Server & "Has_Instance", Instance)),
                  Then_Part =>
                    [Call (Server & "Set_Instance_Cap",
                           Instance
                           & [F.New_Call
                                (Server & "Create_Endpoint",
                                 [F.New_Name (Endpoint_Name (Subprogram)),
                                  F.New_Name ("Identifier")])])]),
               F.New_Assignment
                 (F.New_Name ("Cap"),
                  F.New_Call (Server & "Get_Instance_Cap", Instance))];
            --  The cap for the identifier, made the first time.
            Send : constant not null Syn.Node_Access :=
              Call (System_Calls & "Send_Cap",
                    [F.New_Name ("Parameters"), F.New_Name ("Cap")]);
         begin
            if User then
               return Instance_Cap & [Send];
            else
               return
                 [F.New_If
                    (Condition =>
                       F.New_Binary
                         (F.New_Name (Cap_Object (Subprogram)), "=",
                          F.New_Name ("Rose.Capabilities.Null_Capability")),
                     Then_Part => Instance_Cap,
                     Else_Part =>
                       [F.New_Assignment
                          (F.New_Name ("Cap"),
                           F.New_Name (Cap_Object (Subprogram)))]),
                  Send];
            end if;
         end Send_Cap;

         Declarations : Node_List;
         Statements   : Node_List;
         Own_Caps     : Node_List;

      begin
         Handler_Specs.Append (Specification);

         if not Sent.Is_Empty or else not Ancestors.Is_Empty then
            if not User then
               --  To compare with the caps that are not instanced.
               Declarations.Append
                 (F.New_Use
                    ("Rose.Capabilities.Capability", Use_Type => True));
            end if;
            Declarations.Append
              (F.New_Object ("Cap", F.New_Name (Capability_Name)));
            Declarations.Append
              (F.New_Object
                 ("Identifier",
                  F.New_Name ("Rose.Objects.Capability_Identifier"),
                  F.New_Name ("Parameters.Identifier"),
                  Is_Constant => True));
         end if;

         if not Ancestors.Is_Empty then
            Declarations.Append
              (F.New_Object
                 ("Ancestor", F.New_Name ("Natural"),
                  F.New_Integer_Literal (0)));
            --  The word is read before Initialize_Reply clears it.
            Statements.Append
              (F.New_If
                 (Condition =>
                    F.New_Call
                      ("Parameters.Control.Flags",
                       [F.New_Name ("Rose.Invocation.Send_Words")]),
                  Then_Part =>
                    [F.New_Assignment
                       (F.New_Name ("Ancestor"),
                        F.New_Call
                          ("Natural",
                           [F.New_Call
                              ("Parameters.Data",
                               [F.New_Integer_Literal (0)])]))]));
         end if;

         Statements.Append
           (Call (System_Calls & "Initialize_Reply",
                  [F.New_Name ("Parameters"),
                   F.New_Name ("Parameters.Reply_Cap")]));
         for Subprogram of Sent loop
            for Statement of Send_Cap (Subprogram) loop
               Own_Caps.Append (Statement);
            end loop;
         end loop;

         if Ancestors.Is_Empty then
            for Statement of Own_Caps.To_Array loop
               Statements.Append (Statement);
            end loop;
         else
            --  if Ancestor = 0 then the caps of the subprograms, elsif
            --  Ancestor = N then the interface cap of the Nth ancestor,
            --  else an error.

            declare
               function Choose (Index : Positive) return Syn.Node_Array;
               --  Send the cap of the ancestor numbered Ancestor, trying
               --  the ancestors from Index on.

               ------------
               -- Choose --
               ------------

               function Choose (Index : Positive) return Syn.Node_Array is
               begin
                  if Index > Natural (Ancestors.Length) then
                     return
                       [Call (System_Calls & "Send_Error",
                              [F.New_Name ("Parameters"),
                               F.New_Name
                                 ("Rose.Invocation.Invalid_Operation")])];
                  else
                     return
                       [F.New_If
                          (Condition =>
                             F.New_Binary
                               (F.New_Name ("Ancestor"), "=",
                                F.New_Integer_Literal
                                  (Long_Long_Long_Integer (Index))),
                           Then_Part =>
                             Send_Ancestor_Cap (Ancestors (Index)),
                           Else_Part => Choose (Index + 1))];
                  end if;
               end Choose;

            begin
               Statements.Append
                 (F.New_If
                    (Condition =>
                       F.New_Binary
                         (F.New_Name ("Ancestor"), "=",
                          F.New_Integer_Literal (0)),
                     Then_Part => Own_Caps.To_Array,
                     Else_Part => Choose (1)));
            end;
         end if;

         Bodies.Add
           (Get_Interface (For_Interface),
            F.New_Subprogram_Body
              (Specification => Specification,
               Declarations  => Declarations.To_Array,
               Statements    => Statements.To_Array));
      end Add_Get_Interface;

      -----------------
      -- Add_Getters --
      -----------------

      procedure Add_Getters is
      begin
         for Subprogram of Subprograms loop
            declare
               Getter : constant String := "Get_" & Cap_Object (Subprogram);
               Specification : constant not null Syn.Node_Access :=
                 F.New_Function (Getter, F.New_Name (Capability_Name));
            begin
               Public_Part.Append (Specification);
               Bodies.Add
                 (Getter,
                  F.New_Expression_Function
                    (Specification, F.New_Name (Cap_Object (Subprogram))));
            end;
         end loop;
      end Add_Getters;

      -----------------
      -- Add_Handler --
      -----------------

      --  Words arrive in data words and caps in cap slots, each in the
      --  order of the parameters; a string or array is the invocation
      --  buffer, used in place, and a cap array is every remaining cap.
      --  The reply holds the out values, in order, then the function
      --  result; a cap or interface result is a cap, and a string result
      --  is written to the buffer and its length sent as a data word.

      procedure Add_Handler (Member : Idle.Hierarchy.Member) is
         use all type Types.Category;
         use type Idle.Syntax.Parameter_Mode;

         Subprogram     : Idle.Syntax.Subprogram renames Member.Subprogram;
         Result         : constant Types.Type_Info :=
           (if Subprogram.Is_Function
            then Types.Resolve (Member.Owner, Subprogram.Result)
            else (others => <>));
         Returns_String : constant Boolean :=
           Subprogram.Is_Function and then Result.Category = String_Value;

         Specification : constant not null Syn.Node_Access :=
           F.New_Procedure
             (Handle (Subprogram),
              [F.New_Parameter
                 ("Parameters", F.New_Name (Record_Name), Syn.In_Out_Mode)]);

         function Parameters return not null Syn.Node_Access
         is (F.New_Name ("Parameters"));

         function Literal (Value : Natural) return not null Syn.Node_Access
         is (F.New_Integer_Literal (Long_Long_Long_Integer (Value)));

         function Buffer_Overlay
           (Object_Name : String;
            Object_Type : not null Syn.Node_Access)
            return not null Syn.Node_Access
         is (F.New_Object
               (Object_Name, Object_Type,
                Aspects =>
                  [F.New_Aspect ("Import"),
                   F.New_Aspect
                     ("Address", F.New_Name ("Parameters.Buffer_Address"))]));
         --  An object of type Object_Type at the invocation buffer.

         function String_Type return not null Syn.Node_Access
         is (F.New_Call
               ("String",
                [F.New_Binary
                   (Literal (1), "..",
                    F.New_Call
                      ("Natural",
                       [F.New_Name ("Parameters.Buffer_Length")]))]));

         function Storage_Type return not null Syn.Node_Access
         is (F.New_Call
               ("System.Storage_Elements.Storage_Array",
                [F.New_Binary
                   (Literal (1), "..",
                    F.New_Name ("Parameters.Buffer_Length"))]));

         Packed : constant Boolean :=
           Types.Packs_Buffers (Member.Owner, Subprogram);
         --  The in strings and arrays are items in the buffer (idle#58).

         Next_Item : Positive := 1;

         procedure Add_Item_Overlay
           (Object_Name : String;
            Is_String   : Boolean);
         --  Declare Object_Name, a string or a storage array, at the next
         --  item in the invocation buffer.

         Declarations : Node_List;
         Arguments    : Node_List;
         Statements   : Node_List;
         Reply        : Node_List;
         Result_Call  : Syn.Node_Access;
         --  For the user target, the call of a function whose result is
         --  an interface, which initializes Result in a block that holds
         --  the reply.
         Next_Word    : Natural := 0;
         Next_Cap     : Natural := 0;

         ----------------------
         -- Add_Item_Overlay --
         ----------------------

         procedure Add_Item_Overlay
           (Object_Name : String;
            Is_String   : Boolean)
         is
            Item_Name : constant String := Object_Name & "_Item";
            Length    : constant not null Syn.Node_Access :=
              F.New_Name (Item_Name & ".Length");
         begin
            Declarations.Append
              (F.New_Object
                 (Item_Name, F.New_Name (System_Calls & "Buffer_Item"),
                  F.New_Call
                    (System_Calls & "Get_Buffer_Item",
                     [Parameters, Literal (Next_Item)]),
                  Is_Constant => True));
            Declarations.Append
              (F.New_Object
                 (Object_Name,
                  (if Is_String
                   then F.New_Call
                          ("String",
                           [F.New_Binary
                              (Literal (1), "..",
                               F.New_Call ("Natural", [Length]))])
                   else F.New_Call
                          ("System.Storage_Elements.Storage_Array",
                           [F.New_Binary (Literal (1), "..", Length)])),
                  Aspects =>
                    [F.New_Aspect ("Import"),
                     F.New_Aspect
                       ("Address", F.New_Name (Item_Name & ".Address"))]));
            Next_Item := Next_Item + 1;
         end Add_Item_Overlay;

      begin
         Handler_Specs.Append (Specification);
         if User then
            Declarations.Append
              (F.New_Object
                 ("Object", F.New_Name ("Object_Access"),
                  F.New_Call ("Find", [F.New_Name ("Parameters.Identifier")]),
                  Is_Constant => True));
         else
            Arguments.Append (F.New_Name ("Parameters.Identifier"));
         end if;

         for Parameter of Subprogram.Parameters loop
            declare
               Info        : constant Types.Type_Info :=
                 Types.Resolve (Member.Owner, Parameter.Of_Type);
               Object_Name : constant String := Name (Parameter);
               Object_Type : constant not null Syn.Node_Access :=
                 F.New_Name (Server_Type_Of (Info));
               Argument    : Syn.Node_Access := F.New_Name (Object_Name);
            begin
               if Packed and then Parameter.Mode = Idle.Syntax.In_Mode
                 and then Types.Is_Buffer (Info)
               then
                  Add_Item_Overlay
                    (Object_Name, Info.Category = String_Value);
               else
                  case Info.Category is
                     when Word_Value | Double_Word_Value =>
                        if Parameter.Mode = Idle.Syntax.Out_Mode then
                           Declarations.Append
                             (F.New_Object (Object_Name, Object_Type));
                        else
                           Declarations.Append
                             (F.New_Object
                                (Object_Name, Object_Type,
                                 Types.Decode
                                   (F, Info, "Parameters", Next_Word),
                                 Is_Constant =>
                                   Parameter.Mode = Idle.Syntax.In_Mode));
                           Next_Word := Next_Word + Types.Words (Info);
                        end if;
                     when Capability_Value | Interface_Value =>
                        if User and then Info.Category = Interface_Value then
                           --  A client of the interface, which the object can
                           --  call, or for an out interface opens.
                           Declarations.Append
                             (F.New_Object
                                (Object_Name,
                                 F.New_Name (To_String (Info.Ada_Name)),
                                 (if Parameter.Mode = Idle.Syntax.Out_Mode
                                  then null
                                  else F.New_Call
                                         (To_String (Info.Unit) & ".From_Cap",
                                          [F.New_Call
                                             ("Parameters.Caps",
                                              [Literal (Next_Cap)])]))));
                           if Parameter.Mode /= Idle.Syntax.Out_Mode then
                              Next_Cap := Next_Cap + 1;
                           end if;
                        elsif Parameter.Mode = Idle.Syntax.Out_Mode then
                           Declarations.Append
                             (F.New_Object
                                (Object_Name, Object_Type,
                                 F.New_Name
                                   ("Rose.Capabilities.Null_Capability")));
                        else
                           Declarations.Append
                             (F.New_Object
                                (Object_Name, Object_Type,
                                 F.New_Call
                                   ("Parameters.Caps", [Literal (Next_Cap)]),
                                 Is_Constant =>
                                   Parameter.Mode = Idle.Syntax.In_Mode));
                           Next_Cap := Next_Cap + 1;
                        end if;
                     when Capability_Array_Value =>
                        Declarations.Append
                          (F.New_Object
                             (Object_Name,
                              F.New_Call
                                (Capability_Name & "_Array",
                                 [F.New_Binary
                                    (Literal (1), "..",
                                     F.New_Name
                                       ("Rose.Invocation"
                                        & ".Max_Capabilities"))])));
                        Declarations.Append
                          (F.New_Object
                             (Object_Name & "_Count", F.New_Name ("Natural"),
                              F.New_Call
                                (System_Calls & "Copy_Received_Caps",
                                 [Parameters, Literal (Next_Cap),
                                  F.New_Name (Object_Name)]),
                              Is_Constant => True));
                        Argument :=
                          F.New_Call
                            (Object_Name,
                             [F.New_Binary
                                (Literal (1), "..",
                                 F.New_Name (Object_Name & "_Count"))]);
                     when String_Value =>
                        if User and then Parameter.Mode /= Idle.Syntax.In_Mode
                        then
                           --  A text, from the buffer for an in out string,
                           --  which is copied to the buffer for the reply.
                           Declarations.Append
                             (Buffer_Overlay (Object_Name & "_Buffer",
                                              String_Type));
                           Declarations.Append
                             (F.New_Object
                                (Object_Name, F.New_Name (Text_Name),
                                 (if Parameter.Mode = Idle.Syntax.Out_Mode
                                  then null
                                  else F.New_Call
                                         ("Rose.Texts.To_Text",
                                          [F.New_Name
                                             (Object_Name & "_Buffer")]))));
                        else
                           Declarations.Append
                             (Buffer_Overlay (Object_Name, String_Type));
                        end if;
                        if Parameter.Mode /= Idle.Syntax.In_Mode then
                           Declarations.Append
                             (F.New_Object
                                (Object_Name & "_Last", F.New_Name ("Natural"),
                                 Literal (0)));
                        end if;
                     when Storage_Value =>
                        Declarations.Append
                          (Buffer_Overlay (Object_Name, Storage_Type));
                     when Unknown =>
                        raise Program_Error;
                  end case;
               end if;
               Arguments.Append (Argument);
               if Info.Category = String_Value
                 and then Parameter.Mode /= Idle.Syntax.In_Mode
                 and then not User
               then
                  Arguments.Append (F.New_Name (Object_Name & "_Last"));
               end if;
            end;
         end loop;

         if Returns_String then
            Declarations.Append
              (F.New_Object
                 ("Last", F.New_Name ("Natural"), Literal (0)));
            Declarations.Append (Buffer_Overlay ("Result", String_Type));
            if not User then
               Arguments.Append (F.New_Name ("Result"));
               Arguments.Append (F.New_Name ("Last"));
            end if;
         end if;

         if User then
            --  An identifier with no object is an error, as in
            --  Rose.Server for an endpoint with no handler.

            Statements.Append
              (F.New_If
                 (Condition =>
                    F.New_Binary
                      (F.New_Name ("Object"), "=", F.New_Name ("null")),
                  Then_Part =>
                    [Call (System_Calls & "Initialize_Reply",
                           [Parameters,
                            F.New_Name ("Parameters.Reply_Cap")]),
                     Call (System_Calls & "Send_Error",
                           [Parameters,
                            F.New_Name ("Rose.Invocation.Invalid_Operation")]),
                     F.New_Return]));

            declare
               Callee : constant String := "Object." & Name (Subprogram);
               Value  : constant not null Syn.Node_Access :=
                 (if Arguments.To_Array'Length = 0
                  then F.New_Name (Callee)
                  else F.New_Call (Callee, Arguments.To_Array));
            begin
               if Subprogram.Is_Function
                 and then Result.Category = Interface_Value
               then
                  Result_Call := Value;
               elsif Returns_String then
                  --  The string is copied to the buffer, as much as fits.
                  Statements.Append
                    (Call ("Rose.Texts.Copy",
                           [Value, F.New_Name ("Result"),
                            F.New_Name ("Last")]));
               elsif Subprogram.Is_Function then
                  Declarations.Append
                    (F.New_Object
                       ("Result", F.New_Name (Server_Type_Of (Result))));
                  Statements.Append
                    (F.New_Assignment (F.New_Name ("Result"), Value));
               else
                  Statements.Append (F.New_Call_Statement (Value));
                  if Is_Release (Member) then
                     --  The object is gone: free its slot (Rose ADR 0010).
                     Statements.Append
                       (Call ("Detach",
                              [F.New_Name ("Parameters.Identifier")]));
                  end if;
               end if;
            end;
         elsif Subprogram.Is_Function and then not Returns_String then
            Declarations.Append
              (F.New_Object
                 ("Result",
                  F.New_Name (Server_Type_Of (Result)),
                  F.New_Call (Local (Subprogram), Arguments.To_Array),
                  Is_Constant => True));
         else
            Statements.Append
              (Call (Local (Subprogram), Arguments.To_Array));
            if Is_Release (Member) then
               --  The object is gone: delete its caps (Rose ADR 0010).
               Statements.Append
                 (Call (Server & "Remove_Instance",
                        [F.New_Name ("Server_Instance"),
                         F.New_Name ("Parameters.Identifier")]));
            end if;
         end if;

         Reply.Append
           (Call (System_Calls & "Initialize_Reply",
                  [Parameters, F.New_Name ("Parameters.Reply_Cap")]));

         for Parameter of Subprogram.Parameters loop
            if Parameter.Mode /= Idle.Syntax.In_Mode then
               declare
                  Info : constant Types.Type_Info :=
                    Types.Resolve (Member.Owner, Parameter.Of_Type);
               begin
                  case Info.Category is
                     when Word_Value | Double_Word_Value =>
                        Reply.Append
                          (Types.Send
                             (F, Info, "Parameters", Name (Parameter)));
                     when Capability_Value | Interface_Value =>
                        Reply.Append
                          (Call (System_Calls & "Send_Cap",
                                 [Parameters,
                                  F.New_Name
                                    (Name (Parameter)
                                     & (if User
                                          and then Info.Category
                                                   = Interface_Value
                                        then "." & Types.Cap_Function (Info)
                                        else ""))]));
                     when String_Value =>
                        if User then
                           Reply.Append
                             (Call ("Rose.Texts.Copy",
                                    [F.New_Name (Name (Parameter)),
                                     F.New_Name (Name (Parameter) & "_Buffer"),
                                     F.New_Name
                                       (Name (Parameter) & "_Last")]));
                        end if;
                        Reply.Append
                          (Call (System_Calls & "Send_Word",
                                 [Parameters,
                                  F.New_Name (Name (Parameter) & "_Last")]));
                     when Storage_Value =>
                        null;
                     when Capability_Array_Value | Unknown =>
                        raise Program_Error;
                  end case;
               end;
            end if;
         end loop;

         if Subprogram.Is_Function then
            case Result.Category is
               when Word_Value | Double_Word_Value =>
                  Reply.Append
                    (Types.Send (F, Result, "Parameters", "Result"));
               when Capability_Value | Interface_Value =>
                  Reply.Append
                    (Call (System_Calls & "Send_Cap",
                           [Parameters,
                            F.New_Name
                              ("Result"
                               & (if User
                                    and then Result.Category = Interface_Value
                                  then "." & Types.Cap_Function (Result)
                                  else ""))]));
               when String_Value =>
                  Reply.Append
                    (Call (System_Calls & "Send_Word",
                           [Parameters, F.New_Name ("Last")]));
               when Capability_Array_Value | Storage_Value | Unknown =>
                  raise Program_Error;
            end case;
         end if;

         if Result_Call = null then
            for Statement of Reply.To_Array loop
               Statements.Append (Statement);
            end loop;
         else
            Statements.Append
              (F.New_Block
                 (Declarations =>
                    [F.New_Object
                       ("Result", F.New_Name (Result_Subtype (Result)),
                        Result_Call)],
                  Statements   => Reply.To_Array));
         end if;

         if User then
            --  An exception that the object's operation raises, or that
            --  comes from reading the arguments, is an error reply. A
            --  block's handlers don't cover its own declarations, which
            --  read the arguments, so the handler is on an outer block
            --  around the one that holds them (#73). The kernel target is
            --  for programs that can't propagate exceptions, so it has no
            --  handler.

            Bodies.Add
              (Handle (Subprogram),
               F.New_Subprogram_Body
                 (Specification => Specification,
                  Statements    =>
                    [F.New_Block
                       (Statements =>
                          [F.New_Block
                             (Declarations => Declarations.To_Array,
                              Statements   => Statements.To_Array)],
                        Handlers     =>
                          [F.New_Handler
                             ([Call (System_Calls & "Initialize_Reply",
                                     [Parameters,
                                      F.New_Name ("Parameters.Reply_Cap")]),
                               Call (System_Calls & "Send_Error",
                                     [Parameters,
                                      F.New_Name
                                        ("Rose.Invocation.Exception_Raised")])
                              ])])]));
         else
            Bodies.Add
              (Handle (Subprogram),
               F.New_Subprogram_Body
                 (Specification => Specification,
                  Declarations  => Declarations.To_Array,
                  Statements    => Statements.To_Array));
         end if;
      end Add_Handler;

      ----------------------
      -- Add_Handler_Type --
      ----------------------

      procedure Add_Handler_Type (Member : Idle.Hierarchy.Member) is
         Subprogram     : Idle.Syntax.Subprogram renames Member.Subprogram;
         Result         : constant Types.Type_Info :=
           (if Subprogram.Is_Function
            then Types.Resolve (Member.Owner, Subprogram.Result)
            else (others => <>));
         Returns_String : constant Boolean :=
           Subprogram.Is_Function
           and then Result.Category in Types.String_Value;

         function Mode
           (Parameter : Idle.Syntax.Parameter)
            return Syn.Parameter_Mode
         is (case Parameter.Mode is
                when Idle.Syntax.In_Mode     => Syn.In_Mode,
                when Idle.Syntax.Out_Mode    => Syn.Out_Mode,
                when Idle.Syntax.In_Out_Mode => Syn.In_Out_Mode);

         Parameters : Node_List;
      begin
         Parameters.Append
           (F.New_Parameter
              ("Id", F.New_Name ("Rose.Objects.Capability_Identifier")));
         for Parameter of Subprogram.Parameters loop
            declare
               Info : constant Types.Type_Info :=
                 Types.Resolve (Member.Owner, Parameter.Of_Type);
            begin
               Use_Type (Info);
               Parameters.Append
                 (F.New_Parameter
                    (Name (Parameter), F.New_Name (Server_Type_Of (Info)),
                     Mode (Parameter)));
               if Info.Category in Types.String_Value
                 and then Parameter.Mode not in Idle.Syntax.In_Mode
               then
                  Parameters.Append
                    (F.New_Parameter
                       (Name (Parameter) & "_Last", F.New_Name ("Natural"),
                        Syn.Out_Mode));
               end if;
            end;
         end loop;

         if Returns_String then
            Parameters.Append
              (F.New_Parameter
                 ("Result", F.New_Name ("String"), Syn.Out_Mode));
            Parameters.Append
              (F.New_Parameter
                 ("Last", F.New_Name ("Natural"), Syn.Out_Mode));
         end if;

         if Subprogram.Is_Function and then not Returns_String then
            Use_Type (Result);
            Public_Part.Append
              (F.New_Access_Function_Type
                 (Handler_Type (Subprogram),
                  F.New_Name (Server_Type_Of (Result)),
                  Parameters.To_Array));
         else
            Public_Part.Append
              (F.New_Access_Procedure_Type
                 (Handler_Type (Subprogram), Parameters.To_Array));
         end if;

         Objects.Append
           (F.New_Object
              (Local (Subprogram), F.New_Name (Handler_Type (Subprogram))));
         Objects.Append
           (F.New_Object
              (Cap_Object (Subprogram), F.New_Name (Capability_Name),
               F.New_Name ("Rose.Capabilities.Null_Capability")));
      end Add_Handler_Type;

      -----------------
      -- Add_Publish --
      -----------------

      --  Create the endpoints and register the handlers, then publish the
      --  interface cap.

      procedure Add_Publish is
         Specification : constant not null Syn.Node_Access :=
           F.New_Procedure
             ("Publish_Interface",
              [F.New_Parameter
                 ("Server_Context",
                  F.New_Name ("Rose.Server.Server_Context"),
                  Syn.In_Out_Mode)]
              & Handler_Parameters);
      begin
         Public_Part.Append (Specification);
         Objects.Append
           (F.New_Object
              ("Published_Cap", F.New_Name (Capability_Name),
               F.New_Name ("Rose.Capabilities.Null_Capability")));

         Bodies.Add
           ("Publish_Interface",
            F.New_Subprogram_Body
              (Specification => Specification,
               Statements    =>
                 Keep_Handlers
                 & [for Subprogram of Subprograms =>
                      F.New_Assignment
                        (F.New_Name (Cap_Object (Subprogram)),
                         F.New_Call
                           (Server & "Create_Endpoint",
                            [F.New_Name (Endpoint_Name (Subprogram))]))]
                 & [F.New_Assignment
                      (F.New_Name ("Published_Cap"),
                       F.New_Call (Server & "Create_Endpoint",
                                   [F.New_Name (Interface_Id)]))]
                 & Registrations
                 & [Call (Server & "Publish_Interface",
                          [F.New_Name ("Published_Cap")])]));
      end Add_Publish;

      -------------------------
      -- Add_Release_Support --
      -------------------------

      --  For the user target, when Item is a resource (Rose ADR 0010):
      --  Free_Slot finds a slot for Attach, and Detach frees the slot of
      --  an object that has been released. Detach rescinds the object's
      --  caps, so that no copy of them reaches whatever is attached in
      --  the slot next. Without the rescind cap, it retires the slot
      --  instead, so that it is not used again. It deletes and rescinds
      --  through Rose.System_Calls, which does nothing if the program
      --  has no cap to do it with.

      procedure Add_Release_Support is
         Free_Slot : constant not null Syn.Node_Access :=
           F.New_Function ("Free_Slot", F.New_Name ("Natural"));
         Detach    : constant not null Syn.Node_Access :=
           F.New_Procedure
             ("Detach",
              [F.New_Parameter
                 ("Identifier",
                  F.New_Name ("Rose.Objects.Capability_Identifier"))]);
         Slot     : constant String := "Attached (Natural (Identifier))";
         Rescind  : constant not null Syn.Node_Access :=
           F.New_Name (System_Calls & "Rescind_Cap_Capability");
         Null_Cap : constant not null Syn.Node_Access :=
           F.New_Name ("Rose.Capabilities.Null_Capability");

         function Rescind_Instance (Endpoint : String)
           return not null Syn.Node_Access
         is (F.New_If
               (Condition =>
                  F.New_Call
                    (Server & "Has_Instance",
                     [F.New_Name ("Server_Instance"),
                      F.New_Name (Endpoint),
                      F.New_Name ("Identifier")]),
                Then_Part =>
                  [Call (System_Calls & "Rescind_Cap",
                         [F.New_Call
                            (Server & "Get_Instance_Cap",
                             [F.New_Name ("Server_Instance"),
                              F.New_Name (Endpoint),
                              F.New_Name ("Identifier")])])]));
         --  Rescind the cap of Endpoint for the object, if one was made.

         Rescinds : Node_List;

      begin
         Rescinds.Append
           (Call (System_Calls & "Rescind_Cap", [F.New_Name (Slot & ".Cap")]));
         for Subprogram of Subprograms loop
            Rescinds.Append (Rescind_Instance (Endpoint_Name (Subprogram)));
         end loop;
         for For_Interface of Interfaces loop
            Rescinds.Append (Rescind_Instance (Id (For_Interface)));
         end loop;

         Handler_Specs.Append (Free_Slot);
         Handler_Specs.Append (Detach);

         Bodies.Add
           ("Free_Slot",
            F.New_Subprogram_Body
              (Specification => Free_Slot,
               Declarations  =>
                 [F.New_Object
                    ("Index", F.New_Name ("Natural"),
                     F.New_Integer_Literal (0))],
               Statements    =>
                 [F.New_For_Of_Loop
                    ("Item", F.New_Name ("Attached"),
                     [F.New_If
                        (Condition =>
                           F.New_Binary
                             (F.New_Binary
                                (F.New_Binary
                                   (F.New_Name ("Index"), "<",
                                    F.New_Name ("Attached_Count")),
                                 "and then",
                                 F.New_Binary
                                   (F.New_Name ("Item.Object"), "=",
                                    F.New_Name ("null"))),
                              "and then",
                              F.New_Unary
                                ("not", F.New_Name ("Item.Retired"))),
                         Then_Part => [F.New_Return (F.New_Name ("Index"))]),
                      F.New_Assignment
                        (F.New_Name ("Index"),
                         F.New_Binary
                           (F.New_Name ("Index"), "+",
                            F.New_Integer_Literal (1)))]),
                  F.New_Return (F.New_Name ("Attached_Count"))]));

         Bodies.Add
           ("Detach",
            F.New_Subprogram_Body
              (Specification => Detach,
               Declarations  =>
                 [F.New_Use ("Rose.Capabilities.Capability",
                             Use_Type => True)],
               Statements    =>
                 [F.New_If
                    (Condition => F.New_Binary (Rescind, "=", Null_Cap),
                     Then_Part =>
                       [F.New_Assignment
                          (F.New_Name (Slot & ".Retired"),
                           F.New_Name ("True"))],
                     Else_Part => Rescinds.To_Array),
                  Call (Server & "Remove_Instance",
                        [F.New_Name ("Server_Instance"),
                         F.New_Name ("Identifier")]),
                  Call (System_Calls & "Delete_Cap",
                        [F.New_Name (Slot & ".Cap")]),
                  F.New_Assignment
                    (F.New_Name (Slot & ".Object"), F.New_Name ("null")),
                  F.New_Assignment (F.New_Name (Slot & ".Cap"), Null_Cap)]));
      end Add_Release_Support;

      ------------------------
      -- Add_Remove_Instance --
      ------------------------

      --  An instanced server makes caps for each object that a client
      --  asks for; Remove_Instance deletes them, when the object is gone.

      procedure Add_Remove_Instance is
         Specification : constant not null Syn.Node_Access :=
           F.New_Procedure
             ("Remove_Instance",
              [F.New_Parameter
                 ("Identifier",
                  F.New_Name ("Rose.Objects.Capability_Identifier"))]);
      begin
         Spec_Context.Add ("Rose.Objects");
         Public_Part.Append (Specification);
         Bodies.Add
           ("Remove_Instance",
            F.New_Subprogram_Body
              (Specification => Specification,
               Statements    =>
                 [Call (Server & "Remove_Instance",
                        [F.New_Name ("Server_Instance"),
                         F.New_Name ("Identifier")])]));
      end Add_Remove_Instance;

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

      ------------------------
      -- Handler_Parameters --
      ------------------------

      function Handler_Parameters return Syn.Node_Array is
      begin
         return [for Subprogram of Subprograms =>
                   F.New_Parameter
                     (Name (Subprogram),
                      F.New_Name (Handler_Type (Subprogram)))];
      end Handler_Parameters;

      -------------------
      -- Keep_Handlers --
      -------------------

      function Keep_Handlers return Syn.Node_Array is
      begin
         return [for Subprogram of Subprograms =>
                   F.New_Assignment
                     (F.New_Name (Local (Subprogram)),
                      F.New_Name (Name (Subprogram)))];
      end Keep_Handlers;

      --------------
      -- Register --
      --------------

      function Register (Endpoint, Handler : String)
        return not null Syn.Node_Access
      is
      begin
         return Call (Server & "Register_Handler",
                      [F.New_Name ("Server_Context"),
                       F.New_Name (Endpoint),
                       F.New_Attribute (F.New_Name (Handler), "Access")]);
      end Register;

      -------------------
      -- Registrations --
      -------------------

      function Registrations return Syn.Node_Array is
         Extra : Node_List;
      begin
         --  A subprogram that more than one interface declares has the id
         --  of its first declaration, and is handled under the ids of the
         --  others too.

         for Member of Idle.Hierarchy.Members (Item) loop
            for Other of Member.Also_Declared_By loop
               for Declared of Other.Subprograms loop
                  if Idle.Names.Key (To_String (Declared.Name))
                    = Idle.Names.Key (To_String (Member.Subprogram.Name))
                  then
                     Extra.Append
                       (Register
                          (Idle.Endpoints.Image
                             (Idle.Endpoints.Subprogram_Id (Other, Declared)),
                           Handle (Member.Subprogram)));
                  end if;
               end loop;
            end loop;
         end loop;

         return [for For_Interface of Interfaces =>
                   Register (Id (For_Interface),
                             Get_Interface (For_Interface))]
           & [for Subprogram of Subprograms =>
                Register (Endpoint_Name (Subprogram), Handle (Subprogram))]
           & Extra.To_Array;
      end Registrations;

      --------------------
      -- Result_Subtype --
      --------------------

      function Result_Subtype (Info : Types.Type_Info) return String is
         Name : constant String :=
           To_String (Info.Interface_Name) & "_Object_Class";
      begin
         if not Result_Types.Contains (Name) then
            Result_Types.Add (Name);
            Objects.Append
              (F.New_Raw
                 ("subtype " & Name & " is" & ASCII.LF
                  & "  " & Types.Object_Class (Info) & ";"));
         end if;
         return Name;
      end Result_Subtype;

      --------------
      -- Use_Type --
      --------------

      procedure Use_Type
        (Info      : Types.Type_Info;
         Is_Result : Boolean := False)
      is
         Unit : constant String :=
           (if Info.Category not in Types.Interface_Value
            then To_String (Info.Unit)
            elsif not User then "Rose.Capabilities"
            elsif Is_Result then Types.Object_Unit (Info)
            else To_String (Info.Unit));
      begin
         if Unit /= "" and then Unit /= "Rose.Interfaces." & Ada_Name then
            if not User then
               Spec_Context.Add (Unit);
            elsif not Spec_Context.Contains (Unit) then
               Body_Context.Add (Unit);
            end if;
         end if;
         if Types.Uses_Words_Unit (Info) then
            Uses_Words := True;
         end if;
         if Types.Compares_Words (Info) then
            Compares_Words := True;
         end if;
      end Use_Type;

   begin
      Spec_Context.Add ("Rose.Capabilities");
      Spec_Context.Add ("Rose.Server");
      if User then
         --  For Cap_Of.
         Spec_Context.Add ("Rose.Objects");
      end if;

      Objects.Append
        (F.New_Object
           ("Server_Instance", F.New_Name ("Rose.Server.Server_Instance")));

      if User then
         Add_Attached_Objects;
         for Member of Idle.Hierarchy.Members (Item) loop
            for Parameter of Member.Subprogram.Parameters loop
               Use_Type (Types.Resolve (Member.Owner, Parameter.Of_Type));
            end loop;
            if Member.Subprogram.Is_Function then
               Use_Type
                 (Types.Resolve (Member.Owner, Member.Subprogram.Result),
                  Is_Result => True);
            end if;
            if Uses_Text (Member) then
               Body_Context.Add ("Rose.Texts");
            end if;
         end loop;
      else
         for Member of Idle.Hierarchy.Members (Item) loop
            Add_Handler_Type (Member);
         end loop;
         Add_Attach;
         Add_Publish;
         Add_Getters;
         Add_Remove_Instance;
      end if;

      for For_Interface of Interfaces loop
         Add_Get_Interface (For_Interface);
      end loop;
      for Member of Idle.Hierarchy.Members (Item) loop
         Add_Handler (Member);
      end loop;

      Body_Context.Add ("Rose.Invocation");
      Body_Context.Add ("Rose.System_Calls");
      if User then
         --  For Cap_Of.
         Body_Context.Add ("Rose.Interfaces.Objects");
         Body_Context.Add ("System");
      end if;
      if Uses_Words and then not Spec_Context.Contains ("Rose.Words") then
         Body_Context.Add ("Rose.Words");
      end if;

      Syn.Units.Write
        (F.New_Compilation_Unit
           (Context => Spec_Context.To_Array (F),
            Item    =>
              F.New_Package
                (Name        => Package_Name,
                 Public_Part => Public_Part.To_Array)),
         Output_Directory);

      Syn.Units.Write
        (F.New_Compilation_Unit
           (Context => Body_Context.To_Array (F),
            Item    =>
              F.New_Package_Body
                (Name         => Package_Name,
                 Declarations =>
                   (if Compares_Words
                    then [F.New_Use ("Rose.Words.Word_32", Use_Type => True)]
                    else Syn.No_Nodes)
                   & Objects.To_Array
                   & Handler_Specs.To_Array
                   & Bodies.To_Array)),
         Output_Directory);
   end Generate;

end Idle.Targets.Kernel.Server;
