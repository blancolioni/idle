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
   --  Parents read so far, keyed by file name, so that each file is
   --  parsed once.

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
      Path       : constant String :=
        Ada.Directories.Compose
          (Ada.Directories.Containing_Directory (Child_File),
           Idle.Names.Key (Parent), "idl");
   begin
      if Loaded.Contains (Path) then
         Found := Loaded.Element (Path);
         return True;
      end if;

      if not Ada.Directories.Exists (Path) then
         Idle.Diagnostics.Error
           (Child_File, Child.Position.Line, Child.Position.Column,
            "parent interface " & Parent & " not found: no file " & Path);
         return False;
      end if;

      Found := Idle.Parser.Parse_File (Path);
      if Idle.Names.Key (To_String (Found.Name)) /= Idle.Names.Key (Parent)
      then
         Idle.Diagnostics.Error
           (Child_File, Child.Position.Line, Child.Position.Column,
            Path & " declares " & To_String (Found.Name)
            & ", not the parent interface " & Parent);
         return False;
      end if;

      Loaded.Insert (Path, Found);
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

end Idle.Hierarchy;
