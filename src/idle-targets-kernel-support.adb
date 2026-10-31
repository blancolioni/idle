with Ada.Characters.Handling;
with Ada.Strings.Unbounded;

with Idle.Names;

package body Idle.Targets.Kernel.Support is

   use Ada.Strings.Unbounded;

   Resource_Name : constant String := "Resource";
   Release_Name  : constant String := "Release";

   procedure Find_Standard
     (Name     : String;
      Ada_Name : out Unbounded_String;
      Unit     : out Unbounded_String);
   --  The Ada type of the predefined IDL type Name and the unit that
   --  declares it, or "" for both if there is no such type. Unit is "" for
   --  a type declared in Standard.

   ---------
   -- Add --
   ---------

   procedure Add
     (List : in out Body_List;
      Name : String;
      Item : not null Syn.Node_Access)
   is
   begin
      List.Items.Insert (Ada.Characters.Handling.To_Lower (Name), Item);
   end Add;

   ---------
   -- Add --
   ---------

   procedure Add
     (List      : in out Context_List;
      Unit_Name : String)
   is
   begin
      List.Units.Include (Unit_Name);
   end Add;

   -----------------
   -- Add_Limited --
   -----------------

   procedure Add_Limited
     (List      : in out Context_List;
      Unit_Name : String)
   is
   begin
      List.Limited_Units.Include (Unit_Name);
   end Add_Limited;

   ------------
   -- Append --
   ------------

   procedure Append
     (List : in out Node_List;
      Item : not null Syn.Node_Access)
   is
   begin
      List.Items.Append (Item);
   end Append;

   ------------------
   -- Cap_Function --
   ------------------

   function Cap_Function (Interface_Name : String) return String is
   begin
      return Idle.Names.Ada_Name (Interface_Name) & "_Cap";
   end Cap_Function;

   --------------
   -- Contains --
   --------------

   function Contains
     (List      : Context_List;
      Unit_Name : String)
      return Boolean
   is
   begin
      return List.Units.Contains (Unit_Name);
   end Contains;

   -------------------
   -- Endpoint_Name --
   -------------------

   function Endpoint_Name (Item : Idle.Syntax.Subprogram) return String is
   begin
      return Name (Item) & "_Endpoint";
   end Endpoint_Name;

   -------------------
   -- Find_Standard --
   -------------------

   procedure Find_Standard
     (Name     : String;
      Ada_Name : out Unbounded_String;
      Unit     : out Unbounded_String)
   is
      Key : constant String := Idle.Names.Key (Name);

      procedure Set (Type_Name, Unit_Name : String);

      ---------
      -- Set --
      ---------

      procedure Set (Type_Name, Unit_Name : String) is
      begin
         Ada_Name := To_Unbounded_String (Type_Name);
         Unit := To_Unbounded_String (Unit_Name);
      end Set;

   begin
      Set ("", "");
      if Key in "word" | "word_8" | "word_16" | "word_32" | "word_64" then
         Set ("Rose.Words." & Idle.Names.Ada_Name (Name), "Rose.Words");
      elsif Key in "natural" | "positive" | "boolean" | "integer" then
         Set (Idle.Names.Ada_Name (Name), "");
      elsif Key = "integer_64" then
         Set ("Long_Long_Integer", "");
      elsif Key = "object_id" then
         Set ("Rose.Objects.Object_Id", "Rose.Objects");
      elsif Key = "capability" then
         Set ("Rose.Capabilities.Capability", "Rose.Capabilities");
      elsif Key in "storage_count" | "storage_offset" then
         Set ("System.Storage_Elements." & Idle.Names.Ada_Name (Name),
              "System.Storage_Elements");
      end if;
   end Find_Standard;

   ----------------
   -- Index_Name --
   ----------------

   function Index_Name (Item : Idle.Syntax.Subprogram) return String is
   begin
      return Name (Item) & "_Index";
   end Index_Name;

   --------------------
   -- Interface_Name --
   --------------------

   function Interface_Name (Item : Idle.Syntax.Interface_Declaration)
     return String
   is
   begin
      return Idle.Names.Ada_Name (To_String (Item.Name)) & "_Interface";
   end Interface_Name;

   ----------------
   -- Is_Release --
   ----------------

   function Is_Release (Member : Idle.Hierarchy.Member) return Boolean is
   begin
      return Idle.Names.Key (To_String (Member.Declared_In))
          = Idle.Names.Key (Resource_Name)
        and then Idle.Names.Key (To_String (Member.Subprogram.Name))
          = Idle.Names.Key (Release_Name);
   end Is_Release;

   -----------------
   -- Is_Resource --
   -----------------

   function Is_Resource
     (Item : Idle.Syntax.Interface_Declaration)
      return Boolean
   is
      function Is_Named_Resource
        (Declaration : Idle.Syntax.Interface_Declaration)
         return Boolean
      is (Idle.Names.Key (To_String (Declaration.Name))
          = Idle.Names.Key (Resource_Name));
   begin
      return Is_Named_Resource (Item)
        or else (for some Ancestor of Idle.Hierarchy.Ancestors (Item) =>
                   Is_Named_Resource (Ancestor));
   end Is_Resource;

   ----------
   -- Name --
   ----------

   function Name (Item : Idle.Syntax.Subprogram) return String is
   begin
      return Idle.Names.Ada_Name (To_String (Item.Name));
   end Name;

   ----------
   -- Name --
   ----------

   function Name (Item : Idle.Syntax.Parameter) return String is
   begin
      return Idle.Names.Ada_Name (To_String (Item.Name));
   end Name;

   -----------------
   -- Object_Type --
   -----------------

   function Object_Type (Interface_Name : String) return String is
   begin
      return "Rose.Interfaces." & Idle.Names.Ada_Name (Interface_Name) & "."
        & Object_Type_Name (Interface_Name);
   end Object_Type;

   ----------------------
   -- Object_Type_Name --
   ----------------------

   function Object_Type_Name (Interface_Name : String) return String is
   begin
      return Idle.Names.Ada_Name (Interface_Name) & "_Object";
   end Object_Type_Name;

   ----------------------
   -- Standard_Package --
   ----------------------

   function Standard_Package (Name : String) return String is
      Ada_Name, Unit : Unbounded_String;
   begin
      Find_Standard (Name, Ada_Name, Unit);
      return To_String (Unit);
   end Standard_Package;

   -------------------
   -- Standard_Type --
   -------------------

   function Standard_Type (Name : String) return String is
      Ada_Name, Unit : Unbounded_String;
   begin
      Find_Standard (Name, Ada_Name, Unit);
      return To_String (Ada_Name);
   end Standard_Type;

   -----------------
   -- Subprograms --
   -----------------

   function Subprograms
     (Item : Idle.Syntax.Interface_Declaration)
      return Idle.Syntax.Subprogram_Vectors.Vector
   is
   begin
      return Result : Idle.Syntax.Subprogram_Vectors.Vector do
         for Member of Idle.Hierarchy.Members (Item) loop
            Result.Append (Member.Subprogram);
         end loop;
      end return;
   end Subprograms;

   --------------
   -- To_Array --
   --------------

   function To_Array (List : Node_List) return Syn.Node_Array is
   begin
      return [for Item of List.Items => Item];
   end To_Array;

   --------------
   -- To_Array --
   --------------

   function To_Array (List : Body_List) return Syn.Node_Array is
   begin
      return [for Item of List.Items => Item];
   end To_Array;

   --------------
   -- To_Array --
   --------------

   function To_Array
     (List    : Context_List;
      Factory : in out Syn.Factory.Factory)
      return Syn.Node_Array
   is
      Result : Node_List;
   begin
      for Unit_Name of List.Units loop
         Result.Append (Factory.New_With (Unit_Name));
      end loop;
      for Unit_Name of List.Limited_Units loop
         if not List.Units.Contains (Unit_Name) then
            Result.Append (Factory.New_With (Unit_Name, Is_Limited => True));
         end if;
      end loop;
      return Result.To_Array;
   end To_Array;

end Idle.Targets.Kernel.Support;
