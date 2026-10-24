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

   type Interface_Declaration is record
      Name        : Unbounded_String;
      File_Name   : Unbounded_String;
      Parents     : String_Vectors.Vector;
      Constants   : Constant_Vectors.Vector;
      Types       : Type_Vectors.Vector;
      Subprograms : Subprogram_Vectors.Vector;
      Position    : Source_Position;
   end record;
   --  Constants, types and subprograms are each in the order they are
   --  declared.

end Idle.Syntax;
