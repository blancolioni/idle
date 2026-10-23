with Ada.Characters.Handling;

package body Idle.Names is

   use Ada.Characters.Handling;

   --------------
   -- Ada_Name --
   --------------

   function Ada_Name (Name : String) return String is
      Result     : String := Name;
      Word_Start : Boolean := True;
   begin
      for Ch of Result loop
         if Ch = '_' or else Ch = '.' then
            Word_Start := True;
         elsif Is_Letter (Ch) then
            Ch := (if Word_Start then To_Upper (Ch) else To_Lower (Ch));
            Word_Start := False;
         else
            Word_Start := False;
         end if;
      end loop;
      return Result;
   end Ada_Name;

   ---------
   -- Key --
   ---------

   function Key (Name : String) return String is (To_Lower (Name));

end Idle.Names;
