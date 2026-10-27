with Ada.Strings.Unbounded;

with Syn;
with Syn.Factory;
with Syn.Units;

with Idle.Commands;
with Idle.Diagnostics;
with Idle.Endpoints;
with Idle.Hierarchy;
with Idle.Names;
with Idle.Targets.Kernel.Client;
with Idle.Targets.Kernel.Commands;
with Idle.Targets.Kernel.Server;
with Idle.Targets.Kernel.Support;
with Idle.Targets.Kernel.Types;

package body Idle.Targets.Kernel is

   use Ada.Strings.Unbounded;
   use type Syn.Node_Array;
   use Idle.Targets.Kernel.Support;

   Endpoint_Type : constant String := "Rose.Objects.Endpoint_Id";

   function Check (Item : Idle.Syntax.Interface_Declaration) return Boolean;
   --  Report anything in Item that the kernel target does not support.
   --  True if there was nothing to report.

   function Check_User
     (Item : Idle.Syntax.Interface_Declaration)
      return Boolean;
   --  Report what the user target cannot generate, beyond what Check
   --  reports: a constant or type of Item with the name of its object
   --  type, and a subprogram with the name of one of the object type's
   --  cap functions. True if there was nothing to report.

   function Constant_Reference
     (Item  : Idle.Syntax.Interface_Declaration;
      Owner : Idle.Syntax.Interface_Declaration;
      Name  : String)
      return String;
   --  How the interface package of Item names the constant Name declared
   --  by Owner: by its own name if Owner is Item, and qualified with
   --  Owner's interface package if Owner is an ancestor, since a child's
   --  package does not repeat its parents' constants.

   function Earlier
     (Left, Right : Idle.Syntax.Source_Position)
      return Boolean;
   --  True if Left comes before Right in a file.

   function Find_Constant
     (Item   : Idle.Syntax.Interface_Declaration;
      Name   : String;
      Before : Idle.Syntax.Source_Position;
      Owner  : out Idle.Syntax.Interface_Declaration;
      Found  : out Idle.Syntax.Constant_Declaration)
      return Boolean;
   --  Find the constant Name that a declaration of Item at Before can
   --  name: one declared earlier in Item, or one declared by an ancestor
   --  of Item. Owner is the interface that declares it.

   procedure Generate_Interface_Package
     (Item             : Idle.Syntax.Interface_Declaration;
      Output_Directory : String;
      Target           : Idle.Targets.Target);
   --  Write the package Rose.Interfaces.<Name>, which holds the endpoint
   --  ids of the interface and of each of its subprograms, and for the
   --  user target its object type.

   function Is_Integer_Constant
     (Owner : Idle.Syntax.Interface_Declaration;
      Item  : Idle.Syntax.Constant_Declaration)
      return Boolean;
   --  True if the value of the constant Item of Owner is an integer
   --  literal, or names a constant whose value is one.

   function Is_Name (Text : String) return Boolean
   is (Text'Length > 0 and then Text (Text'First) not in '0' .. '9');
   --  True if Text, a value as written, is a name and not a literal.

   -----------
   -- Check --
   -----------

   function Check (Item : Idle.Syntax.Interface_Declaration) return Boolean
   is
      Errors_Before : constant Natural := Idle.Diagnostics.Error_Count;
      Ancestors     : constant Idle.Hierarchy.Interface_Vectors.Vector :=
        Idle.Hierarchy.Ancestors (Item);
      Members       : constant Idle.Hierarchy.Member_Vectors.Vector :=
        Idle.Hierarchy.Members (Item);
      OK            : Boolean := True;

      procedure Check_Declarations
        (Declaration : Idle.Syntax.Interface_Declaration);
      --  Report what the kernel target does not support in the
      --  declarations of Declaration, and an interface without an id.

      procedure Check_Member (Member : Idle.Hierarchy.Member);
      --  Report what the kernel target does not support in the
      --  subprogram of Member, and a subprogram without an id.

      procedure Check_Generated_Names;
      --  Report a constant, type or enumeration literal of Item whose name
      --  is one that its interface package generates.

      procedure Error
        (File_Name : Unbounded_String;
         Position  : Idle.Syntax.Source_Position;
         Message   : String);

      ------------------------
      -- Check_Declarations --
      ------------------------

      procedure Check_Declarations
        (Declaration : Idle.Syntax.Interface_Declaration)
      is
         procedure Check_Reference
           (Text     : Unbounded_String;
            Position : Idle.Syntax.Source_Position);
         --  Report Text, a value or bound written at Position, if it is a
         --  name that does not name an integer constant visible there.

         procedure Unsupported (What : String);

         ---------------------
         -- Check_Reference --
         ---------------------

         procedure Check_Reference
           (Text     : Unbounded_String;
            Position : Idle.Syntax.Source_Position)
         is
            Name  : constant String := To_String (Text);
            Owner : Idle.Syntax.Interface_Declaration;
            Found : Idle.Syntax.Constant_Declaration;
         begin
            if Is_Name (Name) then
               if not Find_Constant (Declaration, Name, Position, Owner, Found)
               then
                  Error (Declaration.File_Name, Position,
                         "unknown constant " & Name);
               elsif not Is_Integer_Constant (Owner, Found) then
                  Error (Declaration.File_Name, Position,
                         Name & " is not an integer constant");
               end if;
            end if;
         end Check_Reference;

         -----------------
         -- Unsupported --
         -----------------

         procedure Unsupported (What : String) is
         begin
            Error (Declaration.File_Name, Declaration.Position,
                   What & " are not yet supported by the kernel target");
         end Unsupported;

         Declared : Idle.Syntax.String_Vectors.Vector;
         --  The keys of the types declared so far.

      begin
         for Declared_Constant of Declaration.Constants loop
            Check_Reference
              (Declared_Constant.Value, Declared_Constant.Position);
         end loop;

         for Declared_Type of Declaration.Types loop
            if Declared_Type.Kind in Idle.Syntax.Range_Type then
               Check_Reference (Declared_Type.Low, Declared_Type.Position);
               Check_Reference (Declared_Type.High, Declared_Type.Position);
            end if;

            if Declared_Type.Kind in Idle.Syntax.Derived_Type then
               declare
                  Parent : constant String :=
                    To_String (Declared_Type.Parent.Name);
               begin
                  if Declared_Type.Parent.Is_Interface then
                     Unsupported ("types derived from interfaces");
                  elsif Standard_Type (Parent) = ""
                    and then not Declared.Contains (Idle.Names.Key (Parent))
                  then
                     Error (Declaration.File_Name, Declared_Type.Position,
                            "unknown parent type " & Parent);
                  end if;
               end;
            end if;
            Declared.Append (Idle.Names.Key (To_String (Declared_Type.Name)));
         end loop;
      end Check_Declarations;

      ---------------------------
      -- Check_Generated_Names --
      ---------------------------

      procedure Check_Generated_Names is

         Generated    : Idle.Syntax.String_Vectors.Vector;
         --  The key of each generated name.
         Descriptions : Idle.Syntax.String_Vectors.Vector;
         --  What generates it.

         procedure Add (Name, Description : String);

         procedure Check
           (Name     : String;
            What     : String;
            Position : Idle.Syntax.Source_Position);
         --  Report Name, of the declaration What at Position, if it is a
         --  generated name.

         ---------
         -- Add --
         ---------

         procedure Add (Name, Description : String) is
         begin
            Generated.Append (Idle.Names.Key (Name));
            Descriptions.Append (Description);
         end Add;

         -----------
         -- Check --
         -----------

         procedure Check
           (Name     : String;
            What     : String;
            Position : Idle.Syntax.Source_Position)
         is
            Index : constant Natural :=
              Generated.Find_Index (Idle.Names.Key (Name));
         begin
            if Index /= 0 then
               Error (Item.File_Name, Position,
                      What & " " & Name & " has the same name as "
                      & Descriptions (Index)
                      & ", which the interface package declares");
            end if;
         end Check;

      begin
         for Declaration of Ancestors loop
            Add (Interface_Name (Declaration),
                 "the id of interface "
                 & Idle.Names.Ada_Name (To_String (Declaration.Name)));
         end loop;
         Add (Interface_Name (Item),
              "the id of interface "
              & Idle.Names.Ada_Name (To_String (Item.Name)));

         for Member of Members loop
            declare
               Subprogram : constant String :=
                 To_String (Member.Declared_In) & "."
                 & Name (Member.Subprogram);
            begin
               Add (Endpoint_Name (Member.Subprogram),
                    "the endpoint id of " & Subprogram);
               Add (Index_Name (Member.Subprogram),
                    "the cap index of " & Subprogram);
            end;
         end loop;

         Add (Count_Name, "the number of subprograms");

         for Declared_Constant of Item.Constants loop
            Check (To_String (Declared_Constant.Name), "constant",
                   Declared_Constant.Position);
         end loop;

         for Declared_Type of Item.Types loop
            Check (To_String (Declared_Type.Name), "type",
                   Declared_Type.Position);
            if Declared_Type.Kind in Idle.Syntax.Enumeration_Type then
               for Literal of Declared_Type.Literals loop
                  Check (Literal, "enumeration literal",
                         Declared_Type.Position);
               end loop;
            end if;
         end loop;
      end Check_Generated_Names;

      ------------------
      -- Check_Member --
      ------------------

      procedure Check_Member (Member : Idle.Hierarchy.Member) is
         use all type Types.Category;
         use type Idle.Syntax.Parameter_Mode;

         Subprogram     : Idle.Syntax.Subprogram renames Member.Subprogram;
         Buffers        : Natural := 0;
         Cap_Array_Seen : Boolean := False;

         function Unsupported_Text (What : String) return String
         is (What & " are not yet supported by the kernel target");

         procedure Check_Interface
           (Info      : Types.Type_Info;
            Type_Name : String;
            Position  : Idle.Syntax.Source_Position);
         --  Report Type_Name if it is an interface that does not exist.

         ---------------------
         -- Check_Interface --
         ---------------------

         procedure Check_Interface
           (Info      : Types.Type_Info;
            Type_Name : String;
            Position  : Idle.Syntax.Source_Position)
         is
            Found : Idle.Syntax.Interface_Declaration;
         begin
            if Info.Category = Interface_Value
              and then not Idle.Hierarchy.Find (Member.Owner, Type_Name, Found)
            then
               Error (Member.File_Name, Position,
                      "unknown interface " & Type_Name);
            end if;
         end Check_Interface;

      begin

         for Parameter of Subprogram.Parameters loop
            declare
               Info      : constant Types.Type_Info :=
                 Types.Resolve (Member.Owner, Parameter.Of_Type);
               Type_Name : constant String :=
                 To_String (Parameter.Of_Type.Name);
            begin
               if Info.Category = Unknown then
                  Error (Member.File_Name, Parameter.Position,
                         "unknown type " & Type_Name);
               else
                  Check_Interface (Info, Type_Name, Parameter.Position);

                  --  Only the caps that are sent are counted: out caps come
                  --  back in the reply.

                  if Cap_Array_Seen
                    and then Parameter.Mode /= Idle.Syntax.Out_Mode
                    and then Info.Category in
                      Capability_Value | Interface_Value
                      | Capability_Array_Value
                  then
                     Error (Member.File_Name, Parameter.Position,
                            "a capability array must be the last "
                            & "capability parameter");
                  end if;

                  if Info.Category = Capability_Array_Value
                    and then Parameter.Mode /= Idle.Syntax.Out_Mode
                  then
                     Cap_Array_Seen := True;
                  end if;

                  if Types.Is_Buffer (Info) then
                     Buffers := Buffers + 1;
                  end if;

                  if Parameter.Mode /= Idle.Syntax.In_Mode
                    and then Info.Category = Capability_Array_Value
                  then
                     Error (Member.File_Name, Parameter.Position,
                            Unsupported_Text
                              ("out and in out parameters of type "
                               & Type_Name));
                  end if;
               end if;
            end;
         end loop;

         if Subprogram.Is_Function then
            declare
               Info      : constant Types.Type_Info :=
                 Types.Resolve (Member.Owner, Subprogram.Result);
               Type_Name : constant String :=
                 To_String (Subprogram.Result.Name);
            begin
               case Info.Category is
                  when Unknown =>
                     Error (Member.File_Name, Subprogram.Position,
                            "unknown type " & Type_Name);
                  when Capability_Array_Value | Storage_Value =>
                     Error (Member.File_Name, Subprogram.Position,
                            Unsupported_Text ("results of type " & Type_Name));
                  when String_Value =>
                     Buffers := Buffers + 1;
                  when others =>
                     Check_Interface (Info, Type_Name, Subprogram.Position);
               end case;
            end;
         end if;

         if Buffers > 1 then
            Error (Member.File_Name, Subprogram.Position,
                   "only one string or array can be passed in an "
                   & "invocation");
         end if;
      end Check_Member;

      -----------
      -- Error --
      -----------

      procedure Error
        (File_Name : Unbounded_String;
         Position  : Idle.Syntax.Source_Position;
         Message   : String)
      is
      begin
         Idle.Diagnostics.Error
           (To_String (File_Name), Position.Line, Position.Column, Message);
         OK := False;
      end Error;

   begin
      for Ancestor of Ancestors loop
         Check_Declarations (Ancestor);
      end loop;
      Check_Declarations (Item);
      Check_Generated_Names;

      for Member of Members loop
         Check_Member (Member);
      end loop;
      Idle.Hierarchy.Check_Members (Item);

      --  Errors in finding or reading the ancestors were reported by
      --  Idle.Hierarchy.

      return OK and then Idle.Diagnostics.Error_Count = Errors_Before;
   end Check;

   ----------------
   -- Check_User --
   ----------------

   function Check_User
     (Item : Idle.Syntax.Interface_Declaration)
      return Boolean
   is
      Object_Name : constant String :=
        Object_Type_Name (To_String (Item.Name));
      OK          : Boolean := True;

      procedure Error
        (File_Name : Unbounded_String;
         Position  : Idle.Syntax.Source_Position;
         Message   : String);

      function Is_Cap_Function (Name : String) return Boolean
      is (Idle.Names.Key (Name)
            = Idle.Names.Key (Cap_Function (To_String (Item.Name)))
          or else (for some Ancestor of Idle.Hierarchy.Ancestors (Item) =>
                     Idle.Names.Key (Name)
                       = Idle.Names.Key
                           (Cap_Function (To_String (Ancestor.Name)))));
      --  True if Name is that of the cap function of Item's object type,
      --  or of an ancestor's.

      -----------
      -- Error --
      -----------

      procedure Error
        (File_Name : Unbounded_String;
         Position  : Idle.Syntax.Source_Position;
         Message   : String)
      is
      begin
         Idle.Diagnostics.Error
           (To_String (File_Name), Position.Line, Position.Column, Message);
         OK := False;
      end Error;

   begin
      for Declared_Constant of Item.Constants loop
         if Idle.Names.Key (To_String (Declared_Constant.Name))
           = Idle.Names.Key (Object_Name)
         then
            Error (Item.File_Name, Declared_Constant.Position,
                   "constant " & To_String (Declared_Constant.Name)
                   & " has the same name as the object type, which the "
                   & "interface package declares");
         end if;
      end loop;

      for Declared_Type of Item.Types loop
         if Idle.Names.Key (To_String (Declared_Type.Name))
           = Idle.Names.Key (Object_Name)
         then
            Error (Item.File_Name, Declared_Type.Position,
                   "type " & To_String (Declared_Type.Name)
                   & " has the same name as the object type, which the "
                   & "interface package declares");
         end if;
      end loop;

      for Member of Idle.Hierarchy.Members (Item) loop
         declare
            Subprogram_Name : constant String :=
              To_String (Member.Subprogram.Name);
         begin
            if Is_Cap_Function (Subprogram_Name) then
               Error (Member.File_Name, Member.Subprogram.Position,
                      "subprogram " & Subprogram_Name
                      & " has the name of a function that the object type "
                      & "declares");
            end if;
         end;
      end loop;

      return OK;
   end Check_User;

   ------------------------
   -- Constant_Reference --
   ------------------------

   function Constant_Reference
     (Item  : Idle.Syntax.Interface_Declaration;
      Owner : Idle.Syntax.Interface_Declaration;
      Name  : String)
      return String
   is
      Owner_Name : constant String := To_String (Owner.Name);
   begin
      if Idle.Names.Key (Owner_Name) = Idle.Names.Key (To_String (Item.Name))
      then
         return Idle.Names.Ada_Name (Name);
      else
         return "Rose.Interfaces." & Idle.Names.Ada_Name (Owner_Name)
           & "." & Idle.Names.Ada_Name (Name);
      end if;
   end Constant_Reference;

   -------------
   -- Earlier --
   -------------

   function Earlier
     (Left, Right : Idle.Syntax.Source_Position)
      return Boolean
   is
   begin
      return Left.Line < Right.Line
        or else (Left.Line = Right.Line and then Left.Column < Right.Column);
   end Earlier;

   -------------------
   -- Find_Constant --
   -------------------

   function Find_Constant
     (Item   : Idle.Syntax.Interface_Declaration;
      Name   : String;
      Before : Idle.Syntax.Source_Position;
      Owner  : out Idle.Syntax.Interface_Declaration;
      Found  : out Idle.Syntax.Constant_Declaration)
      return Boolean
   is
      Key : constant String := Idle.Names.Key (Name);

      function Matches (Item : Idle.Syntax.Constant_Declaration) return Boolean
      is (Idle.Names.Key (To_String (Item.Name)) = Key);

   begin
      for Declared of Item.Constants loop
         if Earlier (Declared.Position, Before)
           and then Matches (Declared)
         then
            Owner := Item;
            Found := Declared;
            return True;
         end if;
      end loop;

      for Ancestor of Idle.Hierarchy.Ancestors (Item) loop
         for Declared of Ancestor.Constants loop
            if Matches (Declared) then
               Owner := Ancestor;
               Found := Declared;
               return True;
            end if;
         end loop;
      end loop;

      return False;
   end Find_Constant;

   --------------
   -- Generate --
   --------------

   procedure Generate
     (Item             : Idle.Syntax.Interface_Declaration;
      Output_Directory : String;
      Target           : Idle.Targets.Target := Kernel_Target)
   is
   begin
      case Item.Kind is
         when Idle.Syntax.Interface_Unit =>
            if Check (Item)
              and then (Target = Kernel_Target or else Check_User (Item))
            then
               Generate_Interface_Package (Item, Output_Directory, Target);
               Client.Generate (Item, Output_Directory, Target);
               Server.Generate (Item, Output_Directory, Target);
            end if;
         when Idle.Syntax.Command_Unit =>
            if Idle.Commands.Check (Item) then
               Commands.Generate_Command (Item, Output_Directory, Target);
            end if;
         when Idle.Syntax.Package_Unit =>
            if Idle.Commands.Check (Item) then
               Commands.Generate_Package (Item, Output_Directory);
            end if;
         when Idle.Syntax.Role_Unit =>
            --  A role is only part of the commands that play it.
            if Idle.Commands.Check (Item) then
               null;
            end if;
      end case;
   end Generate;

   --------------------------------
   -- Generate_Interface_Package --
   --------------------------------

   procedure Generate_Interface_Package
     (Item             : Idle.Syntax.Interface_Declaration;
      Output_Directory : String;
      Target           : Idle.Targets.Target)
   is
      Name : constant String := To_String (Item.Name);
      F    : Syn.Factory.Factory;

      function Endpoint_Constant
        (Constant_Name : String;
         Value         : Idle.Endpoints.Endpoint_Id)
         return not null Syn.Node_Access;

      -----------------------
      -- Endpoint_Constant --
      -----------------------

      function Endpoint_Constant
        (Constant_Name : String;
         Value         : Idle.Endpoints.Endpoint_Id)
         return not null Syn.Node_Access
      is
      begin
         return F.New_Object
           (Name          => Constant_Name,
            Object_Type   => F.New_Name (Endpoint_Type),
            Initial_Value =>
              F.New_Integer_Literal (Value, Base => 16, Group => 4),
            Is_Constant   => True);
      end Endpoint_Constant;

      Members : constant Idle.Hierarchy.Member_Vectors.Vector :=
        Idle.Hierarchy.Members (Item);
      Context : Context_List;

      function Object_Declarations return Syn.Node_Array;
      --  For the user target: Item's object type, and an abstract
      --  primitive for each subprogram that Item declares first.

      function Types_And_Constants return Syn.Node_Array;
      --  Item's constants and types, in the order they are declared.

      -------------------------
      -- Object_Declarations --
      -------------------------

      function Object_Declarations return Syn.Node_Array is
         use type Idle.Syntax.Parameter_Mode;
         use type Types.Category;

         Package_Name : constant String :=
           "Rose.Interfaces." & Idle.Names.Ada_Name (Name);
         Object_Name  : constant String := Object_Type_Name (Name);
         Result       : Node_List;

         function Type_Name (Info : Types.Type_Info) return String;
         --  The Ada type of Info, after adding its unit to the context.

         function Object_Class
           (Info   : Types.Type_Info;
            Is_Out : Boolean := False)
            return String;
         --  The Ada type of the interface Info: its class-wide object
         --  type, or its client type if Is_Out, after adding its package
         --  to the context with a limited with clause, so that interface
         --  packages can name each other, and their own clients.

         ------------------
         -- Object_Class --
         ------------------

         function Object_Class
           (Info   : Types.Type_Info;
            Is_Out : Boolean := False)
            return String
         is
         begin
            if Is_Out then
               Context.Add_Limited (To_String (Info.Unit));
               return To_String (Info.Ada_Name);
            else
               if Types.Object_Unit (Info) /= Package_Name then
                  Context.Add_Limited (Types.Object_Unit (Info));
               end if;
               return Types.Object_Class (Info);
            end if;
         end Object_Class;

         ---------------
         -- Type_Name --
         ---------------

         function Type_Name (Info : Types.Type_Info) return String is
            Unit : constant String := To_String (Info.Unit);
         begin
            if Unit /= "" and then Unit /= Package_Name then
               Context.Add (Unit);
            end if;
            return To_String (Info.Ada_Name);
         end Type_Name;

      begin
         for Parent of Item.Parents loop
            Context.Add ("Rose.Interfaces." & Idle.Names.Ada_Name (Parent));
         end loop;

         Result.Append
           (F.New_Interface_Type
              (Object_Name,
               [for Parent of Item.Parents =>
                  F.New_Name (Object_Type (Parent))],
               Is_Limited => True));

         Context.Add ("Rose.Capabilities");
         Result.Append
           (F.New_Function
              (Cap_Function (Name), F.New_Name (Capability_Name),
               [F.New_Parameter
                  ("Item", F.New_Name (Object_Name), Syn.In_Out_Mode)],
               Is_Abstract => True));

         for Member of Members loop
            if Idle.Names.Key (To_String (Member.Declared_In))
              = Idle.Names.Key (Name)
            then
               declare
                  Subprogram : Idle.Syntax.Subprogram renames
                    Member.Subprogram;
                  Parameters : Node_List;
               begin
                  --  Item is in out, for functions too, so that a client
                  --  can open itself on its first call.
                  Parameters.Append
                    (F.New_Parameter
                       ("Item", F.New_Name (Object_Name), Syn.In_Out_Mode));
                  for Parameter of Subprogram.Parameters loop
                     declare
                        Info : constant Types.Type_Info :=
                          Types.Resolve (Member.Owner, Parameter.Of_Type);
                     begin
                        if Info.Category = Types.Interface_Value then
                           Parameters.Append
                             (F.New_Parameter
                                (Support.Name (Parameter),
                                 F.New_Name
                                   (Object_Class
                                      (Info,
                                       Is_Out =>
                                         Parameter.Mode
                                         = Idle.Syntax.Out_Mode)),
                                 Syn.In_Out_Mode));
                        elsif Info.Category = Types.String_Value
                          and then Parameter.Mode /= Idle.Syntax.In_Mode
                        then
                           Context.Add ("Rose.Texts");
                           Parameters.Append
                             (F.New_Parameter
                                (Support.Name (Parameter),
                                 F.New_Name (Text_Name),
                                 (if Parameter.Mode = Idle.Syntax.Out_Mode
                                  then Syn.Out_Mode
                                  else Syn.In_Out_Mode)));
                        else
                           Parameters.Append
                             (F.New_Parameter
                                (Support.Name (Parameter),
                                 F.New_Name (Type_Name (Info)),
                                 (case Parameter.Mode is
                                     when Idle.Syntax.In_Mode     =>
                                       Syn.In_Mode,
                                     when Idle.Syntax.Out_Mode    =>
                                       Syn.Out_Mode,
                                     when Idle.Syntax.In_Out_Mode =>
                                       Syn.In_Out_Mode)));
                        end if;
                     end;
                  end loop;

                  if Subprogram.Is_Function then
                     declare
                        Info : constant Types.Type_Info :=
                          Types.Resolve (Member.Owner, Subprogram.Result);
                     begin
                        Result.Append
                          (F.New_Function
                             (Support.Name (Subprogram),
                              F.New_Name
                                (if Info.Category = Types.Interface_Value
                                 then Object_Class (Info)
                                 else Type_Name (Info)),
                              Parameters.To_Array,
                              Is_Abstract => True));
                     end;
                  else
                     Result.Append
                       (F.New_Procedure
                          (Support.Name (Subprogram), Parameters.To_Array,
                           Is_Abstract => True));
                  end if;
               end;
            end if;
         end loop;

         return Result.To_Array;
      end Object_Declarations;

      -------------------------
      -- Types_And_Constants --
      -------------------------

      function Types_And_Constants return Syn.Node_Array is
         use Idle.Syntax;

         function Value_Node
           (Text     : Unbounded_String;
            Position : Source_Position)
            return not null Syn.Node_Access;
         --  Text, a value or bound written at Position: an integer literal
         --  as written, or a reference to a constant.

         function Constant_Node
           (Item : Constant_Declaration)
            return not null Syn.Node_Access
         is (F.New_Object
               (Name          => Idle.Names.Ada_Name (To_String (Item.Name)),
                Initial_Value => Value_Node (Item.Value, Item.Position),
                Is_Constant   => True));

         function Type_Node
           (Item : Type_Declaration)
            return not null Syn.Node_Access;

         ---------------
         -- Type_Node --
         ---------------

         function Type_Node
           (Item : Type_Declaration)
            return not null Syn.Node_Access
         is
            Type_Name : constant String :=
              Idle.Names.Ada_Name (To_String (Item.Name));
         begin
            case Item.Kind is
               when Range_Type =>
                  return F.New_Range_Type
                    (Type_Name,
                     Value_Node (Item.Low, Item.Position),
                     Value_Node (Item.High, Item.Position));
               when Derived_Type =>
                  declare
                     Parent : constant String := To_String (Item.Parent.Name);
                  begin
                     if Standard_Type (Parent) = "" then
                        return F.New_Derived_Type
                          (Type_Name,
                           F.New_Name (Idle.Names.Ada_Name (Parent)));
                     else
                        if Standard_Package (Parent) /= "" then
                           Context.Add (Standard_Package (Parent));
                        end if;
                        return F.New_Derived_Type
                          (Type_Name, F.New_Name (Standard_Type (Parent)));
                     end if;
                  end;
               when Enumeration_Type =>
                  return F.New_Enumeration_Type
                    (Type_Name,
                     [for Literal of Item.Literals =>
                        F.New_Name (Idle.Names.Ada_Name (Literal))]);
            end case;
         end Type_Node;

         ----------------
         -- Value_Node --
         ----------------

         function Value_Node
           (Text     : Unbounded_String;
            Position : Source_Position)
            return not null Syn.Node_Access
         is
            Interface_Item : Interface_Declaration
              renames Generate_Interface_Package.Item;
            Name           : constant String := To_String (Text);
            Owner          : Interface_Declaration;
            Found          : Constant_Declaration;
         begin
            if Is_Name (Name)
              and then Find_Constant
                         (Interface_Item, Name, Position, Owner, Found)
            then
               if Idle.Names.Key (To_String (Owner.Name))
                 /= Idle.Names.Key (To_String (Interface_Item.Name))
               then
                  Context.Add
                    ("Rose.Interfaces."
                     & Idle.Names.Ada_Name (To_String (Owner.Name)));
               end if;
               return F.New_Name
                 (Constant_Reference (Interface_Item, Owner, Name));
            else
               return F.New_Name (Name);
            end if;
         end Value_Node;

         Result        : Node_List;
         Next_Constant : Positive := 1;
         Next_Type     : Positive := 1;

      begin
         while Next_Constant <= Item.Constants.Last_Index
           or else Next_Type <= Item.Types.Last_Index
         loop
            if Next_Type > Item.Types.Last_Index
              or else (Next_Constant <= Item.Constants.Last_Index
                       and then Earlier
                                  (Item.Constants (Next_Constant).Position,
                                   Item.Types (Next_Type).Position))
            then
               Result.Append (Constant_Node (Item.Constants (Next_Constant)));
               Next_Constant := Next_Constant + 1;
            else
               Result.Append (Type_Node (Item.Types (Next_Type)));
               Next_Type := Next_Type + 1;
            end if;
         end loop;
         return Result.To_Array;
      end Types_And_Constants;

      --  The interface ids of the ancestors and of Item, the endpoint id
      --  of each subprogram, and then the position of each subprogram's
      --  cap in the reply to the interface cap. Clients, and anything
      --  else that opens the interface cap, use these positions rather
      --  than assuming an order.

      Declarations : constant Syn.Node_Array :=
        Types_And_Constants
        & [for Ancestor of Idle.Hierarchy.Ancestors (Item) =>
           Endpoint_Constant
             (Interface_Name (Ancestor),
              Idle.Endpoints.Interface_Id (Ancestor))]
        & [Endpoint_Constant
             (Interface_Name (Item), Idle.Endpoints.Interface_Id (Item))]
        & [for Member of Members =>
             Endpoint_Constant
               (Endpoint_Name (Member.Subprogram),
                Idle.Endpoints.Subprogram_Id
                  (Member.Owner, Member.Subprogram))]
        & [for Index in 1 .. Members.Last_Index =>
             F.New_Object
               (Name          => Index_Name (Members (Index).Subprogram),
                Initial_Value =>
                  F.New_Integer_Literal (Long_Long_Long_Integer (Index - 1)),
                Is_Constant   => True)]
        & [F.New_Object
             (Name          => Count_Name,
              Initial_Value =>
                F.New_Integer_Literal
                  (Long_Long_Long_Integer (Members.Length)),
              Is_Constant   => True)];

      User_Declarations : constant Syn.Node_Array :=
        (if Target = User_Target
         then Object_Declarations
         else Syn.No_Nodes);

   begin
      Context.Add ("Rose.Objects");
      Syn.Units.Write
        (F.New_Compilation_Unit
           (Context => Context.To_Array (F),
            Item    =>
              F.New_Package
                (Name        =>
                   "Rose.Interfaces." & Idle.Names.Ada_Name (Name),
                 Public_Part => Declarations & User_Declarations)),
         Output_Directory);
   end Generate_Interface_Package;

   -------------------------
   -- Is_Integer_Constant --
   -------------------------

   function Is_Integer_Constant
     (Owner : Idle.Syntax.Interface_Declaration;
      Item  : Idle.Syntax.Constant_Declaration)
      return Boolean
   is
      Value      : constant String := To_String (Item.Value);
      Next_Owner : Idle.Syntax.Interface_Declaration;
      Next       : Idle.Syntax.Constant_Declaration;
   begin
      --  A name must refer to an earlier constant, or to an ancestor's,
      --  so following the chain always ends.
      return not Is_Name (Value)
        or else
          (Find_Constant (Owner, Value, Item.Position, Next_Owner, Next)
           and then Is_Integer_Constant (Next_Owner, Next));
   end Is_Integer_Constant;

end Idle.Targets.Kernel;
