with Ada.Characters.Handling;
with Ada.Strings.Unbounded;

with Idle.Hierarchy;
with Idle.Names;

package body Idle.Targets.Kernel.Support is

   use Ada.Strings.Unbounded;

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
      elsif Key in "natural" | "positive" | "boolean" then
         Set (Idle.Names.Ada_Name (Name), "");
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
   begin
      return [for Unit_Name of List.Units => Factory.New_With (Unit_Name)];
   end To_Array;

end Idle.Targets.Kernel.Support;
