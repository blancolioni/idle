with Ada.Characters.Handling;
with Ada.Strings.Fixed;
with Ada.Text_IO;

with Idle.Diagnostics;
with Idle.Names;

package body Idle.Endpoints is

   function Interface_Key (Interface_Name : String) return String
   is (Idle.Names.Key
         ("interface." & Idle.Names.Ada_Name (Interface_Name)
          & "_Interface"));

   function Method_Key
     (Interface_Name : String;
      Method_Name    : String)
      return String
   is (Idle.Names.Key
         (Idle.Names.Ada_Name (Interface_Name) & "."
          & Idle.Names.Ada_Name (Method_Name)));

   function Parse_Value
     (Text  : String;
      Value : out Endpoint_Id)
      return Boolean;
   --  Parse Text, a based literal such as 16#D25E_5101_0B66#. False if it
   --  is not one.

   ----------------------
   -- Has_Interface_Id --
   ----------------------

   function Has_Interface_Id
     (Table          : Endpoint_Table;
      Interface_Name : String)
      return Boolean
   is (Table.Ids.Contains (Interface_Key (Interface_Name)));

   -------------------
   -- Has_Method_Id --
   -------------------

   function Has_Method_Id
     (Table          : Endpoint_Table;
      Interface_Name : String;
      Method_Name    : String)
      return Boolean
   is (Table.Ids.Contains (Method_Key (Interface_Name, Method_Name)));

   ------------------
   -- Interface_Id --
   ------------------

   function Interface_Id
     (Table          : Endpoint_Table;
      Interface_Name : String)
      return Endpoint_Id
   is (Table.Ids.Element (Interface_Key (Interface_Name)));

   ----------
   -- Load --
   ----------

   procedure Load (Table : in out Endpoint_Table; Path : String) is
      use Ada.Text_IO;
      File        : File_Type;
      Line_Number : Natural := 0;
   begin
      begin
         Open (File, In_File, Path);
      exception
         when Name_Error | Use_Error =>
            Idle.Diagnostics.Error (Path, 0, 0, "cannot read endpoint table");
            return;
      end;

      while not End_Of_File (File) loop
         Line_Number := Line_Number + 1;
         declare
            Text   : constant String :=
                       Ada.Strings.Fixed.Trim (Get_Line (File),
                                               Ada.Strings.Both);
            Equals : constant Natural := Ada.Strings.Fixed.Index (Text, "=");
            Value  : Endpoint_Id;
         begin
            if Text = "" then
               null;
            elsif Equals = 0 then
               Idle.Diagnostics.Error
                 (Path, Line_Number, 0, "expected ""key = value""");
            else
               declare
                  Key        : constant String :=
                                 Ada.Strings.Fixed.Trim
                                   (Text (Text'First .. Equals - 1),
                                    Ada.Strings.Both);
                  Value_Text : constant String :=
                                 Ada.Strings.Fixed.Trim
                                   (Text (Equals + 1 .. Text'Last),
                                    Ada.Strings.Both);
               begin
                  if Parse_Value (Value_Text, Value) then
                     Table.Ids.Include (Idle.Names.Key (Key), Value);
                  else
                     Idle.Diagnostics.Error
                       (Path, Line_Number, 0,
                        "bad endpoint id: " & Value_Text);
                  end if;
               end;
            end if;
         end;
      end loop;

      Close (File);
   end Load;

   ---------------
   -- Method_Id --
   ---------------

   function Method_Id
     (Table          : Endpoint_Table;
      Interface_Name : String;
      Method_Name    : String)
      return Endpoint_Id
   is (Table.Ids.Element (Method_Key (Interface_Name, Method_Name)));

   -----------------
   -- Parse_Value --
   -----------------

   function Parse_Value
     (Text  : String;
      Value : out Endpoint_Id)
      return Boolean
   is
      Prefix : constant String := "16#";
      Result : Long_Long_Long_Integer := 0;
      Digits_Seen : Natural := 0;
   begin
      Value := 0;
      if Text'Length < Prefix'Length + 2
        or else Text (Text'First .. Text'First + Prefix'Length - 1) /= Prefix
        or else Text (Text'Last) /= '#'
      then
         return False;
      end if;

      for Ch of Text (Text'First + Prefix'Length .. Text'Last - 1) loop
         if Ch = '_' then
            null;
         elsif Ada.Characters.Handling.Is_Hexadecimal_Digit (Ch) then
            Result := Result * 16
              + (if Ada.Characters.Handling.Is_Digit (Ch)
                 then Character'Pos (Ch) - Character'Pos ('0')
                 else Character'Pos (Ada.Characters.Handling.To_Upper (Ch))
                      - Character'Pos ('A') + 10);
            Digits_Seen := Digits_Seen + 1;
            if Result > Endpoint_Id'Last then
               return False;
            end if;
         else
            return False;
         end if;
      end loop;

      if Digits_Seen = 0 then
         return False;
      end if;

      Value := Result;
      return True;
   end Parse_Value;

end Idle.Endpoints;
