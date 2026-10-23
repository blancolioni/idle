with Ada.Containers.Vectors;
with Ada.Directories;
with Ada.Streams.Stream_IO;
with Ada.Strings.Unbounded;

with Idle.Diagnostics;
with Idle.Lexer;

package body Idle.Lexical is

   use Ada.Strings.Unbounded;

   type Session is record
      File_Name : Unbounded_String;
      Tokens    : Idle.Lexer.Token_Vectors.Vector;
      Current   : Positive := 1;
   end record;

   package Session_Vectors is
     new Ada.Containers.Vectors (Positive, Session);

   Sessions : Session_Vectors.Vector;

   function Is_Open return Boolean is (not Sessions.Is_Empty);

   function Token_At (Ahead : Natural) return Idle.Lexer.Token_Info
     with Pre => Is_Open;
   --  The token Ahead places past the current one, or the final
   --  Tok_End_Of_File if that is past the end.

   function Read_File (Path : String; Success : out Boolean) return String;
   --  The contents of Path. Success is False if it could not be read.

   -----------
   -- Close --
   -----------

   procedure Close is
   begin
      if Is_Open then
         Sessions.Delete_Last;
      end if;
   end Close;

   -----------
   -- Error --
   -----------

   procedure Error (Message : String) is
   begin
      Idle.Diagnostics.Error (File_Name, Tok_Line, Tok_Column, Message);
   end Error;

   ------------
   -- Expect --
   ------------

   procedure Expect
     (T          : Token;
      Skip_Up_To : Token_Set)
   is
   begin
      if Tok = T then
         Scan;
      else
         Error ("missing " & Description (T));
         Skip_To (Skip_Up_To & T);
         if Tok = T then
            Scan;
         end if;
      end if;
   end Expect;

   ---------------
   -- File_Name --
   ---------------

   function File_Name return String is
   begin
      return (if Is_Open
              then To_String (Sessions.Last_Element.File_Name)
              else "");
   end File_Name;

   --------------
   -- Next_Tok --
   --------------

   function Next_Tok (Ahead : Positive := 1) return Token is
   begin
      return (if Is_Open then Token_At (Ahead).Kind else Tok_End_Of_File);
   end Next_Tok;

   ----------
   -- Open --
   ----------

   procedure Open (Path : String) is
      Success  : Boolean;
      Source   : constant String := Read_File (Path, Success);
      Item     : Session;
      Problems : Idle.Lexer.Problem_Vectors.Vector;
   begin
      Item.File_Name := To_Unbounded_String (Path);
      if not Success then
         Idle.Diagnostics.Error (Path, 0, 0, "cannot read file");
      end if;

      Idle.Lexer.Tokenize (Source, Item.Tokens, Problems);
      for Problem of Problems loop
         Idle.Diagnostics.Error
           (Path, Problem.Line, Problem.Column, To_String (Problem.Message));
      end loop;

      Sessions.Append (Item);
   end Open;

   ---------------
   -- Read_File --
   ---------------

   function Read_File (Path : String; Success : out Boolean) return String is
      use Ada.Streams.Stream_IO;
      File : File_Type;
   begin
      if not Ada.Directories.Exists (Path) then
         Success := False;
         return "";
      end if;

      Open (File, In_File, Path);
      declare
         Result : String (1 .. Natural (Size (File)));
      begin
         String'Read (Stream (File), Result);
         Close (File);
         Success := True;
         return Result;
      end;
   exception
      when Ada.Streams.Stream_IO.Name_Error
         | Ada.Streams.Stream_IO.Use_Error
         | Ada.Streams.Stream_IO.Device_Error =>
         if Is_Open (File) then
            Close (File);
         end if;
         Success := False;
         return "";
   end Read_File;

   ----------
   -- Scan --
   ----------

   procedure Scan is
   begin
      if Is_Open then
         declare
            Top : Session renames Sessions (Sessions.Last_Index);
         begin
            if Top.Current < Top.Tokens.Last_Index then
               Top.Current := Top.Current + 1;
            end if;
         end;
      end if;
   end Scan;

   -------------
   -- Skip_To --
   -------------

   procedure Skip_To (Stop : Token_Set) is
   begin
      while Tok /= Tok_End_Of_File and then not (Tok <= Stop) loop
         Scan;
      end loop;
   end Skip_To;

   ---------
   -- Tok --
   ---------

   function Tok return Token is
   begin
      return (if Is_Open then Token_At (0).Kind else Tok_End_Of_File);
   end Tok;

   ----------------
   -- Tok_Column --
   ----------------

   function Tok_Column return Natural is
   begin
      return (if Is_Open then Token_At (0).Column else 0);
   end Tok_Column;

   --------------
   -- Tok_Line --
   --------------

   function Tok_Line return Natural is
   begin
      return (if Is_Open then Token_At (0).Line else 0);
   end Tok_Line;

   --------------
   -- Tok_Text --
   --------------

   function Tok_Text return String is
   begin
      return (if Is_Open then To_String (Token_At (0).Text) else "");
   end Tok_Text;

   --------------
   -- Token_At --
   --------------

   function Token_At (Ahead : Natural) return Idle.Lexer.Token_Info is
      Top : Session renames Sessions (Sessions.Last_Index);
   begin
      return Top.Tokens
        (Positive'Min (Top.Current + Ahead, Top.Tokens.Last_Index));
   end Token_At;

end Idle.Lexical;
