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
      Body_Context   : Context_List;
      Uses_Words     : Boolean := False;
      --  True if the body converts values to Rose.Words types.
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
      procedure Add_Handler (Member : Idle.Hierarchy.Member);
      procedure Add_Handler_Type (Member : Idle.Hierarchy.Member);
      procedure Add_Publish;
      procedure Add_Remove_Instance;

      function Server_Type_Of (Info : Types.Type_Info) return String
      is (if Info.Category in Types.Interface_Value
          then Capability_Name
          else To_String (Info.Ada_Name));
      --  The Ada type of Info in the server, where an interface is a cap.

      procedure Use_Type (Info : Types.Type_Info);
      --  Add what the server needs to name values of type Info.

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
               Info        : constant Types.Type_Info :=
                 Types.Resolve (Member.Owner, Parameter.Of_Type);
               Object_Name : constant String := Name (Parameter);
               Object_Type : constant not null Syn.Node_Access :=
                 F.New_Name (Server_Type_Of (Info));
               Argument    : Syn.Node_Access := F.New_Name (Object_Name);
            begin
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
                     if Parameter.Mode = Idle.Syntax.Out_Mode then
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
                                    ("Rose.Invocation.Max_Capabilities"))])));
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
                     Declarations.Append
                       (Buffer_Overlay (Object_Name, String_Type));
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
               Arguments.Append (Argument);
               if Info.Category = String_Value
                 and then Parameter.Mode /= Idle.Syntax.In_Mode
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
            Arguments.Append (F.New_Name ("Result"));
            Arguments.Append (F.New_Name ("Last"));
         end if;

         if Subprogram.Is_Function and then not Returns_String then
            Declarations.Append
              (F.New_Object
                 ("Result",
                  F.New_Name (Server_Type_Of (Result)),
                  F.New_Call (Local (Subprogram), Arguments.To_Array),
                  Is_Constant => True));
         else
            Statements.Append
              (Call (Local (Subprogram), Arguments.To_Array));
         end if;

         Statements.Append
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
                        Statements.Append
                          (Types.Send
                             (F, Info, "Parameters", Name (Parameter)));
                     when Capability_Value | Interface_Value =>
                        Statements.Append
                          (Call (System_Calls & "Send_Cap",
                                 [Parameters, F.New_Name (Name (Parameter))]));
                     when String_Value =>
                        Statements.Append
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
                  Statements.Append
                    (Types.Send (F, Result, "Parameters", "Result"));
               when Capability_Value | Interface_Value =>
                  Statements.Append
                    (Call (System_Calls & "Send_Cap",
                           [Parameters, F.New_Name ("Result")]));
               when String_Value =>
                  Statements.Append
                    (Call (System_Calls & "Send_Word",
                           [Parameters, F.New_Name ("Last")]));
               when Capability_Array_Value | Storage_Value | Unknown =>
                  raise Program_Error;
            end case;
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
                   Register (Interface_Name (For_Interface),
                             Get_Interface (For_Interface))]
           & [for Subprogram of Subprograms =>
                Register (Endpoint_Name (Subprogram), Handle (Subprogram))]
           & Extra.To_Array;
      end Registrations;

      --------------
      -- Use_Type --
      --------------

      procedure Use_Type (Info : Types.Type_Info) is
         Unit : constant String :=
           (if Info.Category in Types.Interface_Value
            then "Rose.Capabilities"
            else To_String (Info.Unit));
      begin
         if Unit /= "" and then Unit /= "Rose.Interfaces." & Ada_Name then
            Spec_Context.Add (Unit);
         end if;
         if Types.Uses_Words_Unit (Info) then
            Uses_Words := True;
         end if;
      end Use_Type;

   begin
      Spec_Context.Add ("Rose.Capabilities");
      Spec_Context.Add ("Rose.Server");

      Objects.Append
        (F.New_Object
           ("Server_Instance", F.New_Name ("Rose.Server.Server_Instance")));

      for Member of Idle.Hierarchy.Members (Item) loop
         Add_Handler_Type (Member);
      end loop;
      Add_Attach;
      Add_Publish;
      Add_Getters;
      Add_Remove_Instance;

      for For_Interface of Interfaces loop
         Add_Get_Interface (For_Interface);
      end loop;
      for Member of Idle.Hierarchy.Members (Item) loop
         Add_Handler (Member);
      end loop;

      Body_Context.Add ("Rose.Invocation");
      Body_Context.Add ("Rose.System_Calls");
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
                   Objects.To_Array
                   & Handler_Specs.To_Array
                   & Bodies.To_Array)),
         Output_Directory);
   end Generate;

end Idle.Targets.Kernel.Server;
