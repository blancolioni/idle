with Ada.Characters.Handling;
with Ada.Strings.Unbounded;

package body Idle.Targets is

   ----------
   -- Find --
   ----------

   function Find (Text : String; Item : out Target) return Boolean is
      Lower : constant String := Ada.Characters.Handling.To_Lower (Text);
   begin
      Item := Default_Target;
      for Candidate in Target loop
         if Lower = Name (Candidate) then
            Item := Candidate;
            return True;
         end if;
      end loop;
      return False;
   end Find;

   ----------
   -- Name --
   ----------

   function Name (Item : Target) return String
   is (case Item is
          when Kernel_Target => "kernel");

   -----------
   -- Names --
   -----------

   function Names return String is
      use Ada.Strings.Unbounded;
      Result : Unbounded_String;
   begin
      for Item in Target loop
         if Length (Result) > 0 then
            Append (Result, ", ");
         end if;
         Append (Result, Name (Item));
      end loop;
      return To_String (Result);
   end Names;

end Idle.Targets;
