with Ada.Strings.Unbounded;

with Syn;
with Syn.Factory;
with Syn.Units;

with Idle.Names;
with Idle.Targets.Kernel.Support;

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

      F            : Syn.Factory.Factory;
      Spec_Context : Context_List;
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

      function Client_Package
        (Subprogram : Idle.Syntax.Subprogram)
         return String;
      --  The client package of the interface that the function Subprogram
      --  returns, or "" if it returns this interface.

      function Client_Parameter
        (Mode : Syn.Parameter_Mode := Syn.In_Mode)
         return not null Syn.Node_Access;
      --  The client object as the first parameter of a subprogram.

      procedure Add_Close;
      procedure Add_Error_Functions;
      procedure Add_Getters;
      procedure Add_Open;
      procedure Add_Open_Cap_Set;
      procedure Add_Subprogram (Subprogram : Idle.Syntax.Subprogram);

      function Result_Type
        (Subprogram : Idle.Syntax.Subprogram)
         return String;
      --  The Ada type returned by the function Subprogram.

      ---------------
      -- Add_Close --
      ---------------

      procedure Add_Close is
         Specification : constant not null Syn.Node_Access :=
           F.New_Procedure ("Close", [Client_Parameter (Syn.In_Out_Mode)]);
      begin
         Public_Part.Append (Specification);
         Bodies.Add
           ("Close",
            F.New_Subprogram_Body
              (Specification => Specification,
               Statements    =>
                 [F.New_Assignment
                    (F.New_Name ("Client.Is_Open"), F.New_Name ("False"))]
                 & [for Subprogram of Item.Subprograms =>
                      Call (System_Calls & "Delete_Cap",
                            [F.New_Name ("Client." & Name (Subprogram))])]
                 & [Call (System_Calls & "Delete_Cap",
                          [F.New_Name ("Client.Interface_Cap")])]));
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
         for Subprogram of Item.Subprograms loop
            Add_Getter (Cap_Getter (Name (Subprogram)), Name (Subprogram));
         end loop;
      end Add_Getters;

      --------------
      -- Add_Open --
      --------------

      --  Invoking the interface cap returns a cap for each subprogram,
      --  in the order they are declared.

      procedure Add_Open is
         Specification : constant not null Syn.Node_Access :=
           F.New_Procedure
             ("Open",
              [Client_Parameter (Syn.Out_Mode),
               F.New_Parameter ("Interface_Cap",
                                F.New_Name (Capability_Name))]);
         Caps : constant Syn.Node_Array :=
           [for Index in 1 .. Natural (Item.Subprograms.Length) =>
              F.New_Assignment
                (F.New_Name ("Client." & Name (Item.Subprograms (Index))),
                 F.New_Call
                   ("Params.Caps",
                    [F.New_Integer_Literal
                       (Long_Long_Long_Integer (Index - 1))]))];
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
                        [F.New_Name ("Params"),
                         F.New_Integer_Literal
                           (Long_Long_Long_Integer
                              (Item.Subprograms.Length))]),
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
              & [for Subprogram of Item.Subprograms =>
                   F.New_Parameter
                     (Name (Subprogram), F.New_Name (Capability_Name))]);
      begin
         Public_Part.Append (Specification);
         Bodies.Add
           ("Open_Cap_Set",
            F.New_Subprogram_Body
              (Specification => Specification,
               Statements    =>
                 [for Subprogram of Item.Subprograms =>
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
      --  order of the parameters. A function's result is the first data
      --  word or cap of the reply; an interface result is a cap, which is
      --  opened as a client of that interface.

      procedure Add_Subprogram (Subprogram : Idle.Syntax.Subprogram) is
         Subprogram_Name : constant String := Name (Subprogram);

         Parameters : constant Syn.Node_Array :=
           [Client_Parameter]
           & [for Parameter of Subprogram.Parameters =>
                F.New_Parameter
                  (Name (Parameter),
                   F.New_Name (Ada_Type (Parameter.Of_Type)))];

         Specification : constant not null Syn.Node_Access :=
           (if Subprogram.Is_Function
            then F.New_Function
                   (Subprogram_Name,
                    F.New_Name (Result_Type (Subprogram)),
                    Parameters)
            else F.New_Procedure (Subprogram_Name, Parameters));

         Send : constant Syn.Node_Array :=
           [for Parameter of Subprogram.Parameters =>
              Call (System_Calls
                    & (if Kind (Parameter.Of_Type) = Word_Type
                       then "Send_Word" else "Send_Cap"),
                    [F.New_Name ("Params"),
                     F.New_Name (Name (Parameter))])];

         function Receive return Syn.Node_Array;
         --  The call that sets up the reply, if there is a result.

         function Result return Syn.Node_Array;
         --  The statements that return the result, if any.

         -------------
         -- Receive --
         -------------

         function Receive return Syn.Node_Array is
         begin
            if not Subprogram.Is_Function then
               return Syn.No_Nodes;
            end if;
            return
              [Call (System_Calls
                     & (if Kind (Subprogram.Result) = Word_Type
                        then "Receive_Words" else "Receive_Caps"),
                     [F.New_Name ("Params"), F.New_Integer_Literal (1)])];
         end Receive;

         ------------
         -- Result --
         ------------

         function Result return Syn.Node_Array is
            First_Cap : constant not null Syn.Node_Access :=
              F.New_Call ("Params.Caps", [F.New_Integer_Literal (0)]);
         begin
            if not Subprogram.Is_Function then
               return Syn.No_Nodes;
            end if;

            case Kind (Subprogram.Result) is
               when Word_Type =>
                  return
                    [F.New_Return
                       (F.New_Call (System_Calls & "Get_Word_32",
                                    [F.New_Name ("Params"),
                                     F.New_Integer_Literal (0)]))];
               when Capability_Type =>
                  return [F.New_Return (First_Cap)];
               when Interface_Type =>
                  declare
                     Result_Package : constant String :=
                       Client_Package (Subprogram);
                  begin
                     return
                       [F.New_Block
                          (Declarations =>
                             [F.New_Object
                                ("Result",
                                 F.New_Name (Result_Type (Subprogram)))],
                           Statements   =>
                             [Call ((if Result_Package = ""
                                     then "Open"
                                     else Result_Package & ".Open"),
                                    [F.New_Name ("Result"), First_Cap]),
                              F.New_Return (F.New_Name ("Result"))])];
                  end;
               when Other_Type =>
                  raise Program_Error;
            end case;
         end Result;

      begin
         Public_Part.Append (Specification);
         Components.Append
           (F.New_Component
              (Subprogram_Name, F.New_Name (Capability_Name),
               F.New_Name ("Rose.Capabilities.Null_Capability")));
         for Parameter of Subprogram.Parameters loop
            if Kind (Parameter.Of_Type) = Word_Type then
               Spec_Context.Add ("Rose.Words");
            end if;
         end loop;
         if Subprogram.Is_Function then
            if Kind (Subprogram.Result) = Word_Type then
               Spec_Context.Add ("Rose.Words");
            elsif Kind (Subprogram.Result) = Interface_Type
              and then Client_Package (Subprogram) /= ""
            then
               Spec_Context.Add (Client_Package (Subprogram));
            end if;
         end if;

         Bodies.Add
           (Subprogram_Name,
            F.New_Subprogram_Body
              (Specification => Specification,
               Declarations  =>
                 [F.New_Object
                    ("Params", F.New_Name (Record_Name),
                     Is_Aliased => True)],
               Statements    =>
                 [Call (System_Calls & "Initialize_Send",
                        [F.New_Name ("Params"),
                         F.New_Name ("Item." & Subprogram_Name)])]
                 & Send
                 & Receive
                 & [Call (System_Calls & "Invoke_Capability",
                          [F.New_Name ("Params")]),
                    F.New_Assignment
                      (F.New_Name ("Last_Error"),
                       F.New_Name ("Rose.Invocation.OK")),
                    F.New_If
                      (Condition =>
                         F.New_Call ("Params.Control.Flags",
                                     [F.New_Name ("Rose.Invocation.Error")]),
                       Then_Part =>
                         [F.New_Assignment
                            (F.New_Name ("Last_Error"),
                             F.New_Name ("Params.Error"))])]
                 & Result));
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

      function Client_Package
        (Subprogram : Idle.Syntax.Subprogram)
         return String
      is
         Result_Name : constant String :=
           Idle.Names.Ada_Name (To_String (Subprogram.Result.Name));
      begin
         if Idle.Names.Key (Result_Name) = Idle.Names.Key (Ada_Name) then
            return "";
         else
            return "Rose.Interfaces." & Result_Name & ".Client";
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

      -----------------
      -- Result_Type --
      -----------------

      function Result_Type
        (Subprogram : Idle.Syntax.Subprogram)
         return String
      is
      begin
         case Kind (Subprogram.Result) is
            when Word_Type | Capability_Type =>
               return Ada_Type (Subprogram.Result);
            when Interface_Type =>
               if Client_Package (Subprogram) = "" then
                  return Client_Type;
               else
                  return Client_Package (Subprogram) & "."
                    & Idle.Names.Ada_Name (To_String (Subprogram.Result.Name))
                    & "_Client";
               end if;
            when Other_Type =>
               raise Program_Error;
         end case;
      end Result_Type;

   begin
      Public_Part.Append (F.New_Private_Type (Client_Type));
      Spec_Context.Add ("Rose.Capabilities");

      Add_Open_Cap_Set;
      Add_Open;
      Add_Close;
      for Subprogram of Item.Subprograms loop
         Add_Subprogram (Subprogram);
      end loop;
      Add_Getters;
      Add_Error_Functions;

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
           (Context => [F.New_With ("Rose.System_Calls")],
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
