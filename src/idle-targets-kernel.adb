with Ada.Containers;
with Ada.Strings.Unbounded;

with Syn;
with Syn.Factory;
with Syn.Units;

with Idle.Diagnostics;
with Idle.Hierarchy;
with Idle.Names;
with Idle.Targets.Kernel.Client;
with Idle.Targets.Kernel.Server;
with Idle.Targets.Kernel.Support;

package body Idle.Targets.Kernel is

   use Ada.Strings.Unbounded;
   use type Ada.Containers.Count_Type;
   use type Syn.Node_Array;
   use Idle.Targets.Kernel.Support;

   Endpoint_Type : constant String := "Rose.Objects.Endpoint_Id";

   function Check
     (Item      : Idle.Syntax.Interface_Declaration;
      Endpoints : Idle.Endpoints.Endpoint_Table)
      return Boolean;
   --  Report anything in Item that the kernel target does not support, or
   --  that has no endpoint id. True if there was nothing to report.

   procedure Generate_Interface_Package
     (Item             : Idle.Syntax.Interface_Declaration;
      Endpoints        : Idle.Endpoints.Endpoint_Table;
      Output_Directory : String);
   --  Write the package Rose.Interfaces.<Name>, which holds the endpoint
   --  ids of the interface and of each of its subprograms.

   -----------
   -- Check --
   -----------

   function Check
     (Item      : Idle.Syntax.Interface_Declaration;
      Endpoints : Idle.Endpoints.Endpoint_Table)
      return Boolean
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
         Name : constant String := To_String (Declaration.Name);

         procedure Unsupported (What : String);

         -----------------
         -- Unsupported --
         -----------------

         procedure Unsupported (What : String) is
         begin
            Error (Declaration.File_Name, Declaration.Position,
                   What & " are not yet supported by the kernel target");
         end Unsupported;

      begin
         if Declaration.Types.Length > 0 then
            Unsupported ("type declarations");
         end if;
         if Declaration.Constants.Length > 0 then
            Unsupported ("constant declarations");
         end if;

         if not Endpoints.Has_Interface_Id (Name) then
            Error (Declaration.File_Name, Declaration.Position,
                   "no endpoint id for interface "
                   & Idle.Names.Ada_Name (Name) & " in the endpoint table");
         end if;
      end Check_Declarations;

      ------------------
      -- Check_Member --
      ------------------

      procedure Check_Member (Member : Idle.Hierarchy.Member) is
         Subprogram : Idle.Syntax.Subprogram renames Member.Subprogram;
      begin
         if not Endpoints.Has_Method_Id
           (To_String (Member.Declared_In), To_String (Subprogram.Name))
         then
            Error (Member.File_Name, Subprogram.Position,
                   "no endpoint id for "
                   & Idle.Names.Ada_Name (To_String (Member.Declared_In))
                   & "." & Support.Name (Subprogram)
                   & " in the endpoint table");
         end if;

         for Parameter of Subprogram.Parameters loop
            if Parameter.Mode not in Idle.Syntax.In_Mode then
               Error (Member.File_Name, Parameter.Position,
                      "out and in out parameters are not yet supported "
                      & "by the kernel target");
            elsif Kind (Parameter.Of_Type) not in Word_Type | Capability_Type
            then
               Error (Member.File_Name, Parameter.Position,
                      (if Parameter.Of_Type.Is_Interface
                       then "interface parameters"
                       else "parameters of type "
                            & To_String (Parameter.Of_Type.Name))
                      & " are not yet supported by the kernel target");
            end if;
         end loop;

         if Subprogram.Is_Function
           and then Kind (Subprogram.Result) = Other_Type
         then
            Error (Member.File_Name, Subprogram.Position,
                   "results of type " & To_String (Subprogram.Result.Name)
                   & " are not yet supported by the kernel target");
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

      for Index in 1 .. Members.Last_Index loop
         Check_Member (Members (Index));

         --  The names of the subprograms are the names of the client's
         --  operations and of the server's handlers, so they must differ.

         for Earlier in 1 .. Index - 1 loop
            if Idle.Names.Key (To_String (Members (Earlier).Subprogram.Name))
              = Idle.Names.Key (To_String (Members (Index).Subprogram.Name))
            then
               Error (Item.File_Name, Item.Position,
                      Name (Members (Index).Subprogram)
                      & " is declared by both "
                      & To_String (Members (Earlier).Declared_In) & " and "
                      & To_String (Members (Index).Declared_In));
            end if;
         end loop;
      end loop;

      --  Errors in finding or reading the ancestors were reported by
      --  Idle.Hierarchy.

      return OK and then Idle.Diagnostics.Error_Count = Errors_Before;
   end Check;

   --------------
   -- Generate --
   --------------

   procedure Generate
     (Item             : Idle.Syntax.Interface_Declaration;
      Endpoints        : Idle.Endpoints.Endpoint_Table;
      Output_Directory : String)
   is
   begin
      if Check (Item, Endpoints) then
         Generate_Interface_Package (Item, Endpoints, Output_Directory);
         Client.Generate (Item, Output_Directory);
         Server.Generate (Item, Output_Directory);
      end if;
   end Generate;

   --------------------------------
   -- Generate_Interface_Package --
   --------------------------------

   procedure Generate_Interface_Package
     (Item             : Idle.Syntax.Interface_Declaration;
      Endpoints        : Idle.Endpoints.Endpoint_Table;
      Output_Directory : String)
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

      --  The interface ids of the ancestors and of Item, the endpoint id
      --  of each subprogram, and then the position of each subprogram's
      --  cap in the reply to the interface cap. Clients, and anything
      --  else that opens the interface cap, use these positions rather
      --  than assuming an order.

      Declarations : constant Syn.Node_Array :=
        [for Ancestor of Idle.Hierarchy.Ancestors (Item) =>
           Endpoint_Constant
             (Interface_Name (Ancestor),
              Endpoints.Interface_Id (To_String (Ancestor.Name)))]
        & [Endpoint_Constant
             (Interface_Name (Item), Endpoints.Interface_Id (Name))]
        & [for Member of Members =>
             Endpoint_Constant
               (Endpoint_Name (Member.Subprogram),
                Endpoints.Method_Id
                  (To_String (Member.Declared_In),
                   To_String (Member.Subprogram.Name)))]
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

   begin
      Syn.Units.Write
        (F.New_Compilation_Unit
           (Context => [F.New_With ("Rose.Objects")],
            Item    =>
              F.New_Package
                (Name        =>
                   "Rose.Interfaces." & Idle.Names.Ada_Name (Name),
                 Public_Part => Declarations)),
         Output_Directory);
   end Generate_Interface_Package;

end Idle.Targets.Kernel;
