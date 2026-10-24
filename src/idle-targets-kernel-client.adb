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
      Output_Directory : String)
   is
      Ada_Name     : constant String :=
        Idle.Names.Ada_Name (To_String (Item.Name));
      Package_Name : constant String :=
        "Rose.Interfaces." & Ada_Name & ".Client";
      Client_Type  : constant String := Ada_Name & "_Client";
      Subprograms  : constant Idle.Syntax.Subprogram_Vectors.Vector :=
        Support.Subprograms (Item);

      F            : Syn.Factory.Factory;
      Spec_Context : Context_List;
      Body_Context : Context_List;
      Uses_Words   : Boolean := False;
      --  True if the body converts values to Rose.Words types.
      Public_Part  : Node_List;
      Components   : Node_List;
      Bodies       : Body_List;

      function Call
        (Name      : String;
         Arguments : Syn.Node_Array := Syn.No_Nodes)
         return not null Syn.Node_Access;
      --  A procedure call statement.

      function Cap_Getter (Name : String) return String
      is ("Get_" & Name & "_Cap");
      --  The function that returns the cap of the subprogram Name.

      function Client_Package (Info : Types.Type_Info) return String;
      --  The client package of the interface Info, or "" if it is this
      --  interface.

      function Client_Type_Of (Info : Types.Type_Info) return String;
      --  The Ada type of Info in the client: the type itself, or for an
      --  interface its client type.

      function Client_Parameter
        (Mode : Syn.Parameter_Mode := Syn.In_Mode)
         return not null Syn.Node_Access;
      --  The client object as the first parameter of a subprogram.

      procedure Add_Close;
      procedure Add_Error_Functions;
      procedure Add_Getters;
      procedure Add_Open;
      procedure Add_Open_Cap_Set;
      procedure Add_Subprogram (Member : Idle.Hierarchy.Member);

      procedure Use_Type (Info : Types.Type_Info);
      --  Add what the client needs to name values of type Info.

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
      begin
         Statements.Append
           (F.New_Assignment
              (F.New_Name ("Client.Is_Open"), F.New_Name ("False")));
         for Subprogram of Subprograms loop
            for Statement of Delete (Name (Subprogram)) loop
               Statements.Append (Statement);
            end loop;
         end loop;
         for Statement of Delete ("Interface_Cap") loop
            Statements.Append (Statement);
         end loop;

         Public_Part.Append (Specification);
         Bodies.Add
           ("Close",
            F.New_Subprogram_Body
              (Specification => Specification,
               Declarations  =>
                 [F.New_Object
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

      -----------------
      -- Add_Getters --
      -----------------

      procedure Add_Getters is

         procedure Add_Getter (Name, Component : String);

         ----------------
         -- Add_Getter --
         ----------------

         procedure Add_Getter (Name, Component : String) is
            Specification : constant not null Syn.Node_Access :=
              F.New_Function
                (Name, F.New_Name (Capability_Name), [Client_Parameter]);
         begin
            Public_Part.Append (Specification);
            Bodies.Add
              (Name,
               F.New_Expression_Function
                 (Specification, F.New_Name ("Item." & Component)));
         end Add_Getter;

      begin
         Add_Getter ("Get_Interface_Cap", "Interface_Cap");
         for Subprogram of Subprograms loop
            Add_Getter (Cap_Getter (Name (Subprogram)), Name (Subprogram));
         end loop;
      end Add_Getters;

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
      --  then the function result; a cap or interface result is the
      --  first cap of the reply, and an interface result is opened as a
      --  client of that interface. A string result is copied from the
      --  buffer, and its length is the data word after the out values.

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

         Parameters : constant Syn.Node_Array :=
           [Client_Parameter]
           & [for Parameter of Subprogram.Parameters =>
                F.New_Parameter
                  (Name (Parameter),
                   F.New_Name (Client_Type_Of (Info (Parameter))),
                   Mode (Parameter))]
           & (if Returns_String
              then [F.New_Parameter
                      ("Result", F.New_Name ("String"), Syn.Out_Mode),
                    F.New_Parameter
                      ("Last", F.New_Name ("Natural"), Syn.Out_Mode)]
              else Syn.No_Nodes);

         Specification : constant not null Syn.Node_Access :=
           (if Subprogram.Is_Function and then not Returns_String
            then F.New_Function
                   (Subprogram_Name,
                    F.New_Name (Client_Type_Of (Result)),
                    Parameters)
            else F.New_Procedure (Subprogram_Name, Parameters));

         Statements  : Node_List;
         Reply_Words : Natural := 0;
         Index       : Natural := 0;

      begin
         Public_Part.Append (Specification);
         Components.Append
           (F.New_Component
              (Subprogram_Name, F.New_Name (Capability_Name),
               F.New_Name ("Rose.Capabilities.Null_Capability")));

         Statements.Append
           (Call (System_Calls & "Initialize_Send",
                  [Params, F.New_Name ("Item." & Subprogram_Name)]));

         for Parameter of Subprogram.Parameters loop
            declare
               Parameter_Info : constant Types.Type_Info := Info (Parameter);
               Value          : constant not null Syn.Node_Access :=
                 F.New_Name (Name (Parameter));
            begin
               Use_Type (Parameter_Info);

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
                                  F.New_Call
                                    (Qualified
                                       (Client_Package (Parameter_Info),
                                        "Get_Interface_Cap"),
                                     [Value])]));
                     when Capability_Array_Value =>
                        Statements.Append
                          (F.New_For_Of_Loop
                             ("Cap", Value,
                              [Call (System_Calls & "Send_Cap",
                                     [Params, F.New_Name ("Cap")])]));
                     when String_Value =>
                        Statements.Append
                          (Call (System_Calls & "Send_Text", [Params, Value]));
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
               elsif Types.Is_Buffer (Parameter_Info) then
                  Statements.Append
                    (Call (System_Calls & "Receive_Buffer",
                           [Params, F.New_Attribute (Value, "Length")]));
               end if;

               if Parameter.Mode /= Idle.Syntax.In_Mode then
                  Reply_Words := Reply_Words + Types.Words (Parameter_Info);
               end if;
            end;
         end loop;

         if Subprogram.Is_Function then
            Use_Type (Result);
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
            Statements.Append
              (Call (System_Calls & "Receive_Caps",
                     [Params, F.New_Integer_Literal (1)]));
         end if;
         if Returns_String then
            Statements.Append
              (Call (System_Calls & "Receive_Buffer", [Params]));
         end if;

         Statements.Append
           (Call (System_Calls & "Invoke_Capability", [Params]));
         Statements.Append
           (F.New_Assignment
              (F.New_Name ("Last_Error"), F.New_Name ("Rose.Invocation.OK")));
         Statements.Append
           (F.New_If
              (Condition =>
                 F.New_Call ("Params.Control.Flags",
                             [F.New_Name ("Rose.Invocation.Error")]),
               Then_Part =>
                 [F.New_Assignment
                    (F.New_Name ("Last_Error"),
                     F.New_Name ("Params.Error"))]));

         for Parameter of Subprogram.Parameters loop
            if Parameter.Mode /= Idle.Syntax.In_Mode then
               declare
                  Parameter_Info : constant Types.Type_Info :=
                    Info (Parameter);
                  Value          : constant not null Syn.Node_Access :=
                    F.New_Name (Name (Parameter));
               begin
                  if Types.Is_Buffer (Parameter_Info) then
                     Statements.Append
                       (Call (System_Calls & "Copy_Received_Buffer",
                              [F.New_Attribute (Value, "Length"),
                               F.New_Attribute (Value, "Address")]));
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
                          ("Params.Caps", [F.New_Integer_Literal (0)])));
               when Interface_Value =>
                  Statements.Append
                    (F.New_Block
                       (Declarations =>
                          [F.New_Object
                             ("Result",
                              F.New_Name (Client_Type_Of (Result)))],
                        Statements   =>
                          [Call (Qualified (Client_Package (Result), "Open"),
                                 [F.New_Name ("Result"),
                                  F.New_Call
                                    ("Params.Caps",
                                     [F.New_Integer_Literal (0)])]),
                           F.New_Return (F.New_Name ("Result"))]));
               when String_Value =>
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
                            F.New_Name ("Result"),
                            F.New_Name ("Last")]));
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

      --------------
      -- Use_Type --
      --------------

      procedure Use_Type (Info : Types.Type_Info) is
         Unit : constant String := To_String (Info.Unit);
      begin
         if Unit /= ""
           and then Unit /= "Rose.Interfaces." & Ada_Name
           and then Unit /= Package_Name
         then
            Spec_Context.Add (Unit);
         end if;
         if Types.Uses_Words_Unit (Info) then
            Uses_Words := True;
         end if;
      end Use_Type;

   begin
      Public_Part.Append (F.New_Private_Type (Client_Type));
      Spec_Context.Add ("Rose.Capabilities");

      Add_Open_Cap_Set;
      Add_Open;
      Add_Close;
      for Member of Idle.Hierarchy.Members (Item) loop
         Add_Subprogram (Member);
      end loop;
      Add_Getters;
      Add_Error_Functions;

      Body_Context.Add ("Rose.System_Calls");
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
                   [F.New_Record_Type
                      (Client_Type,
                       [F.New_Component
                          ("Is_Open", F.New_Name ("Boolean"),
                           F.New_Name ("False")),
                        F.New_Component
                          ("Interface_Cap", F.New_Name (Capability_Name),
                           F.New_Name ("Rose.Capabilities.Null_Capability"))]
                       & Components.To_Array)])),
         Output_Directory);

      Syn.Units.Write
        (F.New_Compilation_Unit
           (Context => Body_Context.To_Array (F),
            Item    =>
              F.New_Package_Body
                (Name         => Package_Name,
                 Declarations =>
                   [F.New_Use ("Rose.Invocation.Invocation_Error",
                               Use_Type => True),
                    F.New_Object
                      ("Last_Error",
                       F.New_Name ("Rose.Invocation.Invocation_Error"),
                       F.New_Name ("Rose.Invocation.OK"))]
                   & Bodies.To_Array)),
         Output_Directory);
   end Generate;

end Idle.Targets.Kernel.Client;
