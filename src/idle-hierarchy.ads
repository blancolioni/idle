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
      Also_Declared_By : Interface_Vectors.Vector;
      --  The other interfaces of the hierarchy that declare a subprogram
      --  with the same name and signature, which is the same subprogram.
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
   --
   --  A subprogram that more than one of them declares, with the same
   --  name and signature, is one member: it has the place, id and cap of
   --  its first declaration, and the other interfaces that declare it are
   --  in Also_Declared_By.

   --  A parent that cannot be found, or an interface that is its own
   --  ancestor, is reported as an error through Idle.Diagnostics, and is
   --  left out.

   procedure Check_Members (Item : Idle.Syntax.Interface_Declaration);
   --  Report each subprogram name that Item and its ancestors declare
   --  more than once with different signatures. The names of the
   --  subprograms are the names of the client's operations and of the
   --  server's handlers, so they must differ unless the subprograms are
   --  the same.

   procedure Add_Search_Directory (Directory : String);
   --  Look for declarations in Directory as well, after the directory of
   --  the declaration that names them, and in the order the directories
   --  are added.

   function Declaration_File
     (Near : Idle.Syntax.Interface_Declaration;
      Name : String)
      return String;
   --  The file that declares Name, named in a declaration beside Near:
   --  the first file called File_Key (Name) & ".idl" in Near's directory
   --  or a search directory, or the one in Near's directory if there is
   --  none.

   function Find
     (Near  : Idle.Syntax.Interface_Declaration;
      Name  : String;
      Found : out Idle.Syntax.Interface_Declaration)
      return Boolean;
   --  Read the interface Name from Declaration_File (Near, Name). False if
   --  there is no such file, or if it declares another interface; only
   --  errors in parsing the file are reported.

end Idle.Hierarchy;
