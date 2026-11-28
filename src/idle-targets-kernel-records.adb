with Ada.Strings.Unbounded;

with Syn.Units;

with Idle.Diagnostics;
with Idle.Endpoints;
with Idle.Hierarchy;
with Idle.Names;
with Idle.Targets.Kernel.Types;

package body Idle.Targets.Kernel.Records is

   use Ada.Strings.Unbounded;
   use type Syn.Node_Array;
   use type Syn.Node_Access;
   use Idle.Targets.Kernel.Support;

   Storage      : constant String := "System.Storage_Elements";
   Unbounded    : constant String := "Ada.Strings.Unbounded";
   Text_Type    : constant String := Unbounded & ".Unbounded_String";

   function Package_Name
     (Owner : Idle.Syntax.Interface_Declaration)
      return String
   is ("Rose.Interfaces." & Idle.Names.Ada_Name (To_String (Owner.Name)));

   function Field_Info
     (Owner : Idle.Syntax.Interface_Declaration;
      Item  : Idle.Syntax.Field)
      return Types.Type_Info
   is (Types.Resolve (Owner, Item.Of_Type, User => True));

   function Field_Name (Item : Idle.Syntax.Field) return String
   is ("Item." & Idle.Names.Ada_Name (To_String (Item.Name)));
   --  The field Item of the record Item, in a codec subprogram.

   function Local_Name
     (Owner : Idle.Syntax.Interface_Declaration;
      Name  : String)
      return String;
   --  Name, the full name of an entity, without the package of Owner if
   --  that is where it is declared.

   function Codec_Name
     (Owner : Idle.Syntax.Interface_Declaration;
      Info  : Types.Type_Info;
      Name  : String)
      return String
   is (Local_Name (Owner, To_String (Info.Unit) & "." & Name));
   --  The codec subprogram Name of the record Info, as Owner's package
   --  body names it.

   type Codec_Specs is record
      Length          : Syn.Node_Access;
      Encode_Into     : Syn.Node_Access;
      Encode_Function : Syn.Node_Access;
      Decode_From     : Syn.Node_Access;
      Decode_Function : Syn.Node_Access;
   end record;
   --  The specifications of the codec of one record.

   function Specs
     (F           : in out Syn.Factory.Factory;
      Record_Name : String)
      return Codec_Specs;
   --  The specifications of the codec of the record Record_Name.

   type Helper_Use is record
      Word_32    : Boolean := False;
      Word_64    : Boolean := False;
      Strings    : Boolean := False;
      Integer_32 : Boolean := False;
      Integer_64 : Boolean := False;
   end record;
   --  Which helpers the codecs of a package call, so that the body has
   --  none that it doesn't, which would be warnings.

   function Helpers_Used
     (Owner : Idle.Syntax.Interface_Declaration)
      return Helper_Use;

   ------------------
   -- Check_Fields --
   ------------------

   procedure Check_Fields
     (Declaration : Idle.Syntax.Interface_Declaration;
      Item        : Idle.Syntax.Type_Declaration;
      Declared    : Idle.Syntax.String_Vectors.Vector;
      OK          : in out Boolean)
   is
      use all type Types.Category;
      use all type Types.Encoding;

      Names : Idle.Syntax.String_Vectors.Vector;

      procedure Error
        (Position : Idle.Syntax.Source_Position;
         Message  : String);

      -----------
      -- Error --
      -----------

      procedure Error
        (Position : Idle.Syntax.Source_Position;
         Message  : String)
      is
      begin
         Idle.Diagnostics.Error
           (To_String (Declaration.File_Name), Position.Line,
            Position.Column, Message);
         OK := False;
      end Error;

   begin
      for Field of Item.Fields loop
         declare
            Name      : constant String := To_String (Field.Name);
            Type_Name : constant String :=
              Idle.Names.Versioned
                (To_String (Field.Of_Type.Name), Field.Of_Type.Version);
            Key       : constant String :=
              Idle.Names.Key (To_String (Field.Of_Type.Name));
            Info      : constant Types.Type_Info :=
              Field_Info (Declaration, Field);
            Declaring : Idle.Syntax.Interface_Declaration;
            Found     : Idle.Syntax.Type_Declaration;

            function Later
              (Left, Right : Idle.Syntax.Source_Position)
               return Boolean
            is (Left.Line > Right.Line
                or else (Left.Line = Right.Line
                         and then Left.Column >= Right.Column));
         begin
            if Names.Contains (Idle.Names.Key (Name)) then
               Error (Field.Position,
                      "field " & Name & " is declared twice");
            end if;
            Names.Append (Idle.Names.Key (Name));

            if Key = Idle.Names.Key (To_String (Item.Name))
              and then Field.Of_Type.Version in 0 | Item.Version
            then
               Error (Field.Position,
                      "record " & To_String (Item.Name)
                      & " cannot hold itself");
            elsif ((for some Other of Declaration.Types =>
                      Idle.Names.Key (To_String (Other.Name)) = Key)
                   and then not Declared.Contains (Key))
              or else
                (Idle.Hierarchy.Find_Type
                   (Declaration, To_String (Field.Of_Type.Name), Declaring,
                    Found, Field.Of_Type.Version)
                 and then Idle.Names.Key (To_String (Declaring.Name))
                            = Idle.Names.Key (To_String (Declaration.Name))
                 and then Later (Found.Position, Item.Position))
            then
               Error (Field.Position,
                      "type " & Type_Name & " is used by record "
                      & To_String (Item.Name) & " before it is declared");
            else
               case Info.Category is
                  when Unknown =>
                     Error (Field.Position, "unknown type " & Type_Name);
                  when Capability_Value | Interface_Value =>
                     Error (Field.Position,
                            "field " & Name & " is a capability or an "
                            & "interface, which a record cannot hold");
                  when Storage_Value =>
                     Error (Field.Position,
                            "field " & Name & " is an array, which a "
                            & "record cannot hold");
                  when Word_Value | Double_Word_Value =>
                     if Info.Encoding = Storage_Offset then
                        Error (Field.Position,
                               "field " & Name & " is a storage offset or "
                               & "count, which a record cannot hold yet");
                     end if;
                  when String_Value | Record_Value =>
                     null;
               end case;
            end if;
         end;
      end loop;
   end Check_Fields;

   ------------------------
   -- Codec_Declarations --
   ------------------------

   function Codec_Declarations
     (F       : in out Syn.Factory.Factory;
      Owner   : Idle.Syntax.Interface_Declaration;
      Context : in out Support.Context_List)
      return Syn.Node_Array
   is
      Result : Node_List;
   begin
      Context.Add (Storage);
      for Item of Owner.Types loop
         if Idle.Syntax."=" (Item.Kind, Idle.Syntax.Record_Type) then
            declare
               Codec : constant Codec_Specs :=
                 Specs (F, Types.Ada_Type_Name (Owner, Item));
            begin
               --  Its type id, which a typed stream gives for its
               --  elements (idle#114).
               Result.Append
                 (F.New_Object
                    (Name          =>
                       Types.Ada_Type_Name (Owner, Item) & "_Type_Id",
                     Object_Type   => F.New_Name ("Rose.Objects.Endpoint_Id"),
                     Initial_Value =>
                       F.New_Integer_Literal
                         (Idle.Endpoints.Record_Id (Owner, Item),
                          Base => 16, Group => 4),
                     Is_Constant   => True));
               Result.Append (Codec.Length);
               Result.Append (Codec.Encode_Into);
               Result.Append (Codec.Encode_Function);
               Result.Append (Codec.Decode_From);
               Result.Append (Codec.Decode_Function);
            end;
         end if;
      end loop;
      return Result.To_Array;
   end Codec_Declarations;

   ------------------
   -- Helpers_Used --
   ------------------

   function Helpers_Used
     (Owner : Idle.Syntax.Interface_Declaration)
      return Helper_Use
   is
      use all type Types.Category;
      use all type Types.Encoding;
      Result : Helper_Use;
   begin
      for Item of Owner.Types loop
         if Idle.Syntax."=" (Item.Kind, Idle.Syntax.Record_Type) then
            for Field of Item.Fields loop
               declare
                  Info : constant Types.Type_Info := Field_Info (Owner, Field);
               begin
                  case Info.Category is
                     when Word_Value =>
                        Result.Word_32 := True;
                        if Info.Encoding = Signed then
                           Result.Integer_32 := True;
                        end if;
                     when Double_Word_Value =>
                        Result.Word_64 := True;
                        if Info.Encoding = Signed then
                           Result.Integer_64 := True;
                        end if;
                     when String_Value =>
                        Result.Strings := True;
                     when others =>
                        null;
                  end case;
               end;
            end loop;
         end if;
      end loop;

      --  A string's length is a word, and a double word is two.
      Result.Word_32 :=
        Result.Word_32 or else Result.Word_64 or else Result.Strings;
      return Result;
   end Helpers_Used;

   ----------------
   -- Local_Name --
   ----------------

   function Local_Name
     (Owner : Idle.Syntax.Interface_Declaration;
      Name  : String)
      return String
   is
      Prefix : constant String := Package_Name (Owner) & ".";
   begin
      if Name'Length > Prefix'Length
        and then Name (Name'First .. Name'First + Prefix'Length - 1) = Prefix
      then
         return Name (Name'First + Prefix'Length .. Name'Last);
      else
         return Name;
      end if;
   end Local_Name;

   -----------
   -- Specs --
   -----------

   function Specs
     (F           : in out Syn.Factory.Factory;
      Record_Name : String)
      return Codec_Specs
   is
      Array_Type  : constant String := Storage & ".Storage_Array";
      Offset_Type : constant String := Storage & ".Storage_Offset";

      function Item_Parameter
        (Mode : Syn.Parameter_Mode := Syn.In_Mode)
         return not null Syn.Node_Access
      is (F.New_Parameter ("Item", F.New_Name (Record_Name), Mode));

      function Buffer_Parameter
        (Mode : Syn.Parameter_Mode := Syn.In_Mode)
         return not null Syn.Node_Access
      is (F.New_Parameter ("Buffer", F.New_Name (Array_Type), Mode));

      function Last_Parameter return not null Syn.Node_Access
      is (F.New_Parameter
            ("Last", F.New_Name (Offset_Type), Syn.In_Out_Mode));

   begin
      return (Length          =>
                F.New_Function
                  ("Encoded_Length", F.New_Name (Storage & ".Storage_Count"),
                   [Item_Parameter]),
              Encode_Into     =>
                F.New_Procedure
                  ("Encode",
                   [Item_Parameter, Buffer_Parameter (Syn.In_Out_Mode),
                    Last_Parameter]),
              Encode_Function =>
                F.New_Function
                  ("Encode", F.New_Name (Array_Type), [Item_Parameter]),
              Decode_From     =>
                F.New_Procedure
                  ("Decode",
                   [Buffer_Parameter, Last_Parameter,
                    Item_Parameter (Syn.Out_Mode)]),
              Decode_Function =>
                F.New_Function
                  ("Decode", F.New_Name (Record_Name), [Buffer_Parameter]));
   end Specs;

   ---------------
   -- Type_Node --
   ---------------

   function Type_Node
     (F       : in out Syn.Factory.Factory;
      Owner   : Idle.Syntax.Interface_Declaration;
      Item    : Idle.Syntax.Type_Declaration;
      Context : in out Support.Context_List)
      return not null Syn.Node_Access
   is
      Components : Node_List;
   begin
      for Field of Item.Fields loop
         declare
            Info : constant Types.Type_Info := Field_Info (Owner, Field);
            Unit : constant String := To_String (Info.Unit);
         begin
            if Types."=" (Info.Category, Types.String_Value) then
               Context.Add (Unbounded);
               Components.Append
                 (F.New_Component
                    (Idle.Names.Ada_Name (To_String (Field.Name)),
                     F.New_Name (Text_Type)));
            else
               if Unit /= "" and then Unit /= Package_Name (Owner) then
                  Context.Add (Unit);
               end if;
               Components.Append
                 (F.New_Component
                    (Idle.Names.Ada_Name (To_String (Field.Name)),
                     F.New_Name
                       (Local_Name (Owner, To_String (Info.Ada_Name)))));
            end if;
         end;
      end loop;
      return F.New_Record_Type
        (Types.Ada_Type_Name (Owner, Item), Components.To_Array);
   end Type_Node;

   ----------------
   -- Write_Body --
   ----------------

   procedure Write_Body
     (Owner            : Idle.Syntax.Interface_Declaration;
      Spec_Context     : Support.Context_List;
      Output_Directory : String)
   is
      use all type Types.Category;
      use all type Types.Encoding;

      F       : Syn.Factory.Factory;
      Used    : constant Helper_Use := Helpers_Used (Owner);
      Context : Context_List;
      Helpers : Node_List;
      --  The specifications of the helpers.
      Bodies  : Body_List;
      Count   : Natural := 0;
      --  For a key that keeps the bodies of overloaded subprograms apart.

      function Literal (Value : Long_Long_Long_Integer)
        return not null Syn.Node_Access
      is (F.New_Integer_Literal (Value));

      function Name (Text : String) return not null Syn.Node_Access
      is (F.New_Name (Text));

      function Call
        (Prefix    : String;
         Arguments : Syn.Node_Array)
         return not null Syn.Node_Access
      is (F.New_Call (Prefix, Arguments));

      function Statement
        (Prefix    : String;
         Arguments : Syn.Node_Array)
         return not null Syn.Node_Access
      is (F.New_Call_Statement (F.New_Call (Prefix, Arguments)));

      function Buffer_Last return Syn.Node_Array
      is ([Name ("Buffer"), Name ("Last")]);

      function Next (Offset : Long_Long_Long_Integer)
        return not null Syn.Node_Access
      is (F.New_Binary (Name ("Last"), "+", Literal (Offset)));
      --  Last + Offset.

      function Advance (Offset : not null Syn.Node_Access)
        return not null Syn.Node_Access
      is (F.New_Assignment
            (Name ("Last"), F.New_Binary (Name ("Last"), "+", Offset)));

      procedure Add_Body
        (Key  : String;
         Item : not null Syn.Node_Access);
      --  Add Item, a body of a subprogram named Key.

      procedure Add_Helper
        (Specification : not null Syn.Node_Access;
         Key           : String;
         Declarations  : Syn.Node_Array := Syn.No_Nodes;
         Statements    : Syn.Node_Array);
      --  Declare a helper at the start of the body, and add its body.

      procedure Add_Helpers;
      procedure Add_Codec (Item : Idle.Syntax.Type_Declaration);

      --------------
      -- Add_Body --
      --------------

      procedure Add_Body
        (Key  : String;
         Item : not null Syn.Node_Access)
      is
         Image : constant String := Natural'Image (Count + 1000);
      begin
         --  A space sorts before any character of a name, so overloads
         --  stay together, in the place their name puts them.
         Count := Count + 1;
         Bodies.Add (Key & " " & Image (Image'First + 1 .. Image'Last),
                     Item);
      end Add_Body;

      -------------------
      -- Add_Codec --
      -------------------

      procedure Add_Codec (Item : Idle.Syntax.Type_Declaration) is
         Record_Name : constant String := Types.Ada_Type_Name (Owner, Item);
         Codec       : constant Codec_Specs := Specs (F, Record_Name);
         Encodes     : Node_List;
         Decodes     : Node_List;
         Fixed       : Long_Long_Long_Integer := 0;
         --  The length of the fields whose length is fixed.
         Varying     : Node_List;
         --  The lengths of the others.
      begin
         for Field of Item.Fields loop
            declare
               Info  : constant Types.Type_Info := Field_Info (Owner, Field);
               Value : constant not null Syn.Node_Access :=
                 Name (Field_Name (Field));
               Ada_Type : constant String :=
                 Local_Name (Owner, To_String (Info.Ada_Name));
            begin
               case Info.Category is
                  when Word_Value | Double_Word_Value =>
                     declare
                        Is_32    : constant Boolean :=
                          Types."=" (Info.Category, Word_Value);
                        Unsigned : constant String :=
                          (if Is_32 then "Unsigned_32" else "Unsigned_64");
                        Size     : constant String :=
                          (if Is_32 then "32" else "64");
                        Word     : constant not null Syn.Node_Access :=
                          (case Info.Encoding is
                              when Enumeration  =>
                                Call (Unsigned,
                                      [Call (Ada_Type & "'Pos", [Value])]),
                              when Boolean_Word =>
                                Call (Unsigned,
                                      [Call ("Boolean'Pos", [Value])]),
                              when Signed       =>
                                Call (Unsigned & "'Mod", [Value]),
                              when others       =>
                                Call (Unsigned, [Value]));
                        Got      : constant not null Syn.Node_Access :=
                          Call ("Get_Word_" & Size, Buffer_Last);
                     begin
                        Fixed := Fixed + (if Is_32 then 4 else 8);
                        Encodes.Append
                          (Statement ("Put_Word_" & Size,
                                      Buffer_Last & [Word]));
                        Decodes.Append
                          (F.New_Assignment
                             (Value,
                              (case Info.Encoding is
                                  when Enumeration  =>
                                    Call (Ada_Type & "'Val", [Got]),
                                  when Boolean_Word =>
                                    F.New_Binary (Got, "/=", Literal (0)),
                                  when Signed       =>
                                    Call ("To_Integer_" & Size, [Got]),
                                  when others       =>
                                    Call (Ada_Type, [Got]))));
                     end;

                  when String_Value =>
                     Fixed := Fixed + 4;
                     Varying.Append
                       (Call ("Padded",
                              [Call (Storage & ".Storage_Count",
                                     [Call (Unbounded & ".Length",
                                            [Value])])]));
                     Encodes.Append
                       (Statement ("Put_String",
                                   Buffer_Last
                                   & [Call (Unbounded & ".To_String",
                                            [Value])]));
                     Decodes.Append
                       (F.New_Assignment
                          (Value,
                           Call (Unbounded & ".To_Unbounded_String",
                                 [Call ("Get_String", Buffer_Last)])));

                  when Record_Value =>
                     Varying.Append
                       (Call (Codec_Name (Owner, Info, "Encoded_Length"),
                              [Value]));
                     Encodes.Append
                       (Statement (Codec_Name (Owner, Info, "Encode"),
                                   [Value] & Buffer_Last));
                     Decodes.Append
                       (Statement (Codec_Name (Owner, Info, "Decode"),
                                   Buffer_Last & [Value]));

                  when others =>
                     raise Program_Error;
               end case;
            end;
         end loop;

         declare
            Length : Syn.Node_Access := null;
         begin
            if Fixed > 0 then
               Length := Literal (Fixed);
            end if;
            for Term of Varying.To_Array loop
               Length :=
                 (if Length = null then Term
                  else F.New_Binary (Length, "+", Term));
            end loop;

            Add_Body
              ("Encoded_Length",
               F.New_Subprogram_Body
                 (Specification => Codec.Length,
                  Declarations  =>
                    (if Varying.To_Array'Length = 0
                     then [F.New_Raw ("pragma Unreferenced (Item);")]
                     else Syn.No_Nodes),
                  Statements    => [F.New_Return (Length)]));
         end;

         Add_Body
           ("Encode",
            F.New_Subprogram_Body
              (Specification => Codec.Encode_Into,
               Statements    => Encodes.To_Array));

         Add_Body
           ("Encode",
            F.New_Subprogram_Body
              (Specification => Codec.Encode_Function,
               Declarations  =>
                 [F.New_Object
                    ("Result",
                     Call ("Storage_Array",
                           [F.New_Binary
                              (Literal (1), "..",
                               Call ("Encoded_Length", [Name ("Item")]))])),
                  F.New_Object
                    ("Last", Name ("Storage_Offset"), Literal (0))],
               Statements    =>
                 [Statement ("Encode",
                             [Name ("Item"), Name ("Result"),
                              Name ("Last")]),
                  F.New_Return (Name ("Result"))]));

         Add_Body
           ("Decode",
            F.New_Subprogram_Body
              (Specification => Codec.Decode_From,
               Statements    => Decodes.To_Array));

         Add_Body
           ("Decode",
            F.New_Subprogram_Body
              (Specification => Codec.Decode_Function,
               Declarations  =>
                 [F.New_Object
                    ("Last", Name ("Storage_Offset"),
                     F.New_Binary
                       (F.New_Attribute (Name ("Buffer"), "First"), "-",
                        Literal (1))),
                  F.New_Object ("Result", Name (Record_Name))],
               Statements    =>
                 [Statement ("Decode",
                             Buffer_Last & [Name ("Result")]),
                  F.New_Return (Name ("Result"))]));
      end Add_Codec;

      ----------------
      -- Add_Helper --
      ----------------

      procedure Add_Helper
        (Specification : not null Syn.Node_Access;
         Key           : String;
         Declarations  : Syn.Node_Array := Syn.No_Nodes;
         Statements    : Syn.Node_Array)
      is
      begin
         Helpers.Append (Specification);
         Add_Body
           (Key,
            F.New_Subprogram_Body
              (Specification => Specification,
               Declarations  => Declarations,
               Statements    => Statements));
      end Add_Helper;

      -----------------
      -- Add_Helpers --
      -----------------

      procedure Add_Helpers is

         function Buffer_Parameters
           (Writable : Boolean)
            return Syn.Node_Array
         is ([F.New_Parameter
                ("Buffer", Name ("Storage_Array"),
                 (if Writable then Syn.In_Out_Mode else Syn.In_Mode)),
              F.New_Parameter
                ("Last", Name ("Storage_Offset"), Syn.In_Out_Mode)]);

         function Byte
           (Value : not null Syn.Node_Access)
            return not null Syn.Node_Access
         is (Call ("Storage_Element", [Value]));

         function Element (Offset : Long_Long_Long_Integer)
           return not null Syn.Node_Access
         is (F.New_Call (Name ("Buffer"), [Next (Offset)]));
         --  Buffer (Last + Offset).

         function Shifted
           (Shift     : String;
            Value     : not null Syn.Node_Access;
            Amount    : Long_Long_Long_Integer)
            return not null Syn.Node_Access
         is (Call (Shift, [Value, Literal (Amount)]));

      begin
         if Used.Word_32 then
            Add_Helper
              (F.New_Procedure
                 ("Put_Word_32",
                  Buffer_Parameters (Writable => True)
                  & [F.New_Parameter ("Value", Name ("Unsigned_32"))]),
               "Put_Word_32",
               Statements =>
                 [F.New_Assignment
                    (Element (1),
                     Byte (F.New_Binary
                             (Name ("Value"), "and",
                              F.New_Integer_Literal (16#FF#, Base => 16)))),
                  F.New_Assignment
                    (Element (2),
                     Byte (F.New_Binary
                             (Shifted ("Shift_Right", Name ("Value"), 8),
                              "and",
                              F.New_Integer_Literal (16#FF#, Base => 16)))),
                  F.New_Assignment
                    (Element (3),
                     Byte (F.New_Binary
                             (Shifted ("Shift_Right", Name ("Value"), 16),
                              "and",
                              F.New_Integer_Literal (16#FF#, Base => 16)))),
                  F.New_Assignment
                    (Element (4),
                     Byte (Shifted ("Shift_Right", Name ("Value"), 24))),
                  Advance (Literal (4))]);

            Add_Helper
              (F.New_Function
                 ("Get_Word_32", Name ("Unsigned_32"),
                  Buffer_Parameters (Writable => False)),
               "Get_Word_32",
               Declarations =>
                 [F.New_Object
                    ("Result", Name ("Unsigned_32"),
                     F.New_Binary
                       (F.New_Binary
                          (F.New_Binary
                             (Call ("Unsigned_32", [Element (1)]),
                              "or",
                              Shifted ("Shift_Left",
                                       Call ("Unsigned_32", [Element (2)]),
                                       8)),
                           "or",
                           Shifted ("Shift_Left",
                                    Call ("Unsigned_32", [Element (3)]),
                                    16)),
                        "or",
                        Shifted ("Shift_Left",
                                 Call ("Unsigned_32", [Element (4)]),
                                 24)),
                     Is_Constant => True)],
               Statements   =>
                 [Advance (Literal (4)),
                  F.New_Return (Name ("Result"))]);
         end if;

         if Used.Word_64 then
            Add_Helper
              (F.New_Procedure
                 ("Put_Word_64",
                  Buffer_Parameters (Writable => True)
                  & [F.New_Parameter ("Value", Name ("Unsigned_64"))]),
               "Put_Word_64",
               Statements =>
                 [Statement
                    ("Put_Word_32",
                     Buffer_Last
                     & [Call ("Unsigned_32",
                              [F.New_Binary
                                 (Name ("Value"), "and",
                                  F.New_Integer_Literal
                                    (16#FFFF_FFFF#, Base => 16,
                                     Group => 4))])]),
                  Statement
                    ("Put_Word_32",
                     Buffer_Last
                     & [Call ("Unsigned_32",
                              [Shifted ("Shift_Right", Name ("Value"),
                                        32)])])]);

            Add_Helper
              (F.New_Function
                 ("Get_Word_64", Name ("Unsigned_64"),
                  Buffer_Parameters (Writable => False)),
               "Get_Word_64",
               Declarations =>
                 [F.New_Object
                    ("Low", Name ("Unsigned_64"),
                     Call ("Unsigned_64",
                           [Call ("Get_Word_32", Buffer_Last)]),
                     Is_Constant => True),
                  F.New_Object
                    ("High", Name ("Unsigned_64"),
                     Call ("Unsigned_64",
                           [Call ("Get_Word_32", Buffer_Last)]),
                     Is_Constant => True)],
               Statements   =>
                 [F.New_Return
                    (F.New_Binary
                       (Name ("Low"), "or",
                        Shifted ("Shift_Left", Name ("High"), 32)))]);
         end if;

         if Used.Strings then
            Add_Helper
              (F.New_Function
                 ("Padded", Name ("Storage_Count"),
                  [F.New_Parameter ("Length", Name ("Storage_Count"))]),
               "Padded",
               Statements =>
                 [F.New_Return
                    (F.New_Binary
                       (F.New_Binary
                          (F.New_Binary (Name ("Length"), "+", Literal (3)),
                           "/", Literal (4)),
                        "*", Literal (4)))]);

            Add_Helper
              (F.New_Procedure
                 ("Put_String",
                  Buffer_Parameters (Writable => True)
                  & [F.New_Parameter ("Value", Name ("String"))]),
               "Put_String",
               Declarations =>
                 [F.New_Object
                    ("Length", Name ("Storage_Count"),
                     Call ("Storage_Count",
                           [F.New_Attribute (Name ("Value"), "Length")]),
                     Is_Constant => True),
                  F.New_Object
                    ("Padding", Name ("Storage_Count"),
                     F.New_Binary
                       (Call ("Padded", [Name ("Length")]), "-",
                        Name ("Length")),
                     Is_Constant => True)],
               Statements   =>
                 --  The padding is zeros by a loop, not an aggregate,
                 --  whose syntax differs between Ada 2012 and 2022.
                 [Statement
                    ("Put_Word_32",
                     Buffer_Last
                     & [Call ("Unsigned_32", [Name ("Length")])]),
                  F.New_For_Of_Loop
                    ("Ch", Name ("Value"),
                     [Advance (Literal (1)),
                      F.New_Assignment
                        (F.New_Call (Name ("Buffer"), [Name ("Last")]),
                         Call ("Character'Pos", [Name ("Ch")]))]),
                  F.New_For_Of_Loop
                    ("Element",
                     F.New_Call
                       (Name ("Buffer"),
                        [F.New_Binary
                           (Next (1), "..",
                            F.New_Binary
                              (Name ("Last"), "+", Name ("Padding")))]),
                     [F.New_Assignment (Name ("Element"), Literal (0))]),
                  Advance (Name ("Padding"))]);

            Add_Helper
              (F.New_Function
                 ("Get_String", Name ("String"),
                  Buffer_Parameters (Writable => False)),
               "Get_String",
               Declarations =>
                 [F.New_Object
                    ("Length", Name ("Storage_Count"),
                     Call ("Storage_Count",
                           [Call ("Get_Word_32", Buffer_Last)]),
                     Is_Constant => True),
                  F.New_Object
                    ("Bytes", Name ("Storage_Array"),
                     F.New_Call
                       (Name ("Buffer"),
                        [F.New_Binary
                           (Next (1), "..",
                            F.New_Binary
                              (Name ("Last"), "+", Name ("Length")))]),
                     Is_Constant => True),
                  F.New_Object
                    ("Result",
                     Call ("String",
                           [F.New_Binary
                              (Literal (1), "..",
                               Call ("Natural", [Name ("Length")]))])),
                  F.New_Object ("Index", Name ("Natural"), Literal (0))],
               Statements   =>
                 [F.New_For_Of_Loop
                    ("Element", Name ("Bytes"),
                     [F.New_Assignment
                        (Name ("Index"),
                         F.New_Binary (Name ("Index"), "+", Literal (1))),
                      F.New_Assignment
                        (F.New_Call (Name ("Result"), [Name ("Index")]),
                         Call ("Character'Val", [Name ("Element")]))]),
                  Advance (Call ("Padded", [Name ("Length")])),
                  F.New_Return (Name ("Result"))]);
         end if;

         --  A signed value is decoded from its two's complement without
         --  overflow: a negative one is the complement of its magnitude
         --  less one.

         for Size in 1 .. 2 loop
            if (Size = 1 and then Used.Integer_32)
              or else (Size = 2 and then Used.Integer_64)
            then
               declare
                  Bits     : constant String :=
                    (if Size = 1 then "32" else "64");
                  Signed   : constant String := "Integer_" & Bits;
                  Unsigned : constant String := "Unsigned_" & Bits;
                  Top      : constant Long_Long_Long_Integer :=
                    (if Size = 1 then 2 ** 31 - 1 else 2 ** 63 - 1);
               begin
                  Add_Helper
                    (F.New_Function
                       ("To_Integer_" & Bits, Name (Signed),
                        [F.New_Parameter ("Value", Name (Unsigned))]),
                     "To_Integer_" & Bits,
                     Statements =>
                       [F.New_If
                          (Condition =>
                             F.New_Binary
                               (Name ("Value"), "<=",
                                F.New_Integer_Literal
                                  (Top, Base => 16, Group => 4)),
                           Then_Part =>
                             [F.New_Return (Call (Signed, [Name ("Value")]))],
                           Else_Part =>
                             [F.New_Return
                                (F.New_Binary
                                   (F.New_Unary
                                      ("-",
                                       Call (Signed,
                                             [F.New_Unary
                                                ("not", Name ("Value"))])),
                                    "-", Literal (1)))])]);
               end;
            end if;
         end loop;
      end Add_Helpers;

      Uses : Node_List;

   begin
      if Used.Word_32 then
         if not Spec_Context.Contains ("Interfaces") then
            Context.Add ("Interfaces");
         end if;
         Uses.Append (F.New_Use ("Standard.Interfaces"));
      end if;
      Uses.Append (F.New_Use (Storage));

      Add_Helpers;
      for Item of Owner.Types loop
         if Idle.Syntax."=" (Item.Kind, Idle.Syntax.Record_Type) then
            Add_Codec (Item);
         end if;
      end loop;

      Syn.Units.Write
        (F.New_Compilation_Unit
           (Context => Context.To_Array (F),
            Item    =>
              F.New_Package_Body
                (Name         => Package_Name (Owner),
                 Declarations =>
                   Uses.To_Array & Helpers.To_Array & Bodies.To_Array)),
         Output_Directory);
   end Write_Body;

end Idle.Targets.Kernel.Records;
