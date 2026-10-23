with Ada.Containers;
with Ada.Strings.Unbounded;

with Syn;
with Syn.Factory;
with Syn.Units;

with Idle.Diagnostics;
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
      File_Name : constant String := To_String (Item.File_Name);
      Name      : constant String := To_String (Item.Name);
      Ada_Name  : constant String := Idle.Names.Ada_Name (Name);
      OK        : Boolean := True;

      procedure Error
        (Position : Idle.Syntax.Source_Position;
         Message  : String);

      procedure Unsupported (What : String);

      -----------
      -- Error --
      -----------

      procedure Error
        (Position : Idle.Syntax.Source_Position;
         Message  : String)
      is
      begin
         Idle.Diagnostics.Error
           (File_Name, Position.Line, Position.Column, Message);
         OK := False;
      end Error;

      -----------------
      -- Unsupported --
      -----------------

      procedure Unsupported (What : String) is
      begin
         Error (Item.Position,
                What & " are not yet supported by the kernel target");
      end Unsupported;

   begin
      if Item.Parents.Length > 0 then
         Unsupported ("parent interfaces");
      end if;
      if Item.Types.Length > 0 then
         Unsupported ("type declarations");
      end if;
      if Item.Constants.Length > 0 then
         Unsupported ("constant declarations");
      end if;

      if not Endpoints.Has_Interface_Id (Name) then
         Error (Item.Position,
                "no endpoint id for interface " & Ada_Name
                & " in the endpoint table");
      end if;

      for Subprogram of Item.Subprograms loop
         if not Endpoints.Has_Method_Id (Name, To_String (Subprogram.Name))
         then
            Error (Subprogram.Position,
                   "no endpoint id for " & Ada_Name & "."
                   & Support.Name (Subprogram) & " in the endpoint table");
         end if;

         for Parameter of Subprogram.Parameters loop
            if Parameter.Mode not in Idle.Syntax.In_Mode then
               Error (Parameter.Position,
                      "out and in out parameters are not yet supported "
                      & "by the kernel target");
            elsif Kind (Parameter.Of_Type) not in Word_Type | Capability_Type
            then
               Error (Parameter.Position,
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
            Error (Subprogram.Position,
                   "results of type " & To_String (Subprogram.Result.Name)
                   & " are not yet supported by the kernel target");
         end if;
      end loop;

      return OK;
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

      Declarations : constant Syn.Node_Array :=
        [Endpoint_Constant
           (Interface_Name (Item), Endpoints.Interface_Id (Name))]
        & [for Subprogram of Item.Subprograms =>
             Endpoint_Constant
               (Endpoint_Name (Subprogram),
                Endpoints.Method_Id (Name, To_String (Subprogram.Name)))];

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
