with Ada.Containers.Vectors;
with Ada.Strings.Unbounded;

with Idle.Syntax;

package Idle.Hierarchy is

   --  The ancestors of an interface, and the subprograms it inherits from
   --  them. A parent named P is read from p.idl, in the directory of the
   --  interface that names it.

   use Ada.Strings.Unbounded;

   package Interface_Vectors is
     new Ada.Containers.Vectors
       (Positive, Idle.Syntax.Interface_Declaration, Idle.Syntax."=");

   type Member is record
      Declared_In : Unbounded_String;
      --  The name of the interface that declares Subprogram.
      File_Name   : Unbounded_String;
      --  The file that declares it.
      Owner       : Idle.Syntax.Interface_Declaration;
      --  The interface that declares it, whose types it can name.
      Subprogram  : Idle.Syntax.Subprogram;
   end record;

   package Member_Vectors is
     new Ada.Containers.Vectors (Positive, Member);

   function Ancestors
     (Item : Idle.Syntax.Interface_Declaration)
      return Interface_Vectors.Vector;
   --  Each ancestor of Item once, depth first: for each parent in the
   --  order Item names it, that parent's ancestors and then the parent.
   --  Item itself is not included. For Process : Segment, Server, Cap,
   --  this is Segment, Server, Cap.

   function Members
     (Item : Idle.Syntax.Interface_Declaration)
      return Member_Vectors.Vector;
   --  The subprograms of each of Ancestors (Item), in that order, and
   --  then those of Item. The position of a subprogram in this list is
   --  the position of its cap in the reply to Item's interface cap.

   --  A parent that cannot be found, or an interface that is its own
   --  ancestor, is reported as an error through Idle.Diagnostics, and is
   --  left out.

   procedure Check_Members (Item : Idle.Syntax.Interface_Declaration);
   --  Report each subprogram name that Item and its ancestors declare
   --  more than once. The names of the subprograms are the names of the
   --  client's operations and of the server's handlers, so they must
   --  differ.

   function Declaration_File
     (Near : Idle.Syntax.Interface_Declaration;
      Name : String)
      return String;
   --  The file that declares the interface Name, for an interface named
   --  in a declaration beside Near: name.idl, in Near's directory.

   function Find
     (Near  : Idle.Syntax.Interface_Declaration;
      Name  : String;
      Found : out Idle.Syntax.Interface_Declaration)
      return Boolean;
   --  Read the interface Name from Declaration_File (Near, Name). False if
   --  there is no such file, or if it declares another interface; only
   --  errors in parsing the file are reported.

end Idle.Hierarchy;
