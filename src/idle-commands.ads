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
      String_Argument, String_List_Argument, Interface_Argument,
      Other_Argument);

   function Type_Of
     (Near : Idle.Syntax.Interface_Declaration;
      Item : Idle.Syntax.Argument)
      return Argument_Type;
   --  The kind of the argument or role member Item, declared by Near. A
   --  type that is not predefined is an Interface_Argument if it names an
   --  interface, and an Other_Argument if it does not.

   type Place_Kind is
     (No_Place, Word_Place, Cap_Place, Item_Place, List_Place);

   type Place is record
      Kind  : Place_Kind := Word_Place;
      Index : Natural := 0;
      --  The data word or cap of a Word_Place or Cap_Place, or the first
      --  buffer item of an Item_Place or List_Place.
      Count : Natural := 0;
      --  For a List_Place, the data word that holds its number of items.
   end record;
   --  Where an argument is in the launch invocation: role members are
   --  caps, first and in role order, and then interface arguments, in
   --  declaration order; scalars and a list's count are data words, in
   --  declaration order; and strings are buffer items, those of string
   --  arguments first, in declaration order, then a list's. An out
   --  argument has no place in the invocation (No_Place).
   --
   --  Where a result is in the reply to the launch invocation: out
   --  scalars are data words from 1, after the completion word, out
   --  strings are buffer items from 1, and out interfaces are caps from 0
   --  (Cap_Place), each in declaration order.
   --
   --  An argument is in or out (Rose ADR 0012, section 1): the mode is
   --  only the direction. What a command can do with an interface is its
   --  type, and whether the shell commits its changes is the command's
   --  (Is_Live).

   function Is_Versioned
     (Near : Idle.Syntax.Interface_Declaration;
      Item : Idle.Syntax.Argument)
      return Boolean;
   --  True if Item, an argument declared by Near, is an interface whose
   --  objects the shell can version and commit: the interface has the
   --  Versioned aspect, or inherits from one that has.

   function Is_Live (Item : Idle.Syntax.Interface_Declaration) return Boolean;
   --  True if the command Item has the Live aspect: the shell passes it
   --  its own caps, not versions of its Versioned arguments, and the
   --  command's changes take effect as it makes them (Rose ADR 0012,
   --  section 3).

   type Stream is (No_Stream, Input_Stream, Output_Stream, Error_Stream);

   type System_Cap is
     (No_System_Cap, Create_Endpoint_Cap, Delete_Cap, Rescind_Cap);
   --  A role member that the generated main passes to
   --  Rose.System_Calls.Use_Capabilities, by its name.

   type Placed_Argument is record
      Argument  : Idle.Syntax.Argument;
      Role      : Unbounded_String;
      --  The role it comes from, or "" for a declared argument.
      Stream    : Commands.Stream := No_Stream;
      System    : System_Cap := No_System_Cap;
      Kind      : Argument_Type := Other_Argument;
      Where     : Place;
      Result    : Place := (Kind => No_Place, others => <>);
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
