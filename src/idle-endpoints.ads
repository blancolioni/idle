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

   function Type_Form
     (Owner     : Idle.Syntax.Interface_Declaration;
      Reference : Idle.Syntax.Type_Reference)
      return String;
   --  The canonical form of the type named by Reference in a declaration
   --  of Owner.

   function Record_Form
     (Owner : Idle.Syntax.Interface_Declaration;
      Item  : Idle.Syntax.Type_Declaration)
      return String;
   --  The canonical form of the record Item, declared by Owner, as
   --  record rose.interfaces.shelf.file_info. It names the record and not
   --  its fields, so it stays the same as the record gains fields
   --  (idle#114, Rose ADR 0048).

   function Record_Id
     (Owner : Idle.Syntax.Interface_Declaration;
      Item  : Idle.Syntax.Type_Declaration)
      return Endpoint_Id;
   --  The type id of the record Item, declared by Owner: the hash of its
   --  canonical form.

   function Field_Form
     (Owner : Idle.Syntax.Interface_Declaration;
      Item  : Idle.Syntax.Type_Declaration;
      Index : Positive)
      return String;
   --  The field Index of the record Item, declared by Owner, as a line of
   --  idle --list-fields:
   --
   --    rose.interfaces.shelf.file_info 2 size rose.interfaces.units.bytes
   --      := 0
   --
   --  on one line: the record, the field's position and name, its type's
   --  canonical form, and its default, if it has one. A field whose
   --  record has a default for each of its fields has ":= <>". Rose keeps
   --  these lines, and within a series a record only gains them at its
   --  end, each with a default.

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
