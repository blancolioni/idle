with Ada.Containers.Indefinite_Hashed_Maps;
with Ada.Directories;
with Ada.Strings.Hash;

with Idle.Diagnostics;
with Idle.Names;
with Idle.Parser;

package body Idle.Hierarchy is

   package Declaration_Maps is
     new Ada.Containers.Indefinite_Hashed_Maps
       (Key_Type        => String,
        Element_Type    => Idle.Syntax.Interface_Declaration,
        Hash            => Ada.Strings.Hash,
        Equivalent_Keys => "=",
        "="             => Idle.Syntax."=");

   Loaded : Declaration_Maps.Map;
   --  Files read so far, keyed by file name, so that each file is parsed
   --  once.

   package Ancestor_Maps is
     new Ada.Containers.Indefinite_Hashed_Maps
       (Key_Type        => String,
        Element_Type    => Interface_Vectors.Vector,
        Hash            => Ada.Strings.Hash,
        Equivalent_Keys => "=",
        "="             => Interface_Vectors."=");

   Known_Ancestors : Ancestor_Maps.Map;
   --  The ancestors of each interface asked about so far, keyed by its
   --  file name, so that errors in finding them are reported once.

   procedure Add_Ancestors
     (Item     : Idle.Syntax.Interface_Declaration;
      Result   : in out Interface_Vectors.Vector;
      Visiting : in out Interface_Vectors.Vector);
   --  Append the ancestors of Item to Result that are not already there.
   --  Visiting holds the interfaces whose ancestors are being added, to
   --  catch an interface that is its own ancestor.

   function Contains
     (List : Interface_Vectors.Vector;
      Name : Unbounded_String)
      return Boolean;
   --  True if List has an interface called Name.

   function Find_Parent
     (Child  : Idle.Syntax.Interface_Declaration;
      Parent : String;
      Found  : out Idle.Syntax.Interface_Declaration)
      return Boolean;
   --  Read the parent Parent of Child, reporting an error if it is not
   --  there or declares some other interface.

   function Read (Path : String) return Idle.Syntax.Interface_Declaration;
   --  The interface declared in Path, which exists.

   -------------------
   -- Add_Ancestors --
   -------------------

   procedure Add_Ancestors
     (Item     : Idle.Syntax.Interface_Declaration;
      Result   : in out Interface_Vectors.Vector;
      Visiting : in out Interface_Vectors.Vector)
   is
   begin
      Visiting.Append (Item);
      for Parent_Name of Item.Parents loop
         declare
            Parent : Idle.Syntax.Interface_Declaration;
         begin
            if Contains (Visiting, To_Unbounded_String (Parent_Name)) then
               Idle.Diagnostics.Error
                 (To_String (Item.File_Name),
                  Item.Position.Line, Item.Position.Column,
                  "interface " & Parent_Name & " is its own ancestor");
            elsif not Contains (Result, To_Unbounded_String (Parent_Name))
              and then Find_Parent (Item, Parent_Name, Parent)
            then
               Add_Ancestors (Parent, Result, Visiting);
               Result.Append (Parent);
            end if;
         end;
      end loop;
      Visiting.Delete_Last;
   end Add_Ancestors;

   ---------------
   -- Ancestors --
   ---------------

   function Ancestors
     (Item : Idle.Syntax.Interface_Declaration)
      return Interface_Vectors.Vector
   is
      Key      : constant String := To_String (Item.File_Name);
      Result   : Interface_Vectors.Vector;
      Visiting : Interface_Vectors.Vector;
   begin
      if not Known_Ancestors.Contains (Key) then
         Add_Ancestors (Item, Result, Visiting);
         Known_Ancestors.Insert (Key, Result);
      end if;
      return Known_Ancestors.Element (Key);
   end Ancestors;

   -------------------
   -- Check_Members --
   -------------------

   procedure Check_Members (Item : Idle.Syntax.Interface_Declaration) is
      All_Members : constant Member_Vectors.Vector := Members (Item);
   begin
      for Index in 1 .. All_Members.Last_Index loop
         for Previous in 1 .. Index - 1 loop
            if Idle.Names.Key
                 (To_String (All_Members (Previous).Subprogram.Name))
              = Idle.Names.Key
                  (To_String (All_Members (Index).Subprogram.Name))
            then
               Idle.Diagnostics.Error
                 (To_String (Item.File_Name),
                  Item.Position.Line, Item.Position.Column,
                  Idle.Names.Ada_Name
                    (To_String (All_Members (Index).Subprogram.Name))
                  & " is declared by both "
                  & To_String (All_Members (Previous).Declared_In) & " and "
                  & To_String (All_Members (Index).Declared_In));
            end if;
         end loop;
      end loop;
   end Check_Members;

   --------------
   -- Contains --
   --------------

   function Contains
     (List : Interface_Vectors.Vector;
      Name : Unbounded_String)
      return Boolean
   is
   begin
      for Item of List loop
         if Idle.Names.Key (To_String (Item.Name))
           = Idle.Names.Key (To_String (Name))
         then
            return True;
         end if;
      end loop;
      return False;
   end Contains;

   ----------------------
   -- Declaration_File --
   ----------------------

   function Declaration_File
     (Near : Idle.Syntax.Interface_Declaration;
      Name : String)
      return String
   is
   begin
      return Ada.Directories.Compose
        (Ada.Directories.Containing_Directory (To_String (Near.File_Name)),
         Idle.Names.Key (Name), "idl");
   end Declaration_File;

   ----------
   -- Find --
   ----------

   function Find
     (Near  : Idle.Syntax.Interface_Declaration;
      Name  : String;
      Found : out Idle.Syntax.Interface_Declaration)
      return Boolean
   is
      Path : constant String := Declaration_File (Near, Name);
   begin
      if not Ada.Directories.Exists (Path) then
         return False;
      end if;
      Found := Read (Path);
      return Idle.Names.Key (To_String (Found.Name)) = Idle.Names.Key (Name);
   end Find;

   -----------------
   -- Find_Parent --
   -----------------

   function Find_Parent
     (Child  : Idle.Syntax.Interface_Declaration;
      Parent : String;
      Found  : out Idle.Syntax.Interface_Declaration)
      return Boolean
   is
      Child_File : constant String := To_String (Child.File_Name);
      Path       : constant String := Declaration_File (Child, Parent);
   begin
      if not Ada.Directories.Exists (Path) then
         Idle.Diagnostics.Error
           (Child_File, Child.Position.Line, Child.Position.Column,
            "parent interface " & Parent & " not found: no file " & Path);
         return False;
      end if;

      Found := Read (Path);
      if Idle.Names.Key (To_String (Found.Name)) /= Idle.Names.Key (Parent)
      then
         Idle.Diagnostics.Error
           (Child_File, Child.Position.Line, Child.Position.Column,
            Path & " declares " & To_String (Found.Name)
            & ", not the parent interface " & Parent);
         return False;
      end if;

      return True;
   end Find_Parent;

   -------------
   -- Members --
   -------------

   function Members
     (Item : Idle.Syntax.Interface_Declaration)
      return Member_Vectors.Vector
   is
      Result : Member_Vectors.Vector;

      procedure Add (From : Idle.Syntax.Interface_Declaration);

      ---------
      -- Add --
      ---------

      procedure Add (From : Idle.Syntax.Interface_Declaration) is
      begin
         for Subprogram of From.Subprograms loop
            Result.Append
              (Member'
                 (Declared_In => From.Name,
                  File_Name   => From.File_Name,
                  Owner       => From,
                  Subprogram  => Subprogram));
         end loop;
      end Add;

   begin
      for Ancestor of Ancestors (Item) loop
         Add (Ancestor);
      end loop;
      Add (Item);
      return Result;
   end Members;

   ----------
   -- Read --
   ----------

   function Read (Path : String) return Idle.Syntax.Interface_Declaration is
   begin
      if not Loaded.Contains (Path) then
         Loaded.Insert (Path, Idle.Parser.Parse_File (Path));
      end if;
      return Loaded.Element (Path);
   end Read;

end Idle.Hierarchy;
