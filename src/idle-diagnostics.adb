with Ada.Strings.Fixed;
with Ada.Text_IO;

package body Idle.Diagnostics is

   Errors : Natural := 0;

   procedure Report
     (File_Name : String;
      Line      : Natural;
      Column    : Natural;
      Kind      : String;
      Message   : String);

   function Image (Value : Natural) return String
   is (Ada.Strings.Fixed.Trim (Value'Image, Ada.Strings.Left));

   -----------
   -- Error --
   -----------

   procedure Error
     (File_Name : String;
      Line      : Natural;
      Column    : Natural;
      Message   : String)
   is
   begin
      Errors := Errors + 1;
      Report (File_Name, Line, Column, "error", Message);
   end Error;

   -----------------
   -- Error_Count --
   -----------------

   function Error_Count return Natural is (Errors);

   ------------
   -- Report --
   ------------

   procedure Report
     (File_Name : String;
      Line      : Natural;
      Column    : Natural;
      Kind      : String;
      Message   : String)
   is
      Position : constant String :=
                   (if Line = 0 then ""
                    elsif Column = 0 then ":" & Image (Line)
                    else ":" & Image (Line) & ":" & Image (Column));
   begin
      Ada.Text_IO.Put_Line
        (Ada.Text_IO.Standard_Error,
         (if File_Name = "" then "idle" else File_Name) & Position
         & ": " & Kind & ": " & Message);
   end Report;

   -------------
   -- Warning --
   -------------

   procedure Warning
     (File_Name : String;
      Line      : Natural;
      Column    : Natural;
      Message   : String)
   is
   begin
      Report (File_Name, Line, Column, "warning", Message);
   end Warning;

end Idle.Diagnostics;
