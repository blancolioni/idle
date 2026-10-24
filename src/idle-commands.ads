with Ada.Containers.Vectors;
with Ada.Strings.Unbounded;

with Idle.Syntax;

package Idle.Commands is

   --  Commands, packages and roles (blancolioni/idle#2): their checks,
   --  and what the generators need to know about them.

   use Ada.Strings.Unbounded;

   function Check (Item : Idle.Syntax.Interface_Declaration) return Boolean;
   --  Report what is wrong with the command, package or role Item through
   --  Idle.Diagnostics. True if there was nothing to report.

   type Argument_Type is
     (Boolean_Argument, Natural_Argument, Positive_Argument,
      String_Argument, String_List_Argument, Other_Argument);

   function Type_Of (Item : Idle.Syntax.Argument) return Argument_Type;

   type Place_Kind is (Word_Place, Cap_Place, Item_Place, List_Place);

   type Place is record
      Kind  : Place_Kind := Word_Place;
      Index : Natural := 0;
      --  The data word or cap of a Word_Place or Cap_Place, or the first
      --  buffer item of an Item_Place or List_Place.
      Count : Natural := 0;
      --  For a List_Place, the data word that holds its number of items.
   end record;
   --  Where an argument is in the launch invocation: role members are
   --  caps, first and in role order; scalars and a list's count are data
   --  words, in declaration order; and strings are buffer items, those of
   --  string arguments first, in declaration order, then a list's.

   type Stream is (No_Stream, Input_Stream, Output_Stream, Error_Stream);

   type Placed_Argument is record
      Argument  : Idle.Syntax.Argument;
      Role      : Unbounded_String;
      --  The role it comes from, or "" for a declared argument.
      Stream    : Commands.Stream := No_Stream;
      Where     : Place;
   end record;

   package Placed_Vectors is
     new Ada.Containers.Vectors (Positive, Placed_Argument);

   function Signature
     (Item : Idle.Syntax.Interface_Declaration)
      return Placed_Vectors.Vector;
   --  The arguments of the command Item, the members of its roles first,
   --  each with its place in the launch invocation.

   function Aspect
     (Aspects : Idle.Syntax.Aspect_Vectors.Vector;
      Name    : String;
      Default : String := "")
      return String;
   --  The text of the aspect Name in Aspects, or Default if there is none.

   function Has_Aspect
     (Aspects : Idle.Syntax.Aspect_Vectors.Vector;
      Name    : String)
      return Boolean;

   function Package_Name
     (Item : Idle.Syntax.Interface_Declaration)
      return String;
   --  The package of the command Item: its name without the last part.

   function Simple_Name (Name : String) return String;
   --  The last part of the qualified name Name.

   function Detail
     (Item : Idle.Syntax.Interface_Declaration;
      Name : String)
      return String;
   --  The aspect Name of the package Item, or, if Item leaves it out and
   --  the aspect is one that is inherited, that of the nearest enclosing
   --  package that gives it, or "".

end Idle.Commands;
