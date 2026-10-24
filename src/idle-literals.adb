with Ada.Characters.Handling;
with Ada.Strings.Fixed;

package body Idle.Literals is

   -----------
   -- Value --
   -----------

   function Value
     (Text   : String;
      Result : out Long_Long_Long_Integer;
      Last   : Long_Long_Long_Integer)
      return Boolean
   is
      Hash  : constant Natural := Ada.Strings.Fixed.Index (Text, "#");

      function Digits_Value
        (Image : String;
         Base  : Long_Long_Long_Integer)
         return Boolean;
      --  Set Result to the value of the digits in Image, in Base.

      ------------------
      -- Digits_Value --
      ------------------

      function Digits_Value
        (Image : String;
         Base  : Long_Long_Long_Integer)
         return Boolean
      is
         Seen : Natural := 0;
      begin
         Result := 0;
         for Ch of Image loop
            if Ch = '_' then
               null;
            elsif Ada.Characters.Handling.Is_Hexadecimal_Digit (Ch) then
               declare
                  Digit : constant Long_Long_Long_Integer :=
                    (if Ada.Characters.Handling.Is_Digit (Ch)
                     then Character'Pos (Ch) - Character'Pos ('0')
                     else Character'Pos (Ada.Characters.Handling.To_Upper (Ch))
                          - Character'Pos ('A') + 10);
               begin
                  if Digit >= Base then
                     return False;
                  end if;
                  Result := Result * Base + Digit;
                  if Result > Last then
                     return False;
                  end if;
               end;
               Seen := Seen + 1;
            else
               return False;
            end if;
         end loop;
         return Seen > 0;
      end Digits_Value;

      Base : Long_Long_Long_Integer;

   begin
      Result := 0;

      if Hash = 0 then
         return Digits_Value (Text, 10);
      end if;

      if Text (Text'Last) /= '#'
        or else Hash = Text'Last
        or else not Digits_Value (Text (Text'First .. Hash - 1), 10)
      then
         return False;
      end if;

      Base := Result;
      return Base in 2 .. 16
        and then Digits_Value (Text (Hash + 1 .. Text'Last - 1), Base);
   end Value;

end Idle.Literals;
