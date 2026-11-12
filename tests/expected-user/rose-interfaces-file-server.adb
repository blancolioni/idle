with Ada.Containers.Vectors;
with Rose.Interfaces.File_Reader;
with Rose.Interfaces.Objects;
with Rose.Interfaces.Seekable_File_Reader;
with Rose.Invocation;
with Rose.System_Calls;
with System;
with System.Storage_Elements;

package body Rose.Interfaces.File.Server is

   Server_Instance : Rose.Server.Server_Instance;

   type Object_Access is access all File_Interface'Class;

   type Attached_Object is record
      Object     : Object_Access;
      Identifier : Rose.Objects.Capability_Identifier := 0;
      Cap        : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
   end record;

   package Attached_Vectors is
     new Ada.Containers.Vectors (Natural, Attached_Object);

   Attached        : Attached_Vectors.Vector;

   Registered      : Boolean := False;

   subtype File_Reader_Object_Class is
     Rose.Interfaces.File_Reader.File_Reader_Object'Class;

   subtype Seekable_File_Reader_Object_Class is
     Rose.Interfaces.Seekable_File_Reader.Seekable_File_Reader_Object'Class;

   function Find
     (Identifier : Rose.Objects.Capability_Identifier)
      return Object_Access;

   function Owns
     (Identifier : Rose.Objects.Capability_Identifier)
      return Boolean;

   procedure Handle_Get_File_Interface
     (Parameters : in out Rose.Invocation.Invocation_Record);

   procedure Handle_Size
     (Parameters : in out Rose.Invocation.Invocation_Record);

   procedure Handle_Open_Reader
     (Parameters : in out Rose.Invocation.Invocation_Record);

   procedure Handle_Open_Seekable_Reader
     (Parameters : in out Rose.Invocation.Invocation_Record);

   ------------
   -- Attach --
   ------------

   procedure Attach
     (Server_Context : in out Rose.Server.Server_Context;
      Object         : not null access File_Interface'Class;
      Identifier     : Rose.Objects.Capability_Identifier := 0)
   is
      use type Rose.Objects.Capability_Identifier;
   begin
      if not Registered then
         Rose.Server.Register_Handler
           (Server_Context,
            Rose.Interfaces.File.File_Interface,
            Handle_Get_File_Interface'Access,
            Owns'Access);
         Rose.Server.Register_Handler
           (Server_Context,
            Size_Endpoint,
            Handle_Size'Access,
            Owns'Access);
         Rose.Server.Register_Handler
           (Server_Context,
            Open_Reader_Endpoint,
            Handle_Open_Reader'Access,
            Owns'Access);
         Rose.Server.Register_Handler
           (Server_Context,
            Open_Seekable_Reader_Endpoint,
            Handle_Open_Seekable_Reader'Access,
            Owns'Access);
         Registered := True;
      end if;
      Attached.Append (Attached_Object'(others => <>));
      Attached (Attached.Last_Index).Object := Object_Access (Object);
      if Identifier = 0 then
         Attached (Attached.Last_Index).Identifier :=
           Rose.Server.New_Identifier;
      else
         Attached (Attached.Last_Index).Identifier := Identifier;
      end if;
      Attached (Attached.Last_Index).Cap :=
        Rose.Server.Create_Endpoint
          (Rose.Interfaces.File.File_Interface,
           Attached (Attached.Last_Index).Identifier);
   end Attach;

   ------------
   -- Cap_Of --
   ------------

   function Cap_Of
     (Object       : File_Interface'Class;
      Interface_Id : Rose.Objects.Endpoint_Id :=
        Rose.Interfaces.File.File_Interface)
      return Rose.Capabilities.Capability
   is
      use type System.Address;
      use type Rose.Objects.Endpoint_Id;
   begin
      for Item of Attached loop
         if Item.Object /= null
           and then Item.Object.all'Address = Object'Address
         then
            if Interface_Id = Rose.Interfaces.File.File_Interface then
               return Item.Cap;
            end if;
         end if;
      end loop;
      raise Rose.Interfaces.Objects.Not_Served
        with "Rose.Interfaces.File.Server.Cap_Of";
   end Cap_Of;

   ----------
   -- Find --
   ----------

   function Find
     (Identifier : Rose.Objects.Capability_Identifier)
      return Object_Access
   is
      use type Rose.Objects.Capability_Identifier;
   begin
      if Identifier = 0 then
         if Attached.Is_Empty then
            return null;
         end if;
         return Attached (0).Object;
      end if;
      for Item of Attached loop
         if Item.Object /= null and then Item.Identifier = Identifier then
            return Item.Object;
         end if;
      end loop;
      return null;
   end Find;

   -------------------------------
   -- Handle_Get_File_Interface --
   -------------------------------

   procedure Handle_Get_File_Interface
     (Parameters : in out Rose.Invocation.Invocation_Record)
   is
      Cap        : Rose.Capabilities.Capability;
      Identifier : constant Rose.Objects.Capability_Identifier :=
        Parameters.Identifier;
      First      : Natural := 0;
      Page       : Natural := Rose.Invocation.Max_Capabilities;
   begin
      if Rose.Invocation.Sent_Word_Count (Parameters) >= 2 then
         First := Natural (Parameters.Data (1));
      end if;
      if Rose.Invocation.Sent_Word_Count (Parameters) >= 3 then
         Page := Natural'Min (Page, Natural (Parameters.Data (2)));
      end if;
      Rose.System_Calls.Initialize_Reply (Parameters, Parameters.Reply_Cap);
      if First >= 3 then
         Rose.System_Calls.Send_Error
           (Parameters,
            Rose.Invocation.Invalid_Operation);
      else
         if 0 in First .. (First + Page - 1) then
            if not Rose.Server.Has_Instance
              (Server_Instance,
               Size_Endpoint,
               Identifier)
            then
               Rose.Server.Set_Instance_Cap
                 (Server_Instance,
                  Size_Endpoint,
                  Identifier,
                  Rose.Server.Create_Endpoint (Size_Endpoint, Identifier));
            end if;
            Cap :=
              Rose.Server.Get_Instance_Cap
                (Server_Instance,
                 Size_Endpoint,
                 Identifier);
            Rose.System_Calls.Send_Cap (Parameters, Cap);
         end if;
         if 1 in First .. (First + Page - 1) then
            if not Rose.Server.Has_Instance
              (Server_Instance,
               Open_Reader_Endpoint,
               Identifier)
            then
               Rose.Server.Set_Instance_Cap
                 (Server_Instance,
                  Open_Reader_Endpoint,
                  Identifier,
                  Rose.Server.Create_Endpoint
                    (Open_Reader_Endpoint,
                     Identifier));
            end if;
            Cap :=
              Rose.Server.Get_Instance_Cap
                (Server_Instance,
                 Open_Reader_Endpoint,
                 Identifier);
            Rose.System_Calls.Send_Cap (Parameters, Cap);
         end if;
         if 2 in First .. (First + Page - 1) then
            if not Rose.Server.Has_Instance
              (Server_Instance,
               Open_Seekable_Reader_Endpoint,
               Identifier)
            then
               Rose.Server.Set_Instance_Cap
                 (Server_Instance,
                  Open_Seekable_Reader_Endpoint,
                  Identifier,
                  Rose.Server.Create_Endpoint
                    (Open_Seekable_Reader_Endpoint,
                     Identifier));
            end if;
            Cap :=
              Rose.Server.Get_Instance_Cap
                (Server_Instance,
                 Open_Seekable_Reader_Endpoint,
                 Identifier);
            Rose.System_Calls.Send_Cap (Parameters, Cap);
         end if;
      end if;
   end Handle_Get_File_Interface;

   ------------------------
   -- Handle_Open_Reader --
   ------------------------

   procedure Handle_Open_Reader
     (Parameters : in out Rose.Invocation.Invocation_Record)
   is
   begin
      begin
         declare
            Object : constant Object_Access := Find (Parameters.Identifier);
         begin
            if Object = null then
               Rose.System_Calls.Initialize_Reply
                 (Parameters,
                  Parameters.Reply_Cap);
               Rose.System_Calls.Send_Error
                 (Parameters,
                  Rose.Invocation.Invalid_Operation);
               return;
            end if;
            declare
               Result : File_Reader_Object_Class := Object.Open_Reader;
            begin
               Rose.System_Calls.Initialize_Reply
                 (Parameters,
                  Parameters.Reply_Cap);
               Rose.System_Calls.Send_Cap (Parameters, Result.File_Reader_Cap);
            end;
         end;
      exception
         when others =>
            Rose.System_Calls.Initialize_Reply
              (Parameters,
               Parameters.Reply_Cap);
            Rose.System_Calls.Send_Error
              (Parameters,
               Rose.Invocation.Exception_Raised);
      end;
   end Handle_Open_Reader;

   ---------------------------------
   -- Handle_Open_Seekable_Reader --
   ---------------------------------

   procedure Handle_Open_Seekable_Reader
     (Parameters : in out Rose.Invocation.Invocation_Record)
   is
   begin
      begin
         declare
            Object : constant Object_Access := Find (Parameters.Identifier);
         begin
            if Object = null then
               Rose.System_Calls.Initialize_Reply
                 (Parameters,
                  Parameters.Reply_Cap);
               Rose.System_Calls.Send_Error
                 (Parameters,
                  Rose.Invocation.Invalid_Operation);
               return;
            end if;
            declare
               Result : Seekable_File_Reader_Object_Class :=
                 Object.Open_Seekable_Reader;
            begin
               Rose.System_Calls.Initialize_Reply
                 (Parameters,
                  Parameters.Reply_Cap);
               Rose.System_Calls.Send_Cap
                 (Parameters,
                  Result.Seekable_File_Reader_Cap);
            end;
         end;
      exception
         when others =>
            Rose.System_Calls.Initialize_Reply
              (Parameters,
               Parameters.Reply_Cap);
            Rose.System_Calls.Send_Error
              (Parameters,
               Rose.Invocation.Exception_Raised);
      end;
   end Handle_Open_Seekable_Reader;

   -----------------
   -- Handle_Size --
   -----------------

   procedure Handle_Size
     (Parameters : in out Rose.Invocation.Invocation_Record)
   is
   begin
      begin
         declare
            Object : constant Object_Access := Find (Parameters.Identifier);
            Result : System.Storage_Elements.Storage_Count;
         begin
            if Object = null then
               Rose.System_Calls.Initialize_Reply
                 (Parameters,
                  Parameters.Reply_Cap);
               Rose.System_Calls.Send_Error
                 (Parameters,
                  Rose.Invocation.Invalid_Operation);
               return;
            end if;
            Result := Object.Size;
            Rose.System_Calls.Initialize_Reply
              (Parameters,
               Parameters.Reply_Cap);
            Rose.System_Calls.Send_Storage_Offset (Parameters, Result);
         end;
      exception
         when others =>
            Rose.System_Calls.Initialize_Reply
              (Parameters,
               Parameters.Reply_Cap);
            Rose.System_Calls.Send_Error
              (Parameters,
               Rose.Invocation.Exception_Raised);
      end;
   end Handle_Size;

   -------------------
   -- Identifier_Of --
   -------------------

   function Identifier_Of
     (Object : not null access File_Interface'Class)
      return Rose.Objects.Capability_Identifier
   is
   begin
      for Item of Attached loop
         if Item.Object = Object_Access (Object) then
            return Item.Identifier;
         end if;
      end loop;
      return 0;
   end Identifier_Of;

   -------------------
   -- Interface_Cap --
   -------------------

   function Interface_Cap
     (Object : not null access File_Interface'Class)
      return Rose.Capabilities.Capability
   is
   begin
      for Item of Attached loop
         if Item.Object = Object_Access (Object) then
            return Item.Cap;
         end if;
      end loop;
      return Rose.Capabilities.Null_Capability;
   end Interface_Cap;

   ----------
   -- Owns --
   ----------

   function Owns
     (Identifier : Rose.Objects.Capability_Identifier)
      return Boolean
   is
   begin
      return Find (Identifier) /= null;
   end Owns;

   -------------
   -- Publish --
   -------------

   procedure Publish
     (Server_Context : in out Rose.Server.Server_Context;
      Object         : not null access File_Interface'Class)
   is
   begin
      Attach (Server_Context, Object);
      Rose.Server.Publish_Interface (Interface_Cap (Object));
   end Publish;

end Rose.Interfaces.File.Server;
