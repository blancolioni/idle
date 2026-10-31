with Idle.Hierarchy;
with Idle.Names;

package body Idle.Targets.Kernel.Types is

   function Declared
     (Owner : Idle.Syntax.Interface_Declaration;
      Item  : Idle.Syntax.Type_Declaration)
      return Type_Info;
   --  The type Item, declared by Owner.

   function Info
     (Category : Types.Category;
      Encoding : Types.Encoding;
      Ada_Name : String;
      Unit     : String)
      return Type_Info
   is (Category       => Category,
       Encoding       => Encoding,
       Ada_Name       => To_Unbounded_String (Ada_Name),
       Unit           => To_Unbounded_String (Unit),
       Interface_Name => Null_Unbounded_String);

   function Predefined (Name : String) return Type_Info;
   --  The predefined type Name, or a Type_Info whose Category is Unknown.

   --------------
   -- Declared --
   --------------

   function Declared
     (Owner : Idle.Syntax.Interface_Declaration;
      Item  : Idle.Syntax.Type_Declaration)
      return Type_Info
   is
      Package_Name : constant String :=
        "Rose.Interfaces." & Idle.Names.Ada_Name (To_String (Owner.Name));
      Type_Name    : constant String :=
        Package_Name & "." & Idle.Names.Ada_Name (To_String (Item.Name));
   begin
      case Item.Kind is
         when Idle.Syntax.Range_Type =>
            return Info (Word_Value, Converted, Type_Name, Package_Name);
         when Idle.Syntax.Enumeration_Type =>
            return Info (Word_Value, Enumeration, Type_Name, Package_Name);
         when Idle.Syntax.Derived_Type =>
            declare
               Parent : constant Type_Info := Resolve (Owner, Item.Parent);
            begin
               case Parent.Category is
                  when Word_Value | Double_Word_Value =>
                     return Info
                       (Parent.Category,
                        (if Parent.Encoding = Enumeration
                         then Enumeration else Converted),
                        Type_Name, Package_Name);
                  when others =>
                     return (others => <>);
               end case;
            end;
      end case;
   end Declared;

   ------------
   -- Decode --
   ------------

   function Decode
     (Factory : in out Syn.Factory.Factory;
      Info    : Type_Info;
      Params  : String;
      Index   : Natural)
      return not null Syn.Node_Access
   is
      Type_Name : constant String := To_String (Info.Ada_Name);
      Word      : constant not null Syn.Node_Access :=
        Factory.New_Call
          ((if Info.Category = Word_Value
            then "Rose.System_Calls.Get_Word_32"
            else "Rose.System_Calls.Get_Word_64"),
           [Factory.New_Name (Params),
            Factory.New_Integer_Literal (Long_Long_Long_Integer (Index))]);
   begin
      case Info.Encoding is
         when Native =>
            if Type_Name'Length > 11
              and then Type_Name (Type_Name'First .. Type_Name'First + 10)
                         = "Rose.Words."
            then
               return Word;
            else
               return Factory.New_Call (Type_Name, [Word]);
            end if;
         when Converted | Storage_Offset =>
            return Factory.New_Call (Type_Name, [Word]);
         when Enumeration =>
            return Factory.New_Call
              (Factory.New_Attribute (Factory.New_Name (Type_Name), "Val"),
               [Word]);
         when Boolean_Word =>
            return Factory.New_Binary
              (Word, "/=", Factory.New_Integer_Literal (0));
         when Signed =>
            return Factory.New_Call
              ((if Info.Category = Word_Value
                then "Rose.System_Calls.Get_Integer"
                else "Rose.System_Calls.Get_Integer_64"),
               [Factory.New_Name (Params),
                Factory.New_Integer_Literal (Long_Long_Long_Integer (Index))]);
         when Object_Id =>
            return Factory.New_Call
              ("Rose.System_Calls.Get_Object_Id",
               [Factory.New_Name (Params),
                Factory.New_Integer_Literal (Long_Long_Long_Integer (Index))]);
         when Not_A_Word =>
            raise Program_Error;
      end case;
   end Decode;

   -------------------
   -- Packs_Buffers --
   -------------------

   function Packs_Buffers
     (Owner : Idle.Syntax.Interface_Declaration;
      Item  : Idle.Syntax.Subprogram)
      return Boolean
   is
      use type Idle.Syntax.Parameter_Mode;
      Count : Natural := 0;
   begin
      for Parameter of Item.Parameters loop
         if Parameter.Mode = Idle.Syntax.In_Mode
           and then Is_Buffer (Resolve (Owner, Parameter.Of_Type))
         then
            Count := Count + 1;
         end if;
      end loop;
      return Count > 1;
   end Packs_Buffers;

   ----------------
   -- Predefined --
   ----------------

   function Predefined (Name : String) return Type_Info is
      Key : constant String := Idle.Names.Key (Name);
   begin
      if Key in "word" | "word_32" then
         return Info (Word_Value, Native,
                      "Rose.Words." & Idle.Names.Ada_Name (Name),
                      "Rose.Words");
      elsif Key = "word_64" then
         return Info (Double_Word_Value, Native, "Rose.Words.Word_64",
                      "Rose.Words");
      elsif Key in "natural" | "positive" then
         return Info (Word_Value, Native, Idle.Names.Ada_Name (Name), "");
      elsif Key = "boolean" then
         return Info (Word_Value, Boolean_Word, "Boolean", "");
      elsif Key = "integer" then
         return Info (Word_Value, Signed, "Integer", "");
      elsif Key = "integer_64" then
         return Info (Double_Word_Value, Signed, "Long_Long_Integer", "");
      elsif Key = "object_id" then
         return Info (Double_Word_Value, Object_Id, "Rose.Objects.Object_Id",
                      "Rose.Objects");
      elsif Key = "endpoint" then
         return Info (Double_Word_Value, Converted,
                      "Rose.Objects.Endpoint_Id", "Rose.Objects");
      elsif Key in "storage_count" | "stream_element_count" then
         return Info (Word_Value, Storage_Offset,
                      "System.Storage_Elements.Storage_Count",
                      "System.Storage_Elements");
      elsif Key in "storage_offset" | "stream_element_offset" then
         return Info (Word_Value, Storage_Offset,
                      "System.Storage_Elements.Storage_Offset",
                      "System.Storage_Elements");
      elsif Key = "capability" then
         return Info (Capability_Value, Not_A_Word,
                      "Rose.Capabilities.Capability", "Rose.Capabilities");
      elsif Key = "capability_array" then
         return Info (Capability_Array_Value, Not_A_Word,
                      "Rose.Capabilities.Capability_Array",
                      "Rose.Capabilities");
      elsif Key = "string" then
         return Info (String_Value, Not_A_Word, "String", "");
      elsif Key in "storage_array" | "stream_element_array" then
         return Info (Storage_Value, Not_A_Word,
                      "System.Storage_Elements.Storage_Array",
                      "System.Storage_Elements");
      else
         return (others => <>);
      end if;
   end Predefined;

   -------------
   -- Resolve --
   -------------

   function Resolve
     (Owner     : Idle.Syntax.Interface_Declaration;
      Reference : Idle.Syntax.Type_Reference)
      return Type_Info
   is
      Name : constant String := To_String (Reference.Name);
      Key  : constant String := Idle.Names.Key (Name);

      function Find_In
        (Declaration : Idle.Syntax.Interface_Declaration;
         Found       : out Type_Info)
         return Boolean;
      --  Look for the type in the declarations of Declaration.

      -------------
      -- Find_In --
      -------------

      function Find_In
        (Declaration : Idle.Syntax.Interface_Declaration;
         Found       : out Type_Info)
         return Boolean
      is
      begin
         for Item of Declaration.Types loop
            if Idle.Names.Key (To_String (Item.Name)) = Key then
               Found := Declared (Declaration, Item);
               return True;
            end if;
         end loop;
         return False;
      end Find_In;

      Result : Type_Info;

   begin
      if Reference.Is_Interface then
         declare
            Ada_Name : constant String := Idle.Names.Ada_Name (Name);
            Client   : constant String :=
              "Rose.Interfaces." & Ada_Name & ".Client";
         begin
            return (Category       => Interface_Value,
                    Encoding       => Not_A_Word,
                    Ada_Name       =>
                      To_Unbounded_String
                        (Client & "." & Ada_Name & "_Client"),
                    Unit           => To_Unbounded_String (Client),
                    Interface_Name => To_Unbounded_String (Ada_Name));
         end;
      end if;

      if Find_In (Owner, Result) then
         return Result;
      end if;
      for Ancestor of Idle.Hierarchy.Ancestors (Owner) loop
         if Find_In (Ancestor, Result) then
            return Result;
         end if;
      end loop;
      return Predefined (Name);
   end Resolve;

   ----------
   -- Send --
   ----------

   function Send
     (Factory : in out Syn.Factory.Factory;
      Info    : Type_Info;
      Params  : String;
      Value   : String)
      return not null Syn.Node_Access
   is
      Type_Name : constant String := To_String (Info.Ada_Name);

      function Call (Name : String; Argument : not null Syn.Node_Access)
        return not null Syn.Node_Access
      is (Factory.New_Call_Statement
            (Factory.New_Call
               ("Rose.System_Calls." & Name,
                [Factory.New_Name (Params), Argument])));

   begin
      case Info.Encoding is
         when Native =>
            return Call ("Send_Word", Factory.New_Name (Value));
         when Converted =>
            return Call
              ("Send_Word",
               Factory.New_Call
                 ((if Info.Category = Word_Value
                   then "Rose.Words.Word" else "Rose.Words.Word_64"),
                  [Factory.New_Name (Value)]));
         when Enumeration =>
            return Call
              ("Send_Word",
               Factory.New_Call
                 ("Natural",
                  [Factory.New_Call
                     (Factory.New_Attribute
                        (Factory.New_Name (Type_Name), "Pos"),
                      [Factory.New_Name (Value)])]));
         when Boolean_Word =>
            return Call
              ("Send_Word",
               Factory.New_Call
                 ("Natural",
                  [Factory.New_Call
                     (Factory.New_Attribute
                        (Factory.New_Name ("Boolean"), "Pos"),
                      [Factory.New_Name (Value)])]));
         when Signed =>
            return Call
              ((if Info.Category = Word_Value
                then "Send_Integer" else "Send_Integer_64"),
               Factory.New_Name (Value));
         when Object_Id =>
            return Call ("Send_Object_Id", Factory.New_Name (Value));
         when Storage_Offset =>
            return Call ("Send_Storage_Offset", Factory.New_Name (Value));
         when Not_A_Word =>
            raise Program_Error;
      end case;
   end Send;

end Idle.Targets.Kernel.Types;
