with Ada.Containers.Vectors;
with Ada.Streams;
with Rose.Interfaces.File_Reader;
with Rose.Interfaces.Objects;
with Rose.Interfaces.Seekable_File_Reader;
with Rose.Interfaces.Transactional_Writable_File;
with Rose.Invocation;
with Rose.System_Calls;
with System;
with System.Storage_Elements;

package body Rose.Interfaces.Writable_File.Server is

   Server_Instance : Rose.Server.Server_Instance;

   type Object_Access is access all Writable_File_Interface'Class;

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

   subtype Transactional_Writable_File_Object_Class is
     Rose.Interfaces.Transactional_Writable_File
       .Transactional_Writable_File_Object'Class;

   function Find
     (Identifier : Rose.Objects.Capability_Identifier)
      return Object_Access;

   function Owns
     (Identifier : Rose.Objects.Capability_Identifier)
      return Boolean;

   procedure Handle_Get_File_Interface
     (Parameters : in out Rose.Invocation.Invocation_Record);

   procedure Handle_Get_Stream_Writer_Interface
     (Parameters : in out Rose.Invocation.Invocation_Record);

   procedure Handle_Get_Writable_File_Interface
     (Parameters : in out Rose.Invocation.Invocation_Record);

   procedure Handle_Size
     (Parameters : in out Rose.Invocation.Invocation_Record);

   procedure Handle_Open_Reader
     (Parameters : in out Rose.Invocation.Invocation_Record);

   procedure Handle_Open_Seekable_Reader
     (Parameters : in out Rose.Invocation.Invocation_Record);

   procedure Handle_Write
     (Parameters : in out Rose.Invocation.Invocation_Record);

   procedure Handle_Truncate
     (Parameters : in out Rose.Invocation.Invocation_Record);

   procedure Handle_New_Version
     (Parameters : in out Rose.Invocation.Invocation_Record);

   ------------
   -- Attach --
   ------------

   procedure Attach
     (Server_Context : in out Rose.Server.Server_Context;
      Object         : not null access Writable_File_Interface'Class;
      Identifier     : Rose.Objects.Capability_Identifier := 0)
   is
      use type Rose.Objects.Capability_Identifier;
   begin
      if not Registered then
         Rose.Server.Register_Handler
           (Server_Context,
            Rose.Interfaces.Writable_File.File_Interface,
            Handle_Get_File_Interface'Access,
            Owns'Access);
         Rose.Server.Register_Handler
           (Server_Context,
            Rose.Interfaces.Writable_File.Stream_Writer_Interface,
            Handle_Get_Stream_Writer_Interface'Access,
            Owns'Access);
         Rose.Server.Register_Handler
           (Server_Context,
            Rose.Interfaces.Writable_File.Writable_File_Interface,
            Handle_Get_Writable_File_Interface'Access,
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
         Rose.Server.Register_Handler
           (Server_Context,
            Write_Endpoint,
            Handle_Write'Access,
            Owns'Access);
         Rose.Server.Register_Handler
           (Server_Context,
            Truncate_Endpoint,
            Handle_Truncate'Access,
            Owns'Access);
         Rose.Server.Register_Handler
           (Server_Context,
            New_Version_Endpoint,
            Handle_New_Version'Access,
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
          (Rose.Interfaces.Writable_File.Writable_File_Interface,
           Attached (Attached.Last_Index).Identifier);
   end Attach;

   ------------
   -- Cap_Of --
   ------------

   function Cap_Of
     (Object       : Writable_File_Interface'Class;
      Interface_Id : Rose.Objects.Endpoint_Id :=
        Rose.Interfaces.Writable_File.Writable_File_Interface)
      return Rose.Capabilities.Capability
   is
      use type System.Address;
      use type Rose.Objects.Endpoint_Id;
   begin
      for Item of Attached loop
         if Item.Object /= null
           and then Item.Object.all'Address = Object'Address
         then
            if Interface_Id = Rose.Interfaces.Writable_File
              .Writable_File_Interface
            then
               return Item.Cap;
            else
               if Interface_Id = Rose.Interfaces.Writable_File.File_Interface
                 or else Interface_Id = Rose.Interfaces.Writable_File
                   .Stream_Writer_Interface
               then
                  if not Rose.Server.Has_Instance
                    (Server_Instance,
                     Interface_Id,
                     Item.Identifier)
                  then
                     Rose.Server.Set_Instance_Cap
                       (Server_Instance,
                        Interface_Id,
                        Item.Identifier,
                        Rose.Server.Create_Endpoint
                          (Interface_Id,
                           Item.Identifier));
                  end if;
                  return Rose.Server.Get_Instance_Cap
                    (Server_Instance,
                     Interface_Id,
                     Item.Identifier);
               end if;
            end if;
         end if;
      end loop;
      raise Rose.Interfaces.Objects.Not_Served
        with "Rose.Interfaces.Writable_File.Server.Cap_Of";
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

   ----------------------------------------
   -- Handle_Get_Stream_Writer_Interface --
   ----------------------------------------

   procedure Handle_Get_Stream_Writer_Interface
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
      if First >= 1 then
         Rose.System_Calls.Send_Error
           (Parameters,
            Rose.Invocation.Invalid_Operation);
      else
         if 0 in First .. (First + Page - 1) then
            if not Rose.Server.Has_Instance
              (Server_Instance,
               Write_Endpoint,
               Identifier)
            then
               Rose.Server.Set_Instance_Cap
                 (Server_Instance,
                  Write_Endpoint,
                  Identifier,
                  Rose.Server.Create_Endpoint (Write_Endpoint, Identifier));
            end if;
            Cap :=
              Rose.Server.Get_Instance_Cap
                (Server_Instance,
                 Write_Endpoint,
                 Identifier);
            Rose.System_Calls.Send_Cap (Parameters, Cap);
         end if;
      end if;
   end Handle_Get_Stream_Writer_Interface;

   ----------------------------------------
   -- Handle_Get_Writable_File_Interface --
   ----------------------------------------

   procedure Handle_Get_Writable_File_Interface
     (Parameters : in out Rose.Invocation.Invocation_Record)
   is
      Cap        : Rose.Capabilities.Capability;
      Identifier : constant Rose.Objects.Capability_Identifier :=
        Parameters.Identifier;
      Ancestor   : Natural := 0;
      First      : Natural := 0;
      Page       : Natural := Rose.Invocation.Max_Capabilities;
   begin
      if Parameters.Control.Flags (Rose.Invocation.Send_Words) then
         Ancestor := Natural (Parameters.Data (0));
      end if;
      if Rose.Invocation.Sent_Word_Count (Parameters) >= 2 then
         First := Natural (Parameters.Data (1));
      end if;
      if Rose.Invocation.Sent_Word_Count (Parameters) >= 3 then
         Page := Natural'Min (Page, Natural (Parameters.Data (2)));
      end if;
      Rose.System_Calls.Initialize_Reply (Parameters, Parameters.Reply_Cap);
      if Ancestor = 0 then
         if First >= 6 then
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
            if 3 in First .. (First + Page - 1) then
               if not Rose.Server.Has_Instance
                 (Server_Instance,
                  Write_Endpoint,
                  Identifier)
               then
                  Rose.Server.Set_Instance_Cap
                    (Server_Instance,
                     Write_Endpoint,
                     Identifier,
                     Rose.Server.Create_Endpoint (Write_Endpoint, Identifier));
               end if;
               Cap :=
                 Rose.Server.Get_Instance_Cap
                   (Server_Instance,
                    Write_Endpoint,
                    Identifier);
               Rose.System_Calls.Send_Cap (Parameters, Cap);
            end if;
            if 4 in First .. (First + Page - 1) then
               if not Rose.Server.Has_Instance
                 (Server_Instance,
                  Truncate_Endpoint,
                  Identifier)
               then
                  Rose.Server.Set_Instance_Cap
                    (Server_Instance,
                     Truncate_Endpoint,
                     Identifier,
                     Rose.Server.Create_Endpoint
                       (Truncate_Endpoint,
                        Identifier));
               end if;
               Cap :=
                 Rose.Server.Get_Instance_Cap
                   (Server_Instance,
                    Truncate_Endpoint,
                    Identifier);
               Rose.System_Calls.Send_Cap (Parameters, Cap);
            end if;
            if 5 in First .. (First + Page - 1) then
               if not Rose.Server.Has_Instance
                 (Server_Instance,
                  New_Version_Endpoint,
                  Identifier)
               then
                  Rose.Server.Set_Instance_Cap
                    (Server_Instance,
                     New_Version_Endpoint,
                     Identifier,
                     Rose.Server.Create_Endpoint
                       (New_Version_Endpoint,
                        Identifier));
               end if;
               Cap :=
                 Rose.Server.Get_Instance_Cap
                   (Server_Instance,
                    New_Version_Endpoint,
                    Identifier);
               Rose.System_Calls.Send_Cap (Parameters, Cap);
            end if;
         end if;
      else
         if Ancestor = 1 then
            if not Rose.Server.Has_Instance
              (Server_Instance,
               File_Interface,
               Identifier)
            then
               Rose.Server.Set_Instance_Cap
                 (Server_Instance,
                  File_Interface,
                  Identifier,
                  Rose.Server.Create_Endpoint (File_Interface, Identifier));
            end if;
            Rose.System_Calls.Send_Cap
              (Parameters,
               Rose.Server.Get_Instance_Cap
                 (Server_Instance,
                  File_Interface,
                  Identifier));
         else
            if Ancestor = 2 then
               if not Rose.Server.Has_Instance
                 (Server_Instance,
                  Stream_Writer_Interface,
                  Identifier)
               then
                  Rose.Server.Set_Instance_Cap
                    (Server_Instance,
                     Stream_Writer_Interface,
                     Identifier,
                     Rose.Server.Create_Endpoint
                       (Stream_Writer_Interface,
                        Identifier));
               end if;
               Rose.System_Calls.Send_Cap
                 (Parameters,
                  Rose.Server.Get_Instance_Cap
                    (Server_Instance,
                     Stream_Writer_Interface,
                     Identifier));
            else
               Rose.System_Calls.Send_Error
                 (Parameters,
                  Rose.Invocation.Invalid_Operation);
            end if;
         end if;
      end if;
   end Handle_Get_Writable_File_Interface;

   ------------------------
   -- Handle_New_Version --
   ------------------------

   procedure Handle_New_Version
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
               Result : Transactional_Writable_File_Object_Class :=
                 Object.New_Version;
            begin
               Rose.System_Calls.Initialize_Reply
                 (Parameters,
                  Parameters.Reply_Cap);
               Rose.System_Calls.Send_Cap
                 (Parameters,
                  Result.Transactional_Writable_File_Cap);
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
   end Handle_New_Version;

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

   ---------------------
   -- Handle_Truncate --
   ---------------------

   procedure Handle_Truncate
     (Parameters : in out Rose.Invocation.Invocation_Record)
   is
   begin
      begin
         declare
            Object : constant Object_Access := Find (Parameters.Identifier);
            Size   : constant System.Storage_Elements.Storage_Count :=
              System.Storage_Elements.Storage_Count
                (Rose.System_Calls.Get_Word_32 (Parameters, 0));
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
            Object.Truncate (Size);
            Rose.System_Calls.Initialize_Reply
              (Parameters,
               Parameters.Reply_Cap);
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
   end Handle_Truncate;

   ------------------
   -- Handle_Write --
   ------------------

   procedure Handle_Write
     (Parameters : in out Rose.Invocation.Invocation_Record)
   is
   begin
      begin
         declare
            Object : constant Object_Access := Find (Parameters.Identifier);
            Buffer : Ada.Streams.Stream_Element_Array
              (1 .. Ada.Streams.Stream_Element_Offset
                 (Parameters.Buffer_Length))
              with Import, Address => Parameters.Buffer_Address;
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
            Object.Write (Buffer);
            Rose.System_Calls.Initialize_Reply
              (Parameters,
               Parameters.Reply_Cap);
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
   end Handle_Write;

   -------------------
   -- Identifier_Of --
   -------------------

   function Identifier_Of
     (Object : not null access Writable_File_Interface'Class)
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
     (Object : not null access Writable_File_Interface'Class)
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
      Object         : not null access Writable_File_Interface'Class)
   is
   begin
      Attach (Server_Context, Object);
      Rose.Server.Publish_Interface (Interface_Cap (Object));
   end Publish;

end Rose.Interfaces.Writable_File.Server;
