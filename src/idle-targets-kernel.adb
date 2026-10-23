with Ada.Containers;
with Ada.Strings.Unbounded;

with Syn;
with Syn.Factory;
with Syn.Units;

with Idle.Diagnostics;
with Idle.Names;

package body Idle.Targets.Kernel is

   use Ada.Strings.Unbounded;
   use type Ada.Containers.Count_Type;
   use type Syn.Node_Array;

   Endpoint_Type : constant String := "Rose.Objects.Endpoint_Id";

   --------------------------------
   -- Generate_Interface_Package --
   --------------------------------

   procedure Generate_Interface_Package
     (Item             : Idle.Syntax.Interface_Declaration;
      Endpoints        : Idle.Endpoints.Endpoint_Table;
      Output_Directory : String)
   is
      File_Name : constant String := To_String (Item.File_Name);
      Name      : constant String := To_String (Item.Name);
      Ada_Name  : constant String := Idle.Names.Ada_Name (Name);
      F         : Syn.Factory.Factory;
      OK        : Boolean := True;

      procedure Unsupported (What : String);

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

      -----------------
      -- Unsupported --
      -----------------

      procedure Unsupported (What : String) is
      begin
         Idle.Diagnostics.Error
           (File_Name, Item.Position.Line, Item.Position.Column,
            What & " are not yet supported by the kernel target");
         OK := False;
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
         Idle.Diagnostics.Error
           (File_Name, Item.Position.Line, Item.Position.Column,
            "no endpoint id for interface " & Ada_Name
            & " in the endpoint table");
         OK := False;
      end if;

      for Subprogram of Item.Subprograms loop
         if not Endpoints.Has_Method_Id (Name, To_String (Subprogram.Name))
         then
            Idle.Diagnostics.Error
              (File_Name, Subprogram.Position.Line,
               Subprogram.Position.Column,
               "no endpoint id for " & Ada_Name & "."
               & Idle.Names.Ada_Name (To_String (Subprogram.Name))
               & " in the endpoint table");
            OK := False;
         end if;
      end loop;

      if not OK then
         return;
      end if;

      declare
         Declarations : constant Syn.Node_Array :=
           [Endpoint_Constant
              (Ada_Name & "_Interface", Endpoints.Interface_Id (Name))]
           & [for Subprogram of Item.Subprograms =>
                Endpoint_Constant
                  (Idle.Names.Ada_Name (To_String (Subprogram.Name))
                   & "_Endpoint",
                   Endpoints.Method_Id (Name, To_String (Subprogram.Name)))];
      begin
         Syn.Units.Write
           (F.New_Compilation_Unit
              (Context => [F.New_With ("Rose.Objects")],
               Item    =>
                 F.New_Package
                   (Name        => "Rose.Interfaces." & Ada_Name,
                    Public_Part => Declarations)),
            Output_Directory);
      end;
   end Generate_Interface_Package;

end Idle.Targets.Kernel;
