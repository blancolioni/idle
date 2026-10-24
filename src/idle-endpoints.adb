with Ada.Strings.Unbounded;

with GNAT.SHA256;

with Idle.Hierarchy;
with Idle.Literals;
with Idle.Names;

package body Idle.Endpoints is

   use Ada.Strings.Unbounded;

   Prefix : constant String := "rose.interfaces.";

   function Type_Form
     (Owner     : Idle.Syntax.Interface_Declaration;
      Reference : Idle.Syntax.Type_Reference)
      return String;
   --  The canonical form of the type named by Reference in a subprogram
   --  of Owner.

   ----------
   -- Hash --
   ----------

   function Hash (Form : String) return Endpoint_Id is
      Digest : constant String := GNAT.SHA256.Digest (Form);
      Result : Long_Long_Long_Integer;
   begin
      --  The digest is in hexadecimal, so its first sixteen characters
      --  are its first eight bytes.
      if not Idle.Literals.Value
        ("16#" & Digest (Digest'First .. Digest'First + 15) & "#",
         Result, Endpoint_Id'Last)
      then
         raise Program_Error;
      end if;
      return (if Result = 0 then 1 else Result);
   end Hash;

   -----------
   -- Image --
   -----------

   function Image (Id : Endpoint_Id) return String is
      Hex    : constant String := "0123456789ABCDEF";
      Result : String (1 .. 19) := "XXXX_XXXX_XXXX_XXXX";
      Rest   : Long_Long_Long_Integer := Id;
   begin
      for Index in reverse Result'Range loop
         if Result (Index) /= '_' then
            Result (Index) := Hex (Integer (Rest mod 16) + 1);
            Rest := Rest / 16;
         end if;
      end loop;
      return "16#" & Result & "#";
   end Image;

   --------------------
   -- Interface_Form --
   --------------------

   function Interface_Form
     (Item : Idle.Syntax.Interface_Declaration)
      return String
   is
   begin
      return "interface " & Prefix & Idle.Names.Key (To_String (Item.Name));
   end Interface_Form;

   ------------------
   -- Interface_Id --
   ------------------

   function Interface_Id
     (Item : Idle.Syntax.Interface_Declaration)
      return Endpoint_Id
   is
   begin
      if Item.Pinned_Id /= 0 then
         return Item.Pinned_Id;
      else
         return Hash (Interface_Form (Item));
      end if;
   end Interface_Id;

   ---------------------
   -- Subprogram_Form --
   ---------------------

   function Subprogram_Form
     (Owner : Idle.Syntax.Interface_Declaration;
      Item  : Idle.Syntax.Subprogram)
      return String
   is
      use all type Idle.Syntax.Parameter_Mode;
      Result : Unbounded_String :=
        To_Unbounded_String
          (Prefix & Idle.Names.Key (To_String (Owner.Name))
           & "." & Idle.Names.Key (To_String (Item.Name)));
   begin
      if not Item.Parameters.Is_Empty then
         Append (Result, "(");
         for Index in 1 .. Item.Parameters.Last_Index loop
            declare
               Parameter : Idle.Syntax.Parameter renames
                 Item.Parameters (Index);
            begin
               if Index > 1 then
                  Append (Result, "; ");
               end if;
               Append (Result,
                       (case Parameter.Mode is
                           when In_Mode     => "in ",
                           when Out_Mode    => "out ",
                           when In_Out_Mode => "in out "));
               Append (Result, Type_Form (Owner, Parameter.Of_Type));
            end;
         end loop;
         Append (Result, ")");
      end if;

      if Item.Is_Function then
         Append (Result, " return " & Type_Form (Owner, Item.Result));
      end if;

      return To_String (Result);
   end Subprogram_Form;

   -------------------
   -- Subprogram_Id --
   -------------------

   function Subprogram_Id
     (Owner : Idle.Syntax.Interface_Declaration;
      Item  : Idle.Syntax.Subprogram)
      return Endpoint_Id
   is
   begin
      if Item.Pinned_Id /= 0 then
         return Item.Pinned_Id;
      else
         return Hash (Subprogram_Form (Owner, Item));
      end if;
   end Subprogram_Id;

   ---------------
   -- Type_Form --
   ---------------

   function Type_Form
     (Owner     : Idle.Syntax.Interface_Declaration;
      Reference : Idle.Syntax.Type_Reference)
      return String
   is
      Key : constant String := Idle.Names.Key (To_String (Reference.Name));

      function Declared_In
        (Declaration : Idle.Syntax.Interface_Declaration)
         return Boolean
      is (for some Item of Declaration.Types =>
            Idle.Names.Key (To_String (Item.Name)) = Key);

      function Qualified
        (Declaration : Idle.Syntax.Interface_Declaration)
         return String
      is (Prefix & Idle.Names.Key (To_String (Declaration.Name))
          & "." & Key);

   begin
      if Reference.Is_Interface then
         return "interface " & Prefix & Key;
      elsif Declared_In (Owner) then
         return Qualified (Owner);
      end if;

      for Ancestor of Idle.Hierarchy.Ancestors (Owner) loop
         if Declared_In (Ancestor) then
            return Qualified (Ancestor);
         end if;
      end loop;

      --  A predefined type, or an unknown one, which is reported where
      --  types are checked.
      return Key;
   end Type_Form;

end Idle.Endpoints;
