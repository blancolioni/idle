private with Ada.Containers.Indefinite_Hashed_Maps;
private with Ada.Strings.Hash;

package Idle.Endpoints is

   --  Endpoint ids, read from an existing interfaces.txt table such as
   --  Rose's. idle never adds to the table or writes it: a missing id is
   --  an error. Ids derived from the source (idle#3) will replace this.

   subtype Endpoint_Id is Long_Long_Long_Integer range 0 .. 2 ** 64 - 1;

   type Endpoint_Table is tagged private;

   procedure Load (Table : in out Endpoint_Table; Path : String);
   --  Add the entries in Path, lines of the form
   --  "Interface.Method = 16#XXXX_XXXX_XXXX#". Errors are reported
   --  through Idle.Diagnostics.

   function Has_Interface_Id
     (Table          : Endpoint_Table;
      Interface_Name : String)
      return Boolean;

   function Interface_Id
     (Table          : Endpoint_Table;
      Interface_Name : String)
      return Endpoint_Id
     with Pre => Table.Has_Interface_Id (Interface_Name);

   function Has_Method_Id
     (Table          : Endpoint_Table;
      Interface_Name : String;
      Method_Name    : String)
      return Boolean;

   function Method_Id
     (Table          : Endpoint_Table;
      Interface_Name : String;
      Method_Name    : String)
      return Endpoint_Id
     with Pre => Table.Has_Method_Id (Interface_Name, Method_Name);

private

   package Id_Maps is
     new Ada.Containers.Indefinite_Hashed_Maps
       (Key_Type        => String,
        Element_Type    => Endpoint_Id,
        Hash            => Ada.Strings.Hash,
        Equivalent_Keys => "=");

   type Endpoint_Table is tagged record
      Ids : Id_Maps.Map;
      --  Keyed by the table's key in lower case.
   end record;

end Idle.Endpoints;
