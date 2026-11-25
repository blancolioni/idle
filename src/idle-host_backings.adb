with Ada.Containers.Indefinite_Hashed_Maps;
with Ada.Strings.Fixed;
with Ada.Strings.Hash;
with Ada.Strings.Maps;
with Ada.Text_IO;

with Idle.Diagnostics;
with Idle.Names;

package body Idle.Host_Backings is

   package Backing_Maps is
     new Ada.Containers.Indefinite_Hashed_Maps
       (Key_Type        => String,
        Element_Type    => String,
        Hash            => Ada.Strings.Hash,
        Equivalent_Keys => "=");

   Backings : Backing_Maps.Map;
   --  Each backing, by the key of its interface's name.

   Loaded : Boolean := False;

   ----------
   -- Find --
   ----------

   function Find (Interface_Name : String) return String is
      Position : constant Backing_Maps.Cursor :=
        Backings.Find (Idle.Names.Key (Interface_Name));
   begin
      if Backing_Maps.Has_Element (Position) then
         return Backing_Maps.Element (Position);
      else
         return "";
      end if;
   end Find;

   ---------------
   -- Is_Loaded --
   ---------------

   function Is_Loaded return Boolean is
   begin
      return Loaded;
   end Is_Loaded;

   ----------
   -- Load --
   ----------

   procedure Load (File_Name : String) is
      File        : Ada.Text_IO.File_Type;
      Line_Number : Natural := 0;

      procedure Read_Line (Line : String);
      --  Add the backing on Line, unless it is blank or a comment.

      ---------------
      -- Read_Line --
      ---------------

      procedure Read_Line (Line : String) is
         use Ada.Strings.Fixed;
         Hash   : constant Natural := Index (Line, "#");
         Text   : constant String :=
           Trim ((if Hash = 0 then Line else Line (Line'First .. Hash - 1)),
                 Ada.Strings.Both);
         Space  : constant Natural :=
           Index (Text, Ada.Strings.Maps.To_Set (" " & ASCII.HT));

         procedure Error (Message : String);

         -----------
         -- Error --
         -----------

         procedure Error (Message : String) is
         begin
            Idle.Diagnostics.Error (File_Name, Line_Number, 0, Message);
         end Error;

      begin
         if Text = "" then
            return;
         elsif Space = 0 then
            Error ("a backing needs an interface and a type");
            return;
         end if;

         declare
            Name    : constant String := Text (Text'First .. Space - 1);
            Backing : constant String :=
              Trim (Text (Space + 1 .. Text'Last), Ada.Strings.Both);
         begin
            if Index (Backing, Ada.Strings.Maps.To_Set (" " & ASCII.HT)) > 0
            then
               Error ("a backing needs an interface and a type");
            elsif Index (Backing, ".") = 0 then
               Error ("the type " & Backing & " needs its package");
            elsif Backings.Contains (Idle.Names.Key (Name)) then
               Error ("interface " & Name & " already has a backing");
            else
               Backings.Insert (Idle.Names.Key (Name), Backing);
            end if;
         end;
      end Read_Line;

   begin
      Loaded := True;
      begin
         Ada.Text_IO.Open (File, Ada.Text_IO.In_File, File_Name);
      exception
         when Ada.Text_IO.Name_Error | Ada.Text_IO.Use_Error =>
            Idle.Diagnostics.Error (File_Name, 0, 0, "cannot open the file");
            return;
      end;

      while not Ada.Text_IO.End_Of_File (File) loop
         Line_Number := Line_Number + 1;
         Read_Line (Ada.Text_IO.Get_Line (File));
      end loop;
      Ada.Text_IO.Close (File);
   end Load;

   -------------
   -- Unit_Of --
   -------------

   function Unit_Of (Backing : String) return String is
      Dot : constant Natural :=
        Ada.Strings.Fixed.Index (Backing, ".", Ada.Strings.Backward);
   begin
      return Backing (Backing'First .. Dot - 1);
   end Unit_Of;

end Idle.Host_Backings;
