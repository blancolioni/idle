with Ada.Command_Line;
with Ada.Containers.Indefinite_Vectors;
with Ada.Strings.Unbounded;
with Ada.Text_IO;

with Idle.Diagnostics;
with Idle.Endpoints;
with Idle.Parser;
with Idle.Syntax;
with Idle.Targets.Kernel;

procedure Idle.Main is

   --  idle [--syntax-only] [--endpoints FILE] [-o DIRECTORY] FILE.idl...

   use Ada.Strings.Unbounded;

   package String_Vectors is
     new Ada.Containers.Indefinite_Vectors (Positive, String);

   procedure Usage;

   Files            : String_Vectors.Vector;
   Endpoint_File    : Unbounded_String;
   Output_Directory : Unbounded_String := To_Unbounded_String (".");
   Syntax_Only      : Boolean := False;
   Arguments_OK     : Boolean := True;
   Index            : Positive := 1;

   -----------
   -- Usage --
   -----------

   procedure Usage is
   begin
      Ada.Text_IO.Put_Line
        (Ada.Text_IO.Standard_Error,
         "usage: idle [--syntax-only] [--endpoints FILE] [-o DIRECTORY]"
         & " FILE.idl...");
   end Usage;

begin
   while Index <= Ada.Command_Line.Argument_Count loop
      declare
         Argument : constant String := Ada.Command_Line.Argument (Index);
      begin
         if Argument = "--syntax-only" then
            Syntax_Only := True;
         elsif Argument = "--endpoints" or else Argument = "-o" then
            if Index = Ada.Command_Line.Argument_Count then
               Ada.Text_IO.Put_Line
                 (Ada.Text_IO.Standard_Error,
                  "idle: " & Argument & " needs a value");
               Arguments_OK := False;
            else
               Index := Index + 1;
               if Argument = "-o" then
                  Output_Directory :=
                    To_Unbounded_String (Ada.Command_Line.Argument (Index));
               else
                  Endpoint_File :=
                    To_Unbounded_String (Ada.Command_Line.Argument (Index));
               end if;
            end if;
         elsif Argument'Length > 0 and then Argument (Argument'First) = '-'
         then
            Ada.Text_IO.Put_Line
              (Ada.Text_IO.Standard_Error,
               "idle: unknown option " & Argument);
            Arguments_OK := False;
         else
            Files.Append (Argument);
         end if;
      end;
      Index := Index + 1;
   end loop;

   if Files.Is_Empty
     or else (not Syntax_Only and then Endpoint_File = Null_Unbounded_String)
   then
      Arguments_OK := False;
   end if;

   if not Arguments_OK then
      Usage;
      Ada.Command_Line.Set_Exit_Status (Ada.Command_Line.Failure);
      return;
   end if;

   declare
      Endpoints : Idle.Endpoints.Endpoint_Table;
   begin
      if not Syntax_Only then
         Endpoints.Load (To_String (Endpoint_File));
      end if;

      for File of Files loop
         declare
            Errors_Before : constant Natural :=
                              Idle.Diagnostics.Error_Count;
            Item          : constant Idle.Syntax.Interface_Declaration :=
                              Idle.Parser.Parse_File (File);
         begin
            if not Syntax_Only
              and then Idle.Diagnostics.Error_Count = Errors_Before
            then
               Idle.Targets.Kernel.Generate_Interface_Package
                 (Item, Endpoints, To_String (Output_Directory));
            end if;
         end;
      end loop;
   end;

   if Idle.Diagnostics.Error_Count > 0 then
      Ada.Command_Line.Set_Exit_Status (Ada.Command_Line.Failure);
   end if;
end Idle.Main;
