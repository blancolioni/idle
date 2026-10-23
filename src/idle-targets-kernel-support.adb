with Ada.Characters.Handling;
with Ada.Strings.Unbounded;

with Idle.Names;

package body Idle.Targets.Kernel.Support is

   use Ada.Strings.Unbounded;

   --------------
   -- Ada_Type --
   --------------

   function Ada_Type (Item : Idle.Syntax.Type_Reference) return String is
   begin
      case Kind (Item) is
         when Word_Type =>
            return Word_Name;
         when Capability_Type =>
            return Capability_Name;
         when Interface_Type | Other_Type =>
            raise Program_Error;
      end case;
   end Ada_Type;

   ---------
   -- Add --
   ---------

   procedure Add
     (List : in out Body_List;
      Name : String;
      Item : not null Syn.Node_Access)
   is
   begin
      List.Items.Insert (Ada.Characters.Handling.To_Upper (Name), Item);
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

   -------------------
   -- Endpoint_Name --
   -------------------

   function Endpoint_Name (Item : Idle.Syntax.Subprogram) return String is
   begin
      return Name (Item) & "_Endpoint";
   end Endpoint_Name;

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
   -- Kind --
   ----------

   function Kind (Item : Idle.Syntax.Type_Reference) return Type_Kind is
      Key : constant String := Idle.Names.Key (To_String (Item.Name));
   begin
      if Item.Is_Interface then
         return Interface_Type;
      elsif Key = "word" then
         return Word_Type;
      elsif Key = "capability" then
         return Capability_Type;
      else
         return Other_Type;
      end if;
   end Kind;

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
