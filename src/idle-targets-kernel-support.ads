private with Ada.Containers.Indefinite_Ordered_Maps;
private with Ada.Containers.Indefinite_Ordered_Sets;
private with Ada.Containers.Vectors;

with Syn;
with Syn.Factory;

with Idle.Syntax;

private package Idle.Targets.Kernel.Support is

   --  What the kernel client and server generators share: how IDL types
   --  map to Ada and to the invocation record, the names of the
   --  generated entities, and lists of declarations and context clauses.

   type Type_Kind is (Word_Type, Capability_Type, Interface_Type, Other_Type);
   --  Word_Type and Capability_Type are passed in data words and cap
   --  slots respectively; Interface_Type is an interface value, passed as
   --  the single cap that opens it.

   function Kind (Item : Idle.Syntax.Type_Reference) return Type_Kind;

   Capability_Name : constant String := "Rose.Capabilities.Capability";
   Word_Name       : constant String := "Rose.Words.Word";
   Record_Name     : constant String := "Rose.Invocation.Invocation_Record";

   function Standard_Type (Name : String) return String;
   --  The Ada type of the predefined IDL type Name, or "" if there is no
   --  such type.

   function Standard_Package (Name : String) return String;
   --  The unit that declares the Ada type of the predefined IDL type
   --  Name, or "" if it is declared in Standard.

   function Ada_Type (Item : Idle.Syntax.Type_Reference) return String
     with Pre => Kind (Item) in Word_Type | Capability_Type;
   --  The Ada type of a word or a capability.

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

   Count_Name : constant String := "Subprogram_Count";
   --  The name of the constant that gives the number of caps in the
   --  reply to the interface cap.

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

   function To_Array
     (List    : Context_List;
      Factory : in out Syn.Factory.Factory)
      return Syn.Node_Array;
   --  A with clause for each unit in List.

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
   --  Keyed by the name of each body in upper case.

   type Context_List is tagged record
      Units : Name_Sets.Set;
   end record;

end Idle.Targets.Kernel.Support;
