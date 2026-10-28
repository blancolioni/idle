private with Ada.Containers.Indefinite_Ordered_Maps;
private with Ada.Containers.Indefinite_Ordered_Sets;
private with Ada.Containers.Vectors;

with Syn;
with Syn.Factory;

with Idle.Hierarchy;
with Idle.Syntax;

private package Idle.Targets.Kernel.Support is

   --  What the kernel client and server generators share: the names of
   --  the generated entities, and lists of declarations, bodies and
   --  context clauses. Idle.Targets.Kernel.Types maps IDL types to Ada.

   Capability_Name : constant String := "Rose.Capabilities.Capability";
   Word_Name       : constant String := "Rose.Words.Word";
   Record_Name     : constant String := "Rose.Invocation.Invocation_Record";
   Text_Name       : constant String := "Rose.Texts.Text";
   --  For the user target, the type of an out or in out string.

   function Standard_Type (Name : String) return String;
   --  The Ada type of the predefined IDL type Name, or "" if there is no
   --  such type.

   function Standard_Package (Name : String) return String;
   --  The unit that declares the Ada type of the predefined IDL type
   --  Name, or "" if it is declared in Standard.

   function Qualified (Prefix, Name : String) return String
   is (if Prefix = "" then Name else Prefix & "." & Name);
   --  Name, qualified by Prefix if it is not "".

   function Name (Item : Idle.Syntax.Subprogram) return String;
   --  The Ada name of Item.

   function Name (Item : Idle.Syntax.Parameter) return String;
   --  The Ada name of Item.

   function Interface_Name (Item : Idle.Syntax.Interface_Declaration)
     return String;
   --  The name of the endpoint id constant of the interface Item.

   function Endpoint_Name (Item : Idle.Syntax.Subprogram) return String;
   --  The name of the endpoint id constant of Item.

   function Index_Name (Item : Idle.Syntax.Subprogram) return String;
   --  The name of the constant that gives the position of the cap of Item
   --  in the reply to the interface cap.

   function Object_Type (Interface_Name : String) return String;
   --  The full name of the user target's object type for the interface
   --  Interface_Name, as written in IDL: for File,
   --  Rose.Interfaces.File.File_Object.

   function Object_Type_Name (Interface_Name : String) return String;
   --  Its simple name: File_Object.

   function Cap_Function (Interface_Name : String) return String;
   --  The function that the user target's object type for the interface
   --  Interface_Name declares, which returns the object's cap for that
   --  interface: for File, File_Cap.

   Count_Name : constant String := "Subprogram_Count";
   --  The name of the constant that gives the number of caps in the
   --  reply to the interface cap.

   function Is_Resource
     (Item : Idle.Syntax.Interface_Declaration)
      return Boolean;
   --  True if Item is the interface Resource, or inherits it: its objects
   --  hold something until they are released (Rose ADR 0010).

   function Is_Release (Member : Idle.Hierarchy.Member) return Boolean;
   --  True if Member is the Release that the interface Resource declares.

   function Subprograms
     (Item : Idle.Syntax.Interface_Declaration)
      return Idle.Syntax.Subprogram_Vectors.Vector;
   --  The subprograms of Item, including those it inherits, in the order
   --  of their caps (see Idle.Hierarchy.Members).

   type Node_List is tagged private;
   --  Declarations or statements, in the order they are added.

   procedure Append
     (List : in out Node_List;
      Item : not null Syn.Node_Access);

   function To_Array (List : Node_List) return Syn.Node_Array;

   type Body_List is tagged private;
   --  Subprogram bodies, in alphabetical order of their names, as GNAT's
   --  style check requires.

   procedure Add
     (List : in out Body_List;
      Name : String;
      Item : not null Syn.Node_Access);

   function To_Array (List : Body_List) return Syn.Node_Array;

   type Context_List is tagged private;
   --  The units named by with clauses, each once and in alphabetical
   --  order.

   procedure Add
     (List      : in out Context_List;
      Unit_Name : String);

   procedure Add_Limited
     (List      : in out Context_List;
      Unit_Name : String);
   --  Name Unit_Name in a limited with clause, unless it is also added
   --  with Add.

   function Contains
     (List      : Context_List;
      Unit_Name : String)
      return Boolean;

   function To_Array
     (List    : Context_List;
      Factory : in out Syn.Factory.Factory)
      return Syn.Node_Array;
   --  A with clause for each unit in List, then a limited with clause for
   --  each unit added only with Add_Limited.

private

   package Node_Maps is
     new Ada.Containers.Indefinite_Ordered_Maps
       (String, Syn.Node_Access, "=" => Syn."=");

   package Name_Sets is
     new Ada.Containers.Indefinite_Ordered_Sets (String);

   package Node_Vectors is
     new Ada.Containers.Vectors (Positive, Syn.Node_Access, Syn."=");

   type Node_List is tagged record
      Items : Node_Vectors.Vector;
   end record;

   type Body_List is tagged record
      Items : Node_Maps.Map;
   end record;
   --  Keyed by the name of each body in lower case, which is how GNAT
   --  compares them.

   type Context_List is tagged record
      Units         : Name_Sets.Set;
      Limited_Units : Name_Sets.Set;
   end record;

end Idle.Targets.Kernel.Support;
