with Ada.Containers.Indefinite_Ordered_Maps;
with Ada.Containers.Indefinite_Ordered_Sets;
with Ada.Containers.Ordered_Maps;
with Ada.Directories;
with Ada.Strings.Unbounded;

with Idle.Diagnostics;
with Idle.Names;
with Idle.Syntax;

package body Idle.Check is

   use Ada.Strings.Unbounded;

   package Name_Sets is
     new Ada.Containers.Indefinite_Ordered_Sets (String);

   package Name_Maps is
     new Ada.Containers.Indefinite_Ordered_Maps (String, String);

   package Id_Maps is
     new Ada.Containers.Ordered_Maps
       (Key_Type     => Idle.Endpoints.Endpoint_Id,
        Element_Type => Unbounded_String);

   ---------------
   -- Check_All --
   ---------------

   procedure Check_All
     (Items     : Idle.Hierarchy.Interface_Vectors.Vector;
      Endpoints : Idle.Endpoints.Endpoint_Table)
   is
      Checked     : Name_Sets.Set;
      --  The full names of the files checked.
      Directories : Name_Sets.Set;
      --  The directories of the files checked, as they were given.
      Parent_Of   : Name_Maps.Map;
      --  For the full name of each ancestor's file, an interface it is a
      --  parent of.
      Ids         : Id_Maps.Map;
      --  Each endpoint id in use, with what uses it.
      Seen        : Name_Sets.Set;
      --  What has had its endpoint id looked up, such as "Cap.Destroy",
      --  since an inherited subprogram uses its parent's id.

      procedure Check_Interface_Type
        (Item      : Idle.Syntax.Interface_Declaration;
         Reference : Idle.Syntax.Type_Reference;
         Position  : Idle.Syntax.Source_Position);
      --  Report Reference if it is an interface that cannot be found.

      procedure Error
        (File_Name : Unbounded_String;
         Position  : Idle.Syntax.Source_Position;
         Message   : String);

      procedure Record_Id
        (Label     : String;
         Id        : Idle.Endpoints.Endpoint_Id;
         File_Name : Unbounded_String;
         Position  : Idle.Syntax.Source_Position);
      --  Note that Label uses the endpoint id Id, and report it if
      --  something else already uses it.

      procedure Use_Interface_Id
        (Declaration : Idle.Syntax.Interface_Declaration);
      --  Look up the endpoint id of the interface Declaration.

      procedure Use_Method_Id (Member : Idle.Hierarchy.Member);
      --  Look up the endpoint id of the subprogram of Member.

      procedure Warn_Unchecked (Directory : String);
      --  Warn about each .idl file in Directory that is not checked.

      --------------------------
      -- Check_Interface_Type --
      --------------------------

      procedure Check_Interface_Type
        (Item      : Idle.Syntax.Interface_Declaration;
         Reference : Idle.Syntax.Type_Reference;
         Position  : Idle.Syntax.Source_Position)
      is
         Found : Idle.Syntax.Interface_Declaration;
         Name  : constant String := To_String (Reference.Name);
      begin
         if Reference.Is_Interface
           and then not Idle.Hierarchy.Find (Item, Name, Found)
         then
            Error (Item.File_Name, Position,
                   "unknown interface " & Name & ": no "
                   & Idle.Hierarchy.Declaration_File (Item, Name)
                   & " declares it");
         end if;
      end Check_Interface_Type;

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
      end Error;

      ---------------
      -- Record_Id --
      ---------------

      procedure Record_Id
        (Label     : String;
         Id        : Idle.Endpoints.Endpoint_Id;
         File_Name : Unbounded_String;
         Position  : Idle.Syntax.Source_Position)
      is
      begin
         if Ids.Contains (Id) then
            Error (File_Name, Position,
                   Label & " has the same endpoint id as "
                   & To_String (Ids.Element (Id)));
         else
            Ids.Insert (Id, To_Unbounded_String (Label));
         end if;
      end Record_Id;

      ----------------------
      -- Use_Interface_Id --
      ----------------------

      procedure Use_Interface_Id
        (Declaration : Idle.Syntax.Interface_Declaration)
      is
         Name  : constant String := To_String (Declaration.Name);
         Label : constant String :=
           "interface " & Idle.Names.Ada_Name (Name);
      begin
         if Seen.Contains (Label) then
            return;
         end if;
         Seen.Insert (Label);

         if Endpoints.Has_Interface_Id (Name) then
            Record_Id (Label, Endpoints.Interface_Id (Name),
                       Declaration.File_Name, Declaration.Position);
         else
            Error (Declaration.File_Name, Declaration.Position,
                   "no endpoint id for " & Label & " in the endpoint table");
         end if;
      end Use_Interface_Id;

      -------------------
      -- Use_Method_Id --
      -------------------

      procedure Use_Method_Id (Member : Idle.Hierarchy.Member) is
         Owner : constant String := To_String (Member.Declared_In);
         Name  : constant String := To_String (Member.Subprogram.Name);
         Label : constant String :=
           Idle.Names.Ada_Name (Owner) & "." & Idle.Names.Ada_Name (Name);
      begin
         if Seen.Contains (Label) then
            return;
         end if;
         Seen.Insert (Label);

         if Endpoints.Has_Method_Id (Owner, Name) then
            Record_Id (Label, Endpoints.Method_Id (Owner, Name),
                       Member.File_Name, Member.Subprogram.Position);
         else
            Error (Member.File_Name, Member.Subprogram.Position,
                   "no endpoint id for " & Label & " in the endpoint table");
         end if;
      end Use_Method_Id;

      --------------------
      -- Warn_Unchecked --
      --------------------

      procedure Warn_Unchecked (Directory : String) is
         use Ada.Directories;
         Search : Search_Type;
         Item   : Directory_Entry_Type;
         Found  : Name_Sets.Set;
      begin
         Start_Search (Search, Directory, "*.idl",
                       [Ordinary_File => True, others => False]);
         while More_Entries (Search) loop
            Get_Next_Entry (Search, Item);
            Found.Include (Simple_Name (Item));
         end loop;
         End_Search (Search);

         --  Warn in file name order, which the search does not promise.

         for Name of Found loop
            declare
               Path : constant String := Compose (Directory, Name);
               Full : constant String := Full_Name (Path);
            begin
               if not Checked.Contains (Full) then
                  Idle.Diagnostics.Warning
                    (Path, 0, 0,
                     "not compiled by this build"
                     & (if Parent_Of.Contains (Full)
                        then ", but it is a parent of "
                             & Parent_Of.Element (Full)
                        else ""));
               end if;
            end;
         end loop;
      end Warn_Unchecked;

   begin
      for Item of Items loop
         declare
            File_Name : constant String := To_String (Item.File_Name);
            Name      : constant String := To_String (Item.Name);
         begin
            Checked.Include (Ada.Directories.Full_Name (File_Name));
            Directories.Include
              (Ada.Directories.Containing_Directory (File_Name));

            if Ada.Directories.Simple_Name (File_Name)
              /= Idle.Names.Key (Name) & ".idl"
            then
               Error (Item.File_Name, Item.Position,
                      "interface " & Idle.Names.Ada_Name (Name)
                      & " should be declared in "
                      & Idle.Names.Key (Name) & ".idl");
            end if;

            for Ancestor of Idle.Hierarchy.Ancestors (Item) loop
               Parent_Of.Include
                 (Ada.Directories.Full_Name (To_String (Ancestor.File_Name)),
                  Idle.Names.Ada_Name (Name));
               Use_Interface_Id (Ancestor);
            end loop;
            Use_Interface_Id (Item);

            Idle.Hierarchy.Check_Members (Item);
            for Member of Idle.Hierarchy.Members (Item) loop
               Use_Method_Id (Member);
            end loop;

            for Subprogram of Item.Subprograms loop
               for Parameter of Subprogram.Parameters loop
                  Check_Interface_Type
                    (Item, Parameter.Of_Type, Parameter.Position);
               end loop;
               if Subprogram.Is_Function then
                  Check_Interface_Type
                    (Item, Subprogram.Result, Subprogram.Position);
               end if;
            end loop;
         end;
      end loop;

      for Directory of Directories loop
         Warn_Unchecked (Directory);
      end loop;
   end Check_All;

end Idle.Check;
