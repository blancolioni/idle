with Syn;
with Syn.Factory;

with Idle.Syntax;
with Idle.Targets.Kernel.Support;

private package Idle.Targets.Kernel.Records is

   --  Record types (idle#113), for the user and host targets. A record is
   --  an Ada record type in its interface's package, and a codec, which
   --  the package's body holds:
   --
   --    function Encoded_Length (Item : R) return Storage_Count;
   --    procedure Encode
   --      (Item   : R;
   --       Buffer : in out Storage_Array;
   --       Last   : in out Storage_Offset);
   --    function Encode (Item : R) return Storage_Array;
   --    procedure Decode
   --      (Buffer : Storage_Array;
   --       Last   : in out Storage_Offset;
   --       Item   : out R);
   --    function Decode (Buffer : Storage_Array) return R;
   --
   --  The encoding is fixed by the IDL, not by the compiler, since streams
   --  of records persist across checkpoints. The fields are encoded in the
   --  order they are declared:
   --
   --    a scalar of one word     4 bytes, little-endian
   --    a scalar of two words    8 bytes, little-endian
   --    a string                 its length in 4 bytes, little-endian,
   --                             then its bytes, then zeros up to a
   --                             multiple of 4
   --    a record                 its own encoding
   --
   --  A scalar is encoded as the word an invocation would send it in: an
   --  enumeration as its position, a Boolean as 0 or 1, and a signed
   --  integer in two's complement. A record parameter or result travels
   --  in the invocation buffer as its encoding, and a stream of records
   --  is their encodings one after another.

   Generated_Names : constant Idle.Syntax.String_Vectors.Vector :=
     ["Encode", "Decode", "Encoded_Length", "Padded",
      "Put_Word_32", "Put_Word_64", "Put_String",
      "Get_Word_32", "Get_Word_64", "Get_String",
      "To_Integer_32", "To_Integer_64"];
   --  The names that the package of an interface with records declares,
   --  in its spec or its body, which a type or constant of the interface
   --  can't have.

   function Has_Records
     (Item : Idle.Syntax.Interface_Declaration)
      return Boolean
   is (for some Declared of Item.Types =>
         Idle.Syntax."=" (Declared.Kind, Idle.Syntax.Record_Type));
   --  True if Item declares a record type.

   procedure Check_Fields
     (Declaration : Idle.Syntax.Interface_Declaration;
      Item        : Idle.Syntax.Type_Declaration;
      Declared    : Idle.Syntax.String_Vectors.Vector;
      OK          : in out Boolean);
   --  Report what is wrong with the fields of Item, a record declared by
   --  Declaration: a field named twice, or whose type is unknown, is a cap
   --  or an interface, is an array or a storage offset, or is declared by
   --  Declaration after Item. Declared holds the keys of the types that
   --  Declaration declares before Item. Set OK to False if there is
   --  anything to report.

   function Type_Node
     (F       : in out Syn.Factory.Factory;
      Owner   : Idle.Syntax.Interface_Declaration;
      Item    : Idle.Syntax.Type_Declaration;
      Context : in out Support.Context_List)
      return not null Syn.Node_Access;
   --  The Ada record type for Item, a record of Owner, after adding the
   --  units that its fields' types need to Context.

   function Codec_Declarations
     (F       : in out Syn.Factory.Factory;
      Owner   : Idle.Syntax.Interface_Declaration;
      Context : in out Support.Context_List)
      return Syn.Node_Array;
   --  The codec's subprograms for each record of Owner, in the order they
   --  are declared, after adding System.Storage_Elements to Context.

   procedure Write_Body
     (Owner            : Idle.Syntax.Interface_Declaration;
      Spec_Context     : Support.Context_List;
      Output_Directory : String);
   --  Write the body of the package of Owner, which has records, with the
   --  bodies of their codecs. Spec_Context is the context of the package's
   --  spec, whose units the body doesn't name again.

end Idle.Targets.Kernel.Records;
