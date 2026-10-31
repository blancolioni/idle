with Ada.Strings.Unbounded;

with Syn;
with Syn.Factory;

with Idle.Syntax;

private package Idle.Targets.Kernel.Types is

   --  How the kernel target passes each IDL type: its Ada type, the unit
   --  that declares it, and how it is encoded in an invocation record.
   --  The encoding is the one the original IDL compiler used, which the
   --  kernel also uses where it builds or decodes an invocation itself.

   use Ada.Strings.Unbounded;

   type Category is
     (Word_Value,
      --  One data word.
      Double_Word_Value,
      --  Two data words, low word first, with no alignment.
      Capability_Value,
      --  One cap slot.
      Capability_Array_Value,
      --  One cap slot for each element, after every other cap.
      String_Value,
      --  The invocation buffer.
      Storage_Value,
      --  The invocation buffer.
      Interface_Value,
      --  One cap slot, holding the interface cap.
      Unknown);

   type Encoding is
     (Native,
      --  Word, Word_32, Word_64, Natural, Positive: sent as they are.
      Converted,
      --  Range and derived types: converted to Word or Word_64.
      Enumeration,
      --  Sent as its position.
      Boolean_Word,
      --  Sent as 0 or 1; any non-zero word is True.
      Signed,
      --  Integer_32 and Integer_64: two's complement, in one word or two.
      --  Send_Integer_32, Send_Integer_64, Get_Integer_32, Get_Integer_64.
      Object_Id,
      --  Send_Object_Id.
      Storage_Offset,
      --  Send_Storage_Offset.
      Not_A_Word);
      --  Not passed in data words.

   type Type_Info is record
      Category       : Types.Category := Unknown;
      Encoding       : Types.Encoding := Not_A_Word;
      Ada_Name       : Unbounded_String;
      --  The Ada type. For an interface, its client type.
      Unit           : Unbounded_String;
      --  The unit that declares Ada_Name, or "" for Standard.
      Interface_Name : Unbounded_String;
      --  For an interface, its Ada name.
   end record;

   function Resolve
     (Owner     : Idle.Syntax.Interface_Declaration;
      Reference : Idle.Syntax.Type_Reference)
      return Type_Info;
   --  The type named by Reference in a subprogram of Owner. Owner's own
   --  types are found first, then those of its ancestors, and then the
   --  predefined types. Category is Unknown if there is no such type.

   function Words (Info : Type_Info) return Natural
   is (case Info.Category is
          when Word_Value        => 1,
          when Double_Word_Value => 2,
          when others            => 0);
   --  The number of data words a value of Info takes.

   function Is_Buffer (Info : Type_Info) return Boolean
   is (Info.Category in String_Value | Storage_Value);

   function Packs_Buffers
     (Owner : Idle.Syntax.Interface_Declaration;
      Item  : Idle.Syntax.Subprogram)
      return Boolean;
   --  True if Item, a subprogram of Owner, has more than one in argument
   --  that is a string or an array. They travel in the one invocation
   --  buffer as items: each is its length in four bytes, little-endian,
   --  then its bytes, padded to a multiple of four (idle#58).

   function Object_Unit (Info : Type_Info) return String
   is ("Rose.Interfaces." & To_String (Info.Interface_Name))
     with Pre => Info.Category = Interface_Value;
   --  For the user target: the package that declares the object type of
   --  the interface Info.

   function Object_Class (Info : Type_Info) return String
   is (Object_Unit (Info) & "." & To_String (Info.Interface_Name)
       & "_Object'Class")
     with Pre => Info.Category = Interface_Value;
   --  The class-wide object type of the interface Info.

   function Cap_Function (Info : Type_Info) return String
   is (To_String (Info.Interface_Name) & "_Cap")
     with Pre => Info.Category = Interface_Value;
   --  The function of an object that returns its cap for the interface
   --  Info.

   function Uses_Words_Unit (Info : Type_Info) return Boolean
   is (Info.Encoding = Converted);
   --  True if the code that sends a value of Info names Rose.Words.

   function Send
     (Factory : in out Syn.Factory.Factory;
      Info    : Type_Info;
      Params  : String;
      Value   : String)
      return not null Syn.Node_Access
     with Pre => Info.Category in Word_Value | Double_Word_Value;
   --  A statement that sends Value, of type Info, in the record Params.

   function Decode
     (Factory : in out Syn.Factory.Factory;
      Info    : Type_Info;
      Params  : String;
      Index   : Natural)
      return not null Syn.Node_Access
     with Pre => Info.Category in Word_Value | Double_Word_Value;
   --  An expression for the value of type Info at data word Index of the
   --  record Params.

end Idle.Targets.Kernel.Types;
