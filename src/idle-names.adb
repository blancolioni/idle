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

   --------------
   -- File_Key --
   --------------

   function File_Key (Name : String) return String is
      Result : String := Key (Name);
   begin
      for Ch of Result loop
         if Ch = '.' then
            Ch := '-';
         end if;
      end loop;
      return Result;
   end File_Key;

   ----------------
   -- Group_Name --
   ----------------

   function Group_Name (Name : String) return String is
   begin
      for Index in reverse Name'Range loop
         if Name (Index) = '.' then
            return Ada_Name (Name (Name'First .. Index - 1));
         end if;
      end loop;
      return "";
   end Group_Name;

   -----------------
   -- Simple_Name --
   -----------------

   function Simple_Name (Name : String) return String is
   begin
      for Index in reverse Name'Range loop
         if Name (Index) = '.' then
            return Ada_Name (Name (Index + 1 .. Name'Last));
         end if;
      end loop;
      return Ada_Name (Name);
   end Simple_Name;

   ---------
   -- Key --
   ---------

   function Key (Name : String) return String is (To_Lower (Name));

   ---------------
   -- Versioned --
   ---------------

   function Versioned (Name : String; Version : Natural) return String is
      Image : constant String := Natural'Image (Version);
   begin
      if Version = 0 then
         return Name;
      else
         return Name & "@" & Image (Image'First + 1 .. Image'Last);
      end if;
   end Versioned;

end Idle.Names;
