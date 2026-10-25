with Idle.Syntax;

package Idle.Endpoints is

   --  Endpoint ids, derived from the IDL source (idle#3). Each id is the
   --  hash of a canonical description of the interface or subprogram,
   --  unless its declaration pins it with an Endpoint_Id aspect (idle#4).
   --
   --  The canonical form is all lower case, with single spaces:
   --
   --    interface rose.interfaces.directory
   --    rose.interfaces.directory.find_entry(in string) return natural
   --    rose.interfaces.cap.destroy
   --
   --  A subprogram is named in the interface that declares it, so an
   --  inherited subprogram has its parent's id. Parameter names are not
   --  part of it. A type is its IDL name if it is predefined, is qualified
   --  by its interface if declared in one, and is "interface <name>" for
   --  an interface type.
   --
   --  The hash is SHA-256, of which the first eight bytes, big-endian,
   --  are the id. A hash of zero, which is not a valid id, becomes one.

   subtype Endpoint_Id is Long_Long_Long_Integer range 0 .. 2 ** 64 - 1;

   function Interface_Form
     (Item : Idle.Syntax.Interface_Declaration)
      return String;
   --  The canonical form of the interface Item.

   function Subprogram_Form
     (Owner : Idle.Syntax.Interface_Declaration;
      Item  : Idle.Syntax.Subprogram)
      return String;
   --  The canonical form of the subprogram Item, declared by Owner.

   function Signature_Form
     (Owner : Idle.Syntax.Interface_Declaration;
      Item  : Idle.Syntax.Subprogram)
      return String;
   --  The canonical form of Item without its qualified name: its
   --  parameters and result. Two subprograms with the same name have the
   --  same signature if these are equal.

   function Hash (Form : String) return Endpoint_Id;
   --  The id derived from the canonical form Form.

   function Interface_Id
     (Item : Idle.Syntax.Interface_Declaration)
      return Endpoint_Id;
   --  The id of the interface Item: its pinned id, or its hash.

   function Subprogram_Id
     (Owner : Idle.Syntax.Interface_Declaration;
      Item  : Idle.Syntax.Subprogram)
      return Endpoint_Id;
   --  The id of the subprogram Item, declared by Owner: its pinned id, or
   --  its hash.

   function Image (Id : Endpoint_Id) return String;
   --  Id as an Ada literal: 16#XXXX_XXXX_XXXX_XXXX#.

end Idle.Endpoints;
