with Ada.Strings.Fixed;
with Ada.Strings.Unbounded;

with Syn.Units;

with Idle.Diagnostics;
with Idle.Endpoints;
with Idle.Hierarchy;
with Idle.Literals;
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

   function Default_Node
     (F     : in out Syn.Factory.Factory;
      Owner : Idle.Syntax.Interface_Declaration;
      Item  : Idle.Syntax.Field)
      return Syn.Node_Access;
   --  The default of Item, a field of a record of Owner, as an Ada
   --  expression, or null if it has none of its own. Check_Fields has
   --  checked it.

   function Required_Fields
     (Owner : Idle.Syntax.Interface_Declaration;
      Item  : Idle.Syntax.Type_Declaration)
      return Natural;
   --  The position of the last field of Item, a record of Owner, that has
   --  no default: the fewest fields that a decoded record can have.

   procedure Check_Constant
     (Owner     : Idle.Syntax.Interface_Declaration;
      Of_Type   : Idle.Syntax.Type_Reference;
      Value     : Idle.Syntax.Aspect_Value;
      Subject   : String;
      File_Name : Unbounded_String;
      OK        : in out Boolean);
   --  Report Value, a constant given for a field of the type Of_Type, named
   --  in Owner, if it isn't a value of the type, as Subject, such as "the
   --  default of field Size", in File_Name. The type is not a record.

   function Constant_Node
     (F           : in out Syn.Factory.Factory;
      Type_Owner  : Idle.Syntax.Interface_Declaration;
      Of_Type     : Idle.Syntax.Type_Reference;
      Value       : Idle.Syntax.Aspect_Value;
      Local_Owner : Idle.Syntax.Interface_Declaration)
      return not null Syn.Node_Access;
   --  Value, a constant of the type Of_Type named in Type_Owner, as an Ada
   --  expression in the package of Local_Owner. Check_Constant has
   --  checked it.

   function Resolve_Path
     (Owner      : Idle.Syntax.Interface_Declaration;
      Item       : Idle.Syntax.Type_Declaration;
      Path       : String;
      Path_Owner : out Idle.Syntax.Interface_Declaration;
      Field      : out Idle.Syntax.Field)
      return Boolean;
   --  The field that Path names in Item, a record of Owner: a field of
   --  Item, or a path through its fields of record type, as Where.Path.
   --  Path_Owner is the interface that declares the record that has the
   --  field. False if there is no such field.

   function View_Body
     (F         : in out Syn.Factory.Factory;
      Owner     : Idle.Syntax.Interface_Declaration;
      Item      : Idle.Syntax.View_Declaration;
      Uses_Text : in out Boolean)
      return not null Syn.Node_Access;
   --  The body of the function of Item, a view of Owner. Set Uses_Text if
   --  it names Ada.Strings.Unbounded.

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

   --------------------
   -- Check_Constant --
   --------------------

   procedure Check_Constant
     (Owner     : Idle.Syntax.Interface_Declaration;
      Of_Type   : Idle.Syntax.Type_Reference;
      Value     : Idle.Syntax.Aspect_Value;
      Subject   : String;
      File_Name : Unbounded_String;
      OK        : in out Boolean)
   is
      use all type Types.Category;
      use all type Types.Encoding;
      use all type Idle.Syntax.Value_Kind;

      Info      : constant Types.Type_Info :=
        Types.Resolve (Owner, Of_Type, User => True);
      Type_Name : constant String := To_String (Of_Type.Name);
      Text      : constant String := To_String (Value.Text);
      Declaring : Idle.Syntax.Interface_Declaration;
      Found     : Idle.Syntax.Type_Declaration;
      Is_Found  : constant Boolean :=
        Idle.Hierarchy.Find_Type (Owner, Type_Name, Declaring, Found);

      function Bound
        (Text   : Unbounded_String;
         Result : out Long_Long_Long_Integer)
         return Boolean
      is (Idle.Literals.Value (To_String (Text), Result, 2 ** 64 - 1));
      --  The value of a range type's bound, if it is a literal.

      procedure Check_Number;
      --  Check a whole number against Info and Found.

      procedure Error (Message : String);

      ------------------
      -- Check_Number --
      ------------------

      procedure Check_Number is
         Signed  : constant Boolean := Info.Encoding = Types.Signed;
         Largest : constant Long_Long_Long_Integer :=
           (if Info.Category = Word_Value
            then (if Signed then 2 ** 31 - 1 else 2 ** 32 - 1)
            else (if Signed then 2 ** 63 - 1 else 2 ** 64 - 1));
         Number  : Long_Long_Long_Integer;
         Low     : Long_Long_Long_Integer;
         High    : Long_Long_Long_Integer;
      begin
         if Value.Kind /= Integer_Value then
            Error (" must be a whole number");
         elsif not Idle.Literals.Value (Text, Number, Largest) then
            Error (" is too large for " & Type_Name);
         elsif (Is_Found
                and then Idle.Syntax."=" (Found.Kind, Idle.Syntax.Range_Type)
                and then Bound (Found.Low, Low)
                and then Bound (Found.High, High)
                and then Number not in Low .. High)
           or else (Idle.Names.Key (Type_Name) = "positive"
                    and then Number = 0)
         then
            Error (" is outside the range of " & Type_Name);
         end if;
      end Check_Number;

      -----------
      -- Error --
      -----------

      procedure Error (Message : String) is
      begin
         Idle.Diagnostics.Error
           (To_String (File_Name), Value.Position.Line,
            Value.Position.Column, Subject & Message);
         OK := False;
      end Error;

   begin
      case Info.Category is
         when String_Value =>
            if Value.Kind /= String_Value then
               Error (" must be a string");
            end if;
         when Word_Value | Double_Word_Value =>
            case Info.Encoding is
               when Boolean_Word =>
                  if Value.Kind /= Name_Value
                    or else Idle.Names.Key (Text) not in "true" | "false"
                  then
                     Error (" must be True or False");
                  end if;
               when Enumeration =>
                  if Value.Kind /= Name_Value
                    or else not Is_Found
                    or else not (for some Literal of Found.Literals =>
                                   Idle.Names.Key (Literal)
                                   = Idle.Names.Key (Text))
                  then
                     Error (" must be a literal of " & Type_Name);
                  end if;
               when others =>
                  Check_Number;
            end case;
         when others =>
            null;
      end case;
   end Check_Constant;

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

      procedure Check_Default
        (Field : Idle.Syntax.Field;
         Info  : Types.Type_Info);
      --  Report a default of Field, whose type is Info, that isn't a value
      --  of the type.

      procedure Error
        (Position : Idle.Syntax.Source_Position;
         Message  : String);

      -------------------
      -- Check_Default --
      -------------------

      procedure Check_Default
        (Field : Idle.Syntax.Field;
         Info  : Types.Type_Info)
      is
      begin
         if Info.Category = Record_Value then
            Error (Field.Default.Position,
                   "field " & To_String (Field.Name) & " is a record, which "
                   & "takes no default: it has one when each field of "
                   & To_String (Field.Of_Type.Name) & " has one");
         else
            Check_Constant
              (Declaration, Field.Of_Type, Field.Default,
               "the default of field " & To_String (Field.Name),
               Declaration.File_Name, OK);
         end if;
      end Check_Default;

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
      if Natural (Item.Fields.Length) > 255 then
         Error (Item.Position,
                "record " & To_String (Item.Name)
                & " has more than 255 fields");
      end if;

      for Field of Item.Fields loop
         declare
            Name      : constant String := To_String (Field.Name);
            Type_Name : constant String := To_String (Field.Of_Type.Name);
            Key       : constant String := Idle.Names.Key (Type_Name);
            Info      : constant Types.Type_Info :=
              Field_Info (Declaration, Field);
         begin
            if Names.Contains (Idle.Names.Key (Name)) then
               Error (Field.Position,
                      "field " & Name & " is declared twice");
            end if;
            Names.Append (Idle.Names.Key (Name));

            if Key = Idle.Names.Key (To_String (Item.Name)) then
               Error (Field.Position,
                      "record " & To_String (Item.Name)
                      & " cannot hold itself");
            elsif (for some Other of Declaration.Types =>
                  Idle.Names.Key (To_String (Other.Name)) = Key)
              and then not Declared.Contains (Key)
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

               if Field.Has_Default then
                  Check_Default (Field, Info);
               end if;
            end if;
         end;
      end loop;
   end Check_Fields;

   -----------------
   -- Check_Views --
   -----------------

   procedure Check_Views
     (Declaration : Idle.Syntax.Interface_Declaration;
      Is_Kernel   : Boolean;
      OK          : in out Boolean)
   is
      use type Idle.Syntax.Value_Kind;

      Seen : Idle.Syntax.String_Vectors.Vector;
      --  The views checked, by view name, source and target.

      procedure Error
        (Position : Idle.Syntax.Source_Position;
         Message  : String);

      function Find_Record
        (Reference : Idle.Syntax.Type_Reference;
         Owner     : out Idle.Syntax.Interface_Declaration;
         Item      : out Idle.Syntax.Type_Declaration)
         return Boolean
      is (not Reference.Is_Interface
          and then Idle.Hierarchy.Find_Type
                     (Declaration, To_String (Reference.Name), Owner, Item)
          and then Idle.Syntax."=" (Item.Kind, Idle.Syntax.Record_Type));

      function Field_Index
        (Item : Idle.Syntax.Type_Declaration;
         Name : String)
         return Natural;
      --  The position of the field Name of Item, or zero.

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

      -----------------
      -- Field_Index --
      -----------------

      function Field_Index
        (Item : Idle.Syntax.Type_Declaration;
         Name : String)
         return Natural
      is
      begin
         for Index in 1 .. Item.Fields.Last_Index loop
            if Idle.Names.Key (To_String (Item.Fields (Index).Name))
              = Idle.Names.Key (Name)
            then
               return Index;
            end if;
         end loop;
         return 0;
      end Field_Index;

   begin
      for View of Declaration.Views loop
         declare
            S            : constant String := To_String (View.Source.Name);
            T            : constant String := To_String (View.Target.Name);
            Name         : constant String := To_String (View.Name);
            Source_Owner : Idle.Syntax.Interface_Declaration;
            Target_Owner : Idle.Syntax.Interface_Declaration;
            Source       : Idle.Syntax.Type_Declaration;
            Target       : Idle.Syntax.Type_Declaration;
            Given        : Idle.Syntax.String_Vectors.Vector;
         begin
            if Is_Kernel then
               Error (View.Position,
                      "view of " & S & " as " & T & " needs the user or "
                      & "host target: the kernel target has no records");
            elsif not Find_Record (View.Source, Source_Owner, Source) then
               Error (View.Position, "unknown record " & S);
            elsif not Find_Record (View.Target, Target_Owner, Target) then
               Error (View.Position, "unknown record " & T);
            elsif Idle.Endpoints.Record_Form (Source_Owner, Source)
              = Idle.Endpoints.Record_Form (Target_Owner, Target)
            then
               Error (View.Position,
                      "a view of " & S & " as itself: a record needs no "
                      & "view of itself");
            else
               declare
                  Key : constant String :=
                    Idle.Names.Key (Name) & " "
                    & Idle.Endpoints.Record_Form (Source_Owner, Source)
                    & " as "
                    & Idle.Endpoints.Record_Form (Target_Owner, Target);
               begin
                  if Seen.Contains (Key) then
                     Error (View.Position,
                            (if Name = "" then "the view" else "view " & Name)
                            & " of " & S & " as " & T
                            & " is declared twice");
                  end if;
                  Seen.Append (Key);
               end;

               for Field of View.Fields loop
                  declare
                     Field_Name : constant String := To_String (Field.Target);
                     Index      : constant Natural :=
                       Field_Index (Target, Field_Name);
                     Path       : constant String :=
                       To_String (Field.Value.Text);
                     Path_Owner : Idle.Syntax.Interface_Declaration;
                     Path_Field : Idle.Syntax.Field;
                  begin
                     if Index = 0 then
                        Error (Field.Position,
                               "record " & T & " has no field " & Field_Name);
                     elsif Given.Contains (Idle.Names.Key (Field_Name)) then
                        Error (Field.Position,
                               "field " & Field_Name & " is given twice");
                     else
                        Given.Append (Idle.Names.Key (Field_Name));
                        declare
                           Target_Field : constant Idle.Syntax.Field :=
                             Target.Fields (Index);
                           Is_Record    : constant Boolean :=
                             Types."="
                               (Field_Info (Target_Owner, Target_Field)
                                  .Category,
                                Types.Record_Value);
                        begin
                           if Field.Value.Kind = Idle.Syntax.Name_Value
                             and then Resolve_Path
                                        (Source_Owner, Source, Path,
                                         Path_Owner, Path_Field)
                           then
                              if Idle.Endpoints.Type_Form
                                   (Path_Owner, Path_Field.Of_Type)
                                /= Idle.Endpoints.Type_Form
                                     (Target_Owner, Target_Field.Of_Type)
                              then
                                 Error (Field.Value.Position,
                                        "field " & Field_Name & " of " & T
                                        & " is "
                                        & To_String
                                            (Target_Field.Of_Type.Name)
                                        & ", and " & Path & " of " & S
                                        & " is "
                                        & To_String
                                            (Path_Field.Of_Type.Name));
                              end if;
                           elsif Field.Value.Kind = Idle.Syntax.Name_Value
                             and then (Is_Record
                                       or else Ada.Strings.Fixed.Index
                                                 (Path, ".") > 0)
                           then
                              Error (Field.Value.Position,
                                     "record " & S & " has no field "
                                     & Path);
                           elsif Is_Record then
                              Error (Field.Value.Position,
                                     "field " & Field_Name & " of " & T
                                     & " is a record: give it a field of "
                                     & S);
                           else
                              Check_Constant
                                (Target_Owner, Target_Field.Of_Type,
                                 Field.Value,
                                 "the value of field " & Field_Name,
                                 Declaration.File_Name, OK);
                           end if;
                        end;
                     end if;
                  end;
               end loop;

               --  The target's other fields: by name from the source, for
               --  others => <>, or by default.

               for Target_Field of Target.Fields loop
                  declare
                     Field_Name : constant String :=
                       To_String (Target_Field.Name);
                     Index      : constant Natural :=
                       (if View.Others_Box
                        then Field_Index (Source, Field_Name)
                        else 0);
                  begin
                     if Given.Contains (Idle.Names.Key (Field_Name)) then
                        null;
                     elsif Index > 0 then
                        if Idle.Endpoints.Type_Form
                             (Source_Owner, Source.Fields (Index).Of_Type)
                          /= Idle.Endpoints.Type_Form
                               (Target_Owner, Target_Field.Of_Type)
                        then
                           Error (View.Position,
                                  "field " & Field_Name & " of " & T & " is "
                                  & To_String (Target_Field.Of_Type.Name)
                                  & ", and of " & S & " is "
                                  & To_String
                                      (Source.Fields (Index).Of_Type.Name)
                                  & ": give it in the view");
                        end if;
                     elsif not Idle.Hierarchy.Has_Default
                                 (Target_Owner, Target_Field)
                     then
                        Error (View.Position,
                               "field " & Field_Name & " of " & T
                               & (if View.Others_Box
                                  then " has no field of that name in " & S
                                  else " is not given")
                               & ", and has no default");
                     end if;
                  end;
               end loop;
            end if;
         end;
      end loop;
   end Check_Views;

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
               Record_Name : constant String :=
                 Idle.Names.Ada_Name (To_String (Item.Name));
               Codec       : constant Codec_Specs := Specs (F, Record_Name);
            begin
               --  Its type id, for a typed stream to name its elements by
               --  (idle#114).
               Result.Append
                 (F.New_Object
                    (Name          => Record_Name & "_Type_Id",
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

   -------------------
   -- Constant_Node --
   -------------------

   function Constant_Node
     (F           : in out Syn.Factory.Factory;
      Type_Owner  : Idle.Syntax.Interface_Declaration;
      Of_Type     : Idle.Syntax.Type_Reference;
      Value       : Idle.Syntax.Aspect_Value;
      Local_Owner : Idle.Syntax.Interface_Declaration)
      return not null Syn.Node_Access
   is
      Info   : constant Types.Type_Info :=
        Types.Resolve (Type_Owner, Of_Type, User => True);
      Text   : constant String := To_String (Value.Text);
      Number : Long_Long_Long_Integer;
   begin
      case Info.Category is
         when Types.String_Value =>
            return F.New_Call
              (Unbounded & ".To_Unbounded_String",
               [F.New_String_Literal (Text)]);
         when others =>
            case Info.Encoding is
               when Types.Boolean_Word =>
                  return F.New_Name
                    (if Idle.Names.Key (Text) = "true" then "True"
                     else "False");
               when Types.Enumeration =>
                  return F.New_Name
                    (Local_Name
                       (Local_Owner,
                        To_String (Info.Unit) & "."
                        & Idle.Names.Ada_Name (Text)));
               when others =>
                  if not Idle.Literals.Value (Text, Number, 2 ** 64 - 1) then
                     raise Program_Error;
                  end if;
                  return F.New_Integer_Literal (Number);
            end case;
      end case;
   end Constant_Node;

   ------------------
   -- Default_Node --
   ------------------

   function Default_Node
     (F     : in out Syn.Factory.Factory;
      Owner : Idle.Syntax.Interface_Declaration;
      Item  : Idle.Syntax.Field)
      return Syn.Node_Access
   is
   begin
      if not Item.Has_Default then
         return null;
      end if;
      return Constant_Node (F, Owner, Item.Of_Type, Item.Default, Owner);
   end Default_Node;

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

      --  Every record's header is a word (idle#114).
      Result.Word_32 := Has_Records (Owner);
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

   ---------------------
   -- Required_Fields --
   ---------------------

   function Required_Fields
     (Owner : Idle.Syntax.Interface_Declaration;
      Item  : Idle.Syntax.Type_Declaration)
      return Natural
   is
      Result : Natural := 0;
   begin
      for Index in 1 .. Item.Fields.Last_Index loop
         if not Idle.Hierarchy.Has_Default (Owner, Item.Fields (Index)) then
            Result := Index;
         end if;
      end loop;
      return Result;
   end Required_Fields;

   ------------------
   -- Resolve_Path --
   ------------------

   function Resolve_Path
     (Owner      : Idle.Syntax.Interface_Declaration;
      Item       : Idle.Syntax.Type_Declaration;
      Path       : String;
      Path_Owner : out Idle.Syntax.Interface_Declaration;
      Field      : out Idle.Syntax.Field)
      return Boolean
   is
      Dot  : constant Natural := Ada.Strings.Fixed.Index (Path, ".");
      Head : constant String :=
        (if Dot = 0 then Path else Path (Path'First .. Dot - 1));
   begin
      for Candidate of Item.Fields loop
         if Idle.Names.Key (To_String (Candidate.Name))
           = Idle.Names.Key (Head)
         then
            if Dot = 0 then
               Path_Owner := Owner;
               Field := Candidate;
               return True;
            end if;

            declare
               Next_Owner : Idle.Syntax.Interface_Declaration;
               Next       : Idle.Syntax.Type_Declaration;
            begin
               return Idle.Hierarchy.Find_Type
                        (Owner, To_String (Candidate.Of_Type.Name),
                         Next_Owner, Next)
                 and then Idle.Syntax."=" (Next.Kind, Idle.Syntax.Record_Type)
                 and then Resolve_Path
                            (Next_Owner, Next, Path (Dot + 1 .. Path'Last),
                             Path_Owner, Field);
            end;
         end if;
      end loop;
      return False;
   end Resolve_Path;

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
                     F.New_Name (Text_Type),
                     Default_Node (F, Owner, Field)));
            else
               if Unit /= "" and then Unit /= Package_Name (Owner) then
                  Context.Add (Unit);
               end if;
               Components.Append
                 (F.New_Component
                    (Idle.Names.Ada_Name (To_String (Field.Name)),
                     F.New_Name
                       (Local_Name (Owner, To_String (Info.Ada_Name))),
                     Default_Node (F, Owner, Field)));
            end if;
         end;
      end loop;
      return F.New_Record_Type
        (Idle.Names.Ada_Name (To_String (Item.Name)), Components.To_Array);
   end Type_Node;

   ---------------
   -- View_Body --
   ---------------

   function View_Body
     (F         : in out Syn.Factory.Factory;
      Owner     : Idle.Syntax.Interface_Declaration;
      Item      : Idle.Syntax.View_Declaration;
      Uses_Text : in out Boolean)
      return not null Syn.Node_Access
   is
      use type Idle.Syntax.Value_Kind;

      Source_Owner : Idle.Syntax.Interface_Declaration;
      Target_Owner : Idle.Syntax.Interface_Declaration;
      Source       : Idle.Syntax.Type_Declaration;
      Target       : Idle.Syntax.Type_Declaration;
      Target_Info  : constant Types.Type_Info :=
        Types.Resolve (Owner, Item.Target, User => True);
      Assignments  : Node_List;
      Reads_Item   : Boolean := False;

      function Item_Path (Path : String) return String;
      --  Path, a path of fields as written, as an Ada name in Item.

      ---------------
      -- Item_Path --
      ---------------

      function Item_Path (Path : String) return String is
         Result : Unbounded_String := To_Unbounded_String ("Item");
         Start  : Positive := Path'First;
      begin
         for Index in Path'Range loop
            if Path (Index) = '.' then
               Append (Result,
                       "." & Idle.Names.Ada_Name (Path (Start .. Index - 1)));
               Start := Index + 1;
            end if;
         end loop;
         Append (Result,
                 "." & Idle.Names.Ada_Name (Path (Start .. Path'Last)));
         return To_String (Result);
      end Item_Path;

   begin
      if not Idle.Hierarchy.Find_Type
               (Owner, To_String (Item.Source.Name), Source_Owner, Source)
        or else not Idle.Hierarchy.Find_Type
                      (Owner, To_String (Item.Target.Name), Target_Owner,
                       Target)
      then
         raise Program_Error;
      end if;

      for Target_Field of Target.Fields loop
         declare
            Key        : constant String :=
              Idle.Names.Key (To_String (Target_Field.Name));
            Component  : constant String :=
              "Result." & Idle.Names.Ada_Name (To_String (Target_Field.Name));
            Value      : Syn.Node_Access := null;
            Path_Owner : Idle.Syntax.Interface_Declaration;
            Path_Field : Idle.Syntax.Field;
         begin
            for Given of Item.Fields loop
               if Idle.Names.Key (To_String (Given.Target)) = Key then
                  if Given.Value.Kind = Idle.Syntax.Name_Value
                    and then Resolve_Path
                               (Source_Owner, Source,
                                To_String (Given.Value.Text),
                                Path_Owner, Path_Field)
                  then
                     Value :=
                       F.New_Name (Item_Path (To_String (Given.Value.Text)));
                     Reads_Item := True;
                  else
                     Value := Constant_Node
                       (F, Target_Owner, Target_Field.Of_Type, Given.Value,
                        Owner);
                     if Types."="
                          (Field_Info (Target_Owner, Target_Field).Category,
                           Types.String_Value)
                     then
                        Uses_Text := True;
                     end if;
                  end if;
               end if;
            end loop;

            if Value = null
              and then Item.Others_Box
              and then Resolve_Path
                         (Source_Owner, Source,
                          To_String (Target_Field.Name),
                          Path_Owner, Path_Field)
            then
               Value := F.New_Name
                 (Item_Path (To_String (Target_Field.Name)));
               Reads_Item := True;
            end if;

            --  Any other field keeps its default.

            if Value /= null then
               Assignments.Append (F.New_Assignment (F.New_Name (Component),
                                                     Value));
            end if;
         end;
      end loop;

      declare
         Specification : constant not null Syn.Node_Access :=
           F.New_Function
             (View_Function_Name (Item),
              F.New_Name
                (Local_Name (Owner, To_String (Target_Info.Ada_Name))),
              [F.New_Parameter
                 ("Item",
                  F.New_Name
                    (Local_Name
                       (Owner,
                        To_String
                          (Types.Resolve (Owner, Item.Source, User => True)
                             .Ada_Name))))]);
         Unreferenced  : constant Syn.Node_Array :=
           (if Reads_Item then Syn.No_Nodes
            else [F.New_Raw ("pragma Unreferenced (Item);")]);
      begin
         if Assignments.To_Array'Length = 0 then
            return F.New_Subprogram_Body
              (Specification => Specification,
               Declarations  => Unreferenced,
               Statements    => [F.New_Return (F.New_Raw ("(others => <>)"))]);
         else
            return F.New_Subprogram_Body
              (Specification => Specification,
               Declarations  =>
                 Unreferenced
                 & [F.New_Object
                      ("Result",
                       F.New_Name
                         (Local_Name
                            (Owner, To_String (Target_Info.Ada_Name))))],
               Statements    =>
                 Assignments.To_Array
                 & [F.New_Return (F.New_Name ("Result"))]);
         end if;
      end;
   end View_Body;

   -----------------------
   -- View_Declarations --
   -----------------------

   function View_Declarations
     (F       : in out Syn.Factory.Factory;
      Owner   : Idle.Syntax.Interface_Declaration;
      Context : in out Support.Context_List)
      return Syn.Node_Array
   is
      Result : Node_List;
   begin
      for Item of Owner.Views loop
         declare
            Source : constant Types.Type_Info :=
              Types.Resolve (Owner, Item.Source, User => True);
            Target : constant Types.Type_Info :=
              Types.Resolve (Owner, Item.Target, User => True);
         begin
            if To_String (Source.Unit) /= Package_Name (Owner) then
               Context.Add (To_String (Source.Unit));
            end if;
            if To_String (Target.Unit) /= Package_Name (Owner) then
               Context.Add (To_String (Target.Unit));
            end if;
            Result.Append
              (F.New_Function
                 (View_Function_Name (Item),
                  F.New_Name (Local_Name (Owner, To_String (Target.Ada_Name))),
                  [F.New_Parameter
                     ("Item",
                      F.New_Name
                        (Local_Name (Owner, To_String (Source.Ada_Name))))]));
         end;
      end loop;
      return Result.To_Array;
   end View_Declarations;

   ------------------------
   -- View_Function_Name --
   ------------------------

   function View_Function_Name
     (Item : Idle.Syntax.View_Declaration)
      return String
   is
      Name : constant String := To_String (Item.Name);
   begin
      return "To_"
        & Idle.Names.Ada_Name
            (Idle.Names.Simple_Name (To_String (Item.Target.Name)))
        & (if Name = "" then "" else "_" & Idle.Names.Ada_Name (Name));
   end View_Function_Name;

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
         Record_Name : constant String :=
           Idle.Names.Ada_Name (To_String (Item.Name));
         Codec       : constant Codec_Specs := Specs (F, Record_Name);
         Encodes     : Node_List;
         Decodes     : Node_List;
         Fixed       : Long_Long_Long_Integer := 4;
         --  The length of the header and of the fields whose length is
         --  fixed.
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

         --  The header is written last, when the length is known.

         Add_Body
           ("Encode",
            F.New_Subprogram_Body
              (Specification => Codec.Encode_Into,
               Declarations  =>
                 [F.New_Object
                    ("Start", Name ("Storage_Offset"), Name ("Last"),
                     Is_Constant => True)],
               Statements    =>
                 [Advance (Literal (4))]
                 & Encodes.To_Array
                 & [Statement
                      ("Put_Header",
                       [Name ("Buffer"), Name ("Start"), Name ("Last"),
                        Literal
                          (Long_Long_Long_Integer (Item.Fields.Length))])]));

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

         --  A field after the sender's count takes its default, and
         --  fields after the ones this decoder knows are skipped.

         declare
            Fields   : constant Syn.Node_Array := Decodes.To_Array;
            Required : constant Natural := Required_Fields (Owner, Item);
            Bad      : Syn.Node_Access :=
              F.New_Binary
                (F.New_Binary (Name ("Finish"), "<", Name ("Last")),
                 "or else",
                 F.New_Binary
                   (Name ("Finish"), ">",
                    F.New_Attribute (Name ("Buffer"), "Last")));
            Body_Statements : Node_List;
         begin
            if Required > 0 then
               Bad := F.New_Binary
                 (F.New_Binary
                    (Name ("Count"), "<",
                     Literal (Long_Long_Long_Integer (Required))),
                  "or else", Bad);
            end if;
            Body_Statements.Append
              (F.New_If
                 (Bad, [F.New_Raise (Name ("Constraint_Error"))]));

            for Index in Fields'Range loop
               if Index <= Required then
                  Body_Statements.Append (Fields (Index));
               else
                  declare
                     Field   : constant Idle.Syntax.Field :=
                       Item.Fields (Index);
                     Default : constant Syn.Node_Access :=
                       Default_Node (F, Owner, Field);
                  begin
                     Body_Statements.Append
                       (F.New_If
                          (F.New_Binary
                             (Name ("Count"), ">=",
                              Literal (Long_Long_Long_Integer (Index))),
                           [Fields (Index)],
                           [F.New_Assignment
                              (Name (Field_Name (Field)),
                               (if Default = null
                                then F.New_Raw ("(others => <>)")
                                else Default))]));
                  end;
               end if;
            end loop;

            Body_Statements.Append
              (F.New_If
                 (F.New_Binary (Name ("Last"), ">", Name ("Finish")),
                  [F.New_Raise (Name ("Constraint_Error"))]));
            Body_Statements.Append
              (F.New_Assignment (Name ("Last"), Name ("Finish")));

            Add_Body
              ("Decode",
               F.New_Subprogram_Body
                 (Specification => Codec.Decode_From,
                  Declarations  =>
                    [F.New_Object
                       ("Start", Name ("Storage_Offset"), Name ("Last"),
                        Is_Constant => True),
                     F.New_Object
                       ("Header", Name ("Unsigned_32"),
                        Call ("Get_Word_32", Buffer_Last),
                        Is_Constant => True),
                     F.New_Object
                       ("Finish", Name ("Storage_Offset"),
                        F.New_Binary
                          (Name ("Start"), "+",
                           Call ("Storage_Offset",
                                 [F.New_Binary
                                    (Name ("Header"), "and",
                                     F.New_Integer_Literal
                                       (16#FF_FFFF#, Base => 16,
                                        Group => 4))])),
                        Is_Constant => True),
                     F.New_Object
                       ("Count", Name ("Unsigned_32"),
                        Call ("Shift_Right",
                              [Name ("Header"), Literal (24)]),
                        Is_Constant => True)],
                  Statements    => Body_Statements.To_Array));
         end;

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

         --  A record's header: its length in the low 24 bits, and its
         --  number of fields in the high 8 (idle#114).

         if not Has_Records (Owner) then
            return;
         end if;

         Add_Helper
           (F.New_Procedure
              ("Put_Header",
               [F.New_Parameter
                  ("Buffer", Name ("Storage_Array"), Syn.In_Out_Mode),
                F.New_Parameter ("Start", Name ("Storage_Offset")),
                F.New_Parameter ("Finish", Name ("Storage_Offset")),
                F.New_Parameter ("Count", Name ("Unsigned_32"))]),
            "Put_Header",
            Declarations =>
              [F.New_Object
                 ("Position", Name ("Storage_Offset"), Name ("Start"))],
            Statements   =>
              [F.New_If
                 (F.New_Binary
                    (F.New_Binary (Name ("Finish"), "-", Name ("Start")),
                     ">",
                     F.New_Integer_Literal
                       (16#FF_FFFF#, Base => 16, Group => 4)),
                  [F.New_Raise (Name ("Constraint_Error"))]),
               Statement
                 ("Put_Word_32",
                  [Name ("Buffer"), Name ("Position"),
                   F.New_Binary
                     (Call ("Unsigned_32",
                            [F.New_Binary
                               (Name ("Finish"), "-", Name ("Start"))]),
                      "or",
                      Call ("Shift_Left", [Name ("Count"), Literal (24)]))])]);

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
      if Has_Records (Owner) then
         Uses.Append (F.New_Use (Storage));
      end if;

      Add_Helpers;
      for Item of Owner.Types loop
         if Idle.Syntax."=" (Item.Kind, Idle.Syntax.Record_Type) then
            Add_Codec (Item);
         end if;
      end loop;

      --  The views' functions (idle#117).

      declare
         Uses_Text : Boolean := False;
      begin
         for Item of Owner.Views loop
            Add_Body (View_Function_Name (Item),
                      View_Body (F, Owner, Item, Uses_Text));
         end loop;
         if Uses_Text and then not Spec_Context.Contains (Unbounded) then
            Context.Add (Unbounded);
         end if;
      end;

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
