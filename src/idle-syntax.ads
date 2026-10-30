with Ada.Containers.Indefinite_Vectors;
with Ada.Containers.Vectors;
with Ada.Strings.Unbounded;

package Idle.Syntax is

   --  The abstract syntax tree of an IDL file. Names are kept as they are
   --  written; Idle.Names turns them into Ada names.

   use Ada.Strings.Unbounded;

   package String_Vectors is
     new Ada.Containers.Indefinite_Vectors (Positive, String);

   type Source_Position is record
      Line   : Natural := 0;
      Column : Natural := 0;
   end record;

   type Parameter_Mode is (In_Mode, Out_Mode, In_Out_Mode);

   type Type_Reference is record
      Name         : Unbounded_String;
      Is_Interface : Boolean := False;
   end record;
   --  A type named in a declaration. Is_Interface is True for
   --  "interface X", a value of the interface X.

   type Parameter is record
      Name     : Unbounded_String;
      Mode     : Parameter_Mode := In_Mode;
      Of_Type  : Type_Reference;
      Position : Source_Position;
   end record;

   package Parameter_Vectors is
     new Ada.Containers.Vectors (Positive, Parameter);

   type Subprogram is record
      Name        : Unbounded_String;
      Is_Function : Boolean := False;
      Parameters  : Parameter_Vectors.Vector;
      Result      : Type_Reference;
      --  The result type of a function.
      Pinned_Id   : Long_Long_Long_Integer := 0;
      --  The id given by an Endpoint_Id aspect, or zero if it has none.
      Position    : Source_Position;
   end record;

   package Subprogram_Vectors is
     new Ada.Containers.Vectors (Positive, Subprogram);

   type Constant_Declaration is record
      Name     : Unbounded_String;
      Value    : Unbounded_String;
      --  An integer literal or a name, as written.
      Position : Source_Position;
   end record;

   package Constant_Vectors is
     new Ada.Containers.Vectors (Positive, Constant_Declaration);

   type Type_Kind is (Range_Type, Derived_Type, Enumeration_Type);

   type Type_Declaration is record
      Name     : Unbounded_String;
      Kind     : Type_Kind := Range_Type;
      Low      : Unbounded_String;
      High     : Unbounded_String;
      --  The bounds of a range type, as written: integer literals or
      --  names of constants.
      Parent   : Type_Reference;
      --  The parent of a derived type.
      Literals : String_Vectors.Vector;
      --  The literals of an enumeration type.
      Position : Source_Position;
   end record;

   package Type_Vectors is
     new Ada.Containers.Vectors (Positive, Type_Declaration);

   type Unit_Kind is (Interface_Unit, Command_Unit, Package_Unit, Role_Unit);
   --  What an IDL file declares.

   type Value_Kind is
     (Integer_Value, Character_Value, String_Value, Name_Value);

   type Aspect_Value is record
      Kind     : Value_Kind := Name_Value;
      Text     : Unbounded_String;
      Position : Source_Position;
   end record;
   --  An aspect's value, or an argument's default. Text is the value as
   --  written, except for a string, which is its contents: without its
   --  quotes, with doubled quotes undoubled, concatenations joined, a text
   --  block's common indentation removed, and a Text_File's contents read.
   --  A character is the character itself.

   type Aspect is record
      Name      : Unbounded_String;
      Value     : Aspect_Value;
      Has_Value : Boolean := True;
      --  False for an aspect given without a value, whose Value is the
      --  name True.
      Position  : Source_Position;
   end record;

   package Aspect_Vectors is
     new Ada.Containers.Vectors (Positive, Aspect);

   type Argument is record
      Name        : Unbounded_String;
      Mode        : Parameter_Mode := In_Mode;
      Of_Type     : Type_Reference;
      Has_Default : Boolean := False;
      Default     : Aspect_Value;
      Aspects     : Aspect_Vectors.Vector;
      Position    : Source_Position;
   end record;
   --  An argument of a command, or a member of a role, which has no mode,
   --  default or aspects, and whose type is always an interface.

   package Argument_Vectors is
     new Ada.Containers.Vectors (Positive, Argument);

   type Interface_Declaration is record
      Kind        : Unit_Kind := Interface_Unit;
      Name        : Unbounded_String;
      File_Name   : Unbounded_String;
      Parents     : String_Vectors.Vector;
      Constants   : Constant_Vectors.Vector;
      Types       : Type_Vectors.Vector;
      Subprograms : Subprogram_Vectors.Vector;
      Aspects     : Aspect_Vectors.Vector;
      Arguments   : Argument_Vectors.Vector;
      Pinned_Id   : Long_Long_Long_Integer := 0;
      --  The id given by an Endpoint_Id aspect, or zero if it has none.
      Versioned   : Boolean := False;
      --  True for an interface with the Versioned aspect, whose objects
      --  the shell can version and commit (Rose ADR 0012). Its
      --  descendants are versioned too: see Idle.Commands.Is_Versioned.
      Position    : Source_Position;
   end record;
   --  The unit an IDL file declares, which despite the name can be any
   --  Kind of unit:
   --
   --    an interface   Parents, Constants, Types and Subprograms
   --    a command      Parents are its roles, Aspects and Arguments
   --    a package      Aspects
   --    a role         Parents are its parent roles, Arguments its members
   --                   and Aspects its Category, if it has one
   --
   --  Name is qualified for a command or a package, such as
   --  Rose.Core.Echo. Each list is in the order it is declared.

end Idle.Syntax;
