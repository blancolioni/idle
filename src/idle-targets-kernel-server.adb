with Ada.Strings.Unbounded;

with Syn;
with Syn.Factory;
with Syn.Units;

with Idle.Hierarchy;
with Idle.Names;
with Idle.Targets.Kernel.Support;

package body Idle.Targets.Kernel.Server is

   use Ada.Strings.Unbounded;
   use type Idle.Hierarchy.Interface_Vectors.Vector;
   use Idle.Targets.Kernel.Support;
   use type Syn.Node_Array;

   System_Calls : constant String := "Rose.System_Calls.";
   Server       : constant String := "Rose.Server.";

   --------------
   -- Generate --
   --------------

   procedure Generate
     (Item             : Idle.Syntax.Interface_Declaration;
      Output_Directory : String)
   is
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
      Public_Part    : Node_List;
      Objects        : Node_List;
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
      procedure Add_Get_Interface
        (For_Interface : Idle.Syntax.Interface_Declaration);
      procedure Add_Getters;
      procedure Add_Handler (Subprogram : Idle.Syntax.Subprogram);
      procedure Add_Handler_Type (Subprogram : Idle.Syntax.Subprogram);
      procedure Add_Publish;

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
                      Register (Interface_Name (For_Interface),
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

      -----------------------
      -- Add_Get_Interface --
      -----------------------

      --  Invoking the interface cap of For_Interface returns a cap for each
      --  of its subprograms, including those it inherits. They are sent in
      --  the order of Support.Subprograms (For_Interface), which is the
      --  order of the index constants in its interface package. An
      --  instanced server has one endpoint for each subprogram and
      --  identifier, which it creates the first time it is needed.

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
         begin
            return
              [F.New_If
                 (Condition =>
                    F.New_Binary
                      (F.New_Name (Cap_Object (Subprogram)), "=",
                       F.New_Name ("Rose.Capabilities.Null_Capability")),
                  Then_Part =>
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
                                       [F.New_Name
                                          (Endpoint_Name (Subprogram)),
                                        F.New_Name ("Identifier")])])]),
                     F.New_Assignment
                       (F.New_Name ("Cap"),
                        F.New_Call (Server & "Get_Instance_Cap", Instance))],
                  Else_Part =>
                    [F.New_Assignment
                       (F.New_Name ("Cap"),
                        F.New_Name (Cap_Object (Subprogram)))]),
               Call (System_Calls & "Send_Cap",
                     [F.New_Name ("Parameters"), F.New_Name ("Cap")])];
         end Send_Cap;

         Declarations : Node_List;
         Statements   : Node_List;

      begin
         Handler_Specs.Append (Specification);

         if not Sent.Is_Empty then
            Declarations.Append
              (F.New_Use ("Rose.Capabilities.Capability", Use_Type => True));
            Declarations.Append
              (F.New_Object ("Cap", F.New_Name (Capability_Name)));
            Declarations.Append
              (F.New_Object
                 ("Identifier",
                  F.New_Name ("Rose.Objects.Capability_Identifier"),
                  F.New_Name ("Parameters.Identifier"),
                  Is_Constant => True));
         end if;

         Statements.Append
           (Call (System_Calls & "Initialize_Reply",
                  [F.New_Name ("Parameters"),
                   F.New_Name ("Parameters.Reply_Cap")]));
         for Subprogram of Sent loop
            for Statement of Send_Cap (Subprogram) loop
               Statements.Append (Statement);
            end loop;
         end loop;

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
      --  order of the parameters. A function's result is sent back as a
      --  data word or a cap; an interface result is a cap.

      procedure Add_Handler (Subprogram : Idle.Syntax.Subprogram) is
         Specification : constant not null Syn.Node_Access :=
           F.New_Procedure
             (Handle (Subprogram),
              [F.New_Parameter
                 ("Parameters", F.New_Name (Record_Name), Syn.In_Out_Mode)]);

         Declarations : Node_List;
         Arguments    : Node_List;
         Statements   : Node_List;
         Next_Word    : Natural := 0;
         Next_Cap     : Natural := 0;

      begin
         Handler_Specs.Append (Specification);
         Arguments.Append (F.New_Name ("Parameters.Identifier"));

         for Parameter of Subprogram.Parameters loop
            declare
               Value : Syn.Node_Access;
            begin
               if Kind (Parameter.Of_Type) = Word_Type then
                  Value :=
                    F.New_Call
                      (System_Calls & "Get_Word_32",
                       [F.New_Name ("Parameters"),
                        F.New_Integer_Literal
                          (Long_Long_Long_Integer (Next_Word))]);
                  Next_Word := Next_Word + 1;
               else
                  Value :=
                    F.New_Call
                      ("Parameters.Caps",
                       [F.New_Integer_Literal
                          (Long_Long_Long_Integer (Next_Cap))]);
                  Next_Cap := Next_Cap + 1;
               end if;

               Declarations.Append
                 (F.New_Object
                    (Name (Parameter),
                     F.New_Name (Ada_Type (Parameter.Of_Type)),
                     Value,
                     Is_Constant => True));
               Arguments.Append (F.New_Name (Name (Parameter)));
            end;
         end loop;

         if Subprogram.Is_Function then
            Declarations.Append
              (F.New_Object
                 ("Result",
                  F.New_Name
                    (if Kind (Subprogram.Result) = Word_Type
                     then Word_Name else Capability_Name),
                  F.New_Call (Local (Subprogram), Arguments.To_Array),
                  Is_Constant => True));
         else
            Statements.Append
              (Call (Local (Subprogram), Arguments.To_Array));
         end if;

         Statements.Append
           (Call (System_Calls & "Initialize_Reply",
                  [F.New_Name ("Parameters"),
                   F.New_Name ("Parameters.Reply_Cap")]));

         if Subprogram.Is_Function then
            Statements.Append
              (Call (System_Calls
                     & (if Kind (Subprogram.Result) = Word_Type
                        then "Send_Word" else "Send_Cap"),
                     [F.New_Name ("Parameters"), F.New_Name ("Result")]));
         end if;

         Bodies.Add
           (Handle (Subprogram),
            F.New_Subprogram_Body
              (Specification => Specification,
               Declarations  => Declarations.To_Array,
               Statements    => Statements.To_Array));
      end Add_Handler;

      ----------------------
      -- Add_Handler_Type --
      ----------------------

      procedure Add_Handler_Type (Subprogram : Idle.Syntax.Subprogram) is
         Parameters : constant Syn.Node_Array :=
           [F.New_Parameter
              ("Id", F.New_Name ("Rose.Objects.Capability_Identifier"))]
           & [for Parameter of Subprogram.Parameters =>
                F.New_Parameter
                  (Name (Parameter),
                   F.New_Name (Ada_Type (Parameter.Of_Type)))];
      begin
         for Parameter of Subprogram.Parameters loop
            if Kind (Parameter.Of_Type) = Word_Type then
               Spec_Context.Add ("Rose.Words");
            end if;
         end loop;

         if Subprogram.Is_Function then
            if Kind (Subprogram.Result) = Word_Type then
               Spec_Context.Add ("Rose.Words");
            end if;
            Public_Part.Append
              (F.New_Access_Function_Type
                 (Handler_Type (Subprogram),
                  F.New_Name
                    (if Kind (Subprogram.Result) = Word_Type
                     then Word_Name else Capability_Name),
                  Parameters));
         else
            Public_Part.Append
              (F.New_Access_Procedure_Type
                 (Handler_Type (Subprogram), Parameters));
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
                          [F.New_Integer_Literal (1),
                           F.New_Name ("Published_Cap")])]));
      end Add_Publish;

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
      begin
         return [for For_Interface of Interfaces =>
                   Register (Interface_Name (For_Interface),
                             Get_Interface (For_Interface))]
           & [for Subprogram of Subprograms =>
                Register (Endpoint_Name (Subprogram), Handle (Subprogram))];
      end Registrations;

   begin
      Spec_Context.Add ("Rose.Capabilities");
      Spec_Context.Add ("Rose.Server");

      Objects.Append
        (F.New_Object
           ("Server_Instance", F.New_Name ("Rose.Server.Server_Instance")));

      for Subprogram of Subprograms loop
         Add_Handler_Type (Subprogram);
      end loop;
      Add_Attach;
      Add_Publish;
      Add_Getters;

      for For_Interface of Interfaces loop
         Add_Get_Interface (For_Interface);
      end loop;
      for Subprogram of Subprograms loop
         Add_Handler (Subprogram);
      end loop;

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
           (Context =>
              [F.New_With ("Rose.Invocation"),
               F.New_With ("Rose.System_Calls")],
            Item    =>
              F.New_Package_Body
                (Name         => Package_Name,
                 Declarations =>
                   Objects.To_Array
                   & Handler_Specs.To_Array
                   & Bodies.To_Array)),
         Output_Directory);
   end Generate;

end Idle.Targets.Kernel.Server;
