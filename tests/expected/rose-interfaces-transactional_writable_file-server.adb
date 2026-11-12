with Rose.Invocation;
with Rose.System_Calls;

package body Rose.Interfaces.Transactional_Writable_File.Server is

   Server_Instance            : Rose.Server.Server_Instance;

   Local_Size                 : Size_Handler;

   Size_Cap                   : Rose.Capabilities.Capability :=
     Rose.Capabilities.Null_Capability;

   Local_Open_Reader          : Open_Reader_Handler;

   Open_Reader_Cap            : Rose.Capabilities.Capability :=
     Rose.Capabilities.Null_Capability;

   Local_Open_Seekable_Reader : Open_Seekable_Reader_Handler;

   Open_Seekable_Reader_Cap   : Rose.Capabilities.Capability :=
     Rose.Capabilities.Null_Capability;

   Local_Write                : Write_Handler;

   Write_Cap                  : Rose.Capabilities.Capability :=
     Rose.Capabilities.Null_Capability;

   Local_Truncate             : Truncate_Handler;

   Truncate_Cap               : Rose.Capabilities.Capability :=
     Rose.Capabilities.Null_Capability;

   Local_New_Version          : New_Version_Handler;

   New_Version_Cap            : Rose.Capabilities.Capability :=
     Rose.Capabilities.Null_Capability;

   Local_Commit               : Commit_Handler;

   Commit_Cap                 : Rose.Capabilities.Capability :=
     Rose.Capabilities.Null_Capability;

   Local_Rollback             : Rollback_Handler;

   Rollback_Cap               : Rose.Capabilities.Capability :=
     Rose.Capabilities.Null_Capability;

   Local_Release              : Release_Handler;

   Release_Cap                : Rose.Capabilities.Capability :=
     Rose.Capabilities.Null_Capability;

   Published_Cap              : Rose.Capabilities.Capability :=
     Rose.Capabilities.Null_Capability;

   procedure Handle_Get_File_Interface
     (Parameters : in out Rose.Invocation.Invocation_Record);

   procedure Handle_Get_Stream_Writer_Interface
     (Parameters : in out Rose.Invocation.Invocation_Record);

   procedure Handle_Get_Writable_File_Interface
     (Parameters : in out Rose.Invocation.Invocation_Record);

   procedure Handle_Get_Transactional_Interface
     (Parameters : in out Rose.Invocation.Invocation_Record);

   procedure Handle_Get_Resource_Interface
     (Parameters : in out Rose.Invocation.Invocation_Record);

   procedure Handle_Get_Transactional_Writable_File_Interface
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

   procedure Handle_Commit
     (Parameters : in out Rose.Invocation.Invocation_Record);

   procedure Handle_Rollback
     (Parameters : in out Rose.Invocation.Invocation_Record);

   procedure Handle_Release
     (Parameters : in out Rose.Invocation.Invocation_Record);

   ----------------------
   -- Attach_Interface --
   ----------------------

   procedure Attach_Interface
     (Server_Context       : in out Rose.Server.Server_Context;
      Size                 : Size_Handler;
      Open_Reader          : Open_Reader_Handler;
      Open_Seekable_Reader : Open_Seekable_Reader_Handler;
      Write                : Write_Handler;
      Truncate             : Truncate_Handler;
      New_Version          : New_Version_Handler;
      Commit               : Commit_Handler;
      Rollback             : Rollback_Handler;
      Release              : Release_Handler;
      Instanced            : Boolean := False)
   is
   begin
      Local_Size := Size;
      Local_Open_Reader := Open_Reader;
      Local_Open_Seekable_Reader := Open_Seekable_Reader;
      Local_Write := Write;
      Local_Truncate := Truncate;
      Local_New_Version := New_Version;
      Local_Commit := Commit;
      Local_Rollback := Rollback;
      Local_Release := Release;
      Rose.Server.Register_Handler
        (Server_Context,
         File_Interface,
         Handle_Get_File_Interface'Access);
      Rose.Server.Register_Handler
        (Server_Context,
         Stream_Writer_Interface,
         Handle_Get_Stream_Writer_Interface'Access);
      Rose.Server.Register_Handler
        (Server_Context,
         Writable_File_Interface,
         Handle_Get_Writable_File_Interface'Access);
      Rose.Server.Register_Handler
        (Server_Context,
         Transactional_Interface,
         Handle_Get_Transactional_Interface'Access);
      Rose.Server.Register_Handler
        (Server_Context,
         Resource_Interface,
         Handle_Get_Resource_Interface'Access);
      Rose.Server.Register_Handler
        (Server_Context,
         Transactional_Writable_File_Interface,
         Handle_Get_Transactional_Writable_File_Interface'Access);
      if not Instanced then
         Size_Cap := Rose.Server.Create_Endpoint (Size_Endpoint);
         Open_Reader_Cap := Rose.Server.Create_Endpoint (Open_Reader_Endpoint);
         Open_Seekable_Reader_Cap :=
           Rose.Server.Create_Endpoint (Open_Seekable_Reader_Endpoint);
         Write_Cap := Rose.Server.Create_Endpoint (Write_Endpoint);
         Truncate_Cap := Rose.Server.Create_Endpoint (Truncate_Endpoint);
         New_Version_Cap := Rose.Server.Create_Endpoint (New_Version_Endpoint);
         Commit_Cap := Rose.Server.Create_Endpoint (Commit_Endpoint);
         Rollback_Cap := Rose.Server.Create_Endpoint (Rollback_Endpoint);
         Release_Cap := Rose.Server.Create_Endpoint (Release_Endpoint);
         Rose.Server.Create_Anonymous_Endpoint (File_Interface);
         Rose.Server.Create_Anonymous_Endpoint (Stream_Writer_Interface);
         Rose.Server.Create_Anonymous_Endpoint (Writable_File_Interface);
         Rose.Server.Create_Anonymous_Endpoint (Transactional_Interface);
         Rose.Server.Create_Anonymous_Endpoint (Resource_Interface);
         Rose.Server.Create_Anonymous_Endpoint
           (Transactional_Writable_File_Interface);
      end if;
      Rose.Server.Register_Handler
        (Server_Context,
         Size_Endpoint,
         Handle_Size'Access);
      Rose.Server.Register_Handler
        (Server_Context,
         Open_Reader_Endpoint,
         Handle_Open_Reader'Access);
      Rose.Server.Register_Handler
        (Server_Context,
         Open_Seekable_Reader_Endpoint,
         Handle_Open_Seekable_Reader'Access);
      Rose.Server.Register_Handler
        (Server_Context,
         Write_Endpoint,
         Handle_Write'Access);
      Rose.Server.Register_Handler
        (Server_Context,
         Truncate_Endpoint,
         Handle_Truncate'Access);
      Rose.Server.Register_Handler
        (Server_Context,
         New_Version_Endpoint,
         Handle_New_Version'Access);
      Rose.Server.Register_Handler
        (Server_Context,
         Commit_Endpoint,
         Handle_Commit'Access);
      Rose.Server.Register_Handler
        (Server_Context,
         Rollback_Endpoint,
         Handle_Rollback'Access);
      Rose.Server.Register_Handler
        (Server_Context,
         Release_Endpoint,
         Handle_Release'Access);
   end Attach_Interface;

   -------------------
   -- Create_Server --
   -------------------

   procedure Create_Server
     (Server_Context       : in out Rose.Server.Server_Context;
      Size                 : Size_Handler;
      Open_Reader          : Open_Reader_Handler;
      Open_Seekable_Reader : Open_Seekable_Reader_Handler;
      Write                : Write_Handler;
      Truncate             : Truncate_Handler;
      New_Version          : New_Version_Handler;
      Commit               : Commit_Handler;
      Rollback             : Rollback_Handler;
      Release              : Release_Handler;
      Instanced            : Boolean := False)
   is
   begin
      Attach_Interface
        (Server_Context,
         Size,
         Open_Reader,
         Open_Seekable_Reader,
         Write,
         Truncate,
         New_Version,
         Commit,
         Rollback,
         Release,
         Instanced);
   end Create_Server;

   --------------------
   -- Get_Commit_Cap --
   --------------------

   function Get_Commit_Cap return Rose.Capabilities.Capability is (Commit_Cap);

   -------------------------
   -- Get_New_Version_Cap --
   -------------------------

   function Get_New_Version_Cap
      return Rose.Capabilities.Capability
   is (New_Version_Cap);

   -------------------------
   -- Get_Open_Reader_Cap --
   -------------------------

   function Get_Open_Reader_Cap
      return Rose.Capabilities.Capability
   is (Open_Reader_Cap);

   ----------------------------------
   -- Get_Open_Seekable_Reader_Cap --
   ----------------------------------

   function Get_Open_Seekable_Reader_Cap
      return Rose.Capabilities.Capability
   is (Open_Seekable_Reader_Cap);

   ---------------------
   -- Get_Release_Cap --
   ---------------------

   function Get_Release_Cap
      return Rose.Capabilities.Capability
   is (Release_Cap);

   ----------------------
   -- Get_Rollback_Cap --
   ----------------------

   function Get_Rollback_Cap
      return Rose.Capabilities.Capability
   is (Rollback_Cap);

   ------------------
   -- Get_Size_Cap --
   ------------------

   function Get_Size_Cap return Rose.Capabilities.Capability is (Size_Cap);

   ----------------------
   -- Get_Truncate_Cap --
   ----------------------

   function Get_Truncate_Cap
      return Rose.Capabilities.Capability
   is (Truncate_Cap);

   -------------------
   -- Get_Write_Cap --
   -------------------

   function Get_Write_Cap return Rose.Capabilities.Capability is (Write_Cap);

   -------------------
   -- Handle_Commit --
   -------------------

   procedure Handle_Commit
     (Parameters : in out Rose.Invocation.Invocation_Record)
   is
   begin
      Local_Commit (Parameters.Identifier);
      Rose.System_Calls.Initialize_Reply (Parameters, Parameters.Reply_Cap);
   end Handle_Commit;

   -------------------------------
   -- Handle_Get_File_Interface --
   -------------------------------

   procedure Handle_Get_File_Interface
     (Parameters : in out Rose.Invocation.Invocation_Record)
   is
      use type Rose.Capabilities.Capability;
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
            if Size_Cap = Rose.Capabilities.Null_Capability then
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
            else
               Cap := Size_Cap;
            end if;
            Rose.System_Calls.Send_Cap (Parameters, Cap);
         end if;
         if 1 in First .. (First + Page - 1) then
            if Open_Reader_Cap = Rose.Capabilities.Null_Capability then
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
            else
               Cap := Open_Reader_Cap;
            end if;
            Rose.System_Calls.Send_Cap (Parameters, Cap);
         end if;
         if 2 in First .. (First + Page - 1) then
            if Open_Seekable_Reader_Cap = Rose.Capabilities.Null_Capability
            then
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
            else
               Cap := Open_Seekable_Reader_Cap;
            end if;
            Rose.System_Calls.Send_Cap (Parameters, Cap);
         end if;
      end if;
   end Handle_Get_File_Interface;

   -----------------------------------
   -- Handle_Get_Resource_Interface --
   -----------------------------------

   procedure Handle_Get_Resource_Interface
     (Parameters : in out Rose.Invocation.Invocation_Record)
   is
      use type Rose.Capabilities.Capability;
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
            if Release_Cap = Rose.Capabilities.Null_Capability then
               if not Rose.Server.Has_Instance
                 (Server_Instance,
                  Release_Endpoint,
                  Identifier)
               then
                  Rose.Server.Set_Instance_Cap
                    (Server_Instance,
                     Release_Endpoint,
                     Identifier,
                     Rose.Server.Create_Endpoint
                       (Release_Endpoint,
                        Identifier));
               end if;
               Cap :=
                 Rose.Server.Get_Instance_Cap
                   (Server_Instance,
                    Release_Endpoint,
                    Identifier);
            else
               Cap := Release_Cap;
            end if;
            Rose.System_Calls.Send_Cap (Parameters, Cap);
         end if;
      end if;
   end Handle_Get_Resource_Interface;

   ----------------------------------------
   -- Handle_Get_Stream_Writer_Interface --
   ----------------------------------------

   procedure Handle_Get_Stream_Writer_Interface
     (Parameters : in out Rose.Invocation.Invocation_Record)
   is
      use type Rose.Capabilities.Capability;
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
            if Write_Cap = Rose.Capabilities.Null_Capability then
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
            else
               Cap := Write_Cap;
            end if;
            Rose.System_Calls.Send_Cap (Parameters, Cap);
         end if;
      end if;
   end Handle_Get_Stream_Writer_Interface;

   ----------------------------------------
   -- Handle_Get_Transactional_Interface --
   ----------------------------------------

   procedure Handle_Get_Transactional_Interface
     (Parameters : in out Rose.Invocation.Invocation_Record)
   is
      use type Rose.Capabilities.Capability;
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
      if First >= 2 then
         Rose.System_Calls.Send_Error
           (Parameters,
            Rose.Invocation.Invalid_Operation);
      else
         if 0 in First .. (First + Page - 1) then
            if Commit_Cap = Rose.Capabilities.Null_Capability then
               if not Rose.Server.Has_Instance
                 (Server_Instance,
                  Commit_Endpoint,
                  Identifier)
               then
                  Rose.Server.Set_Instance_Cap
                    (Server_Instance,
                     Commit_Endpoint,
                     Identifier,
                     Rose.Server.Create_Endpoint
                       (Commit_Endpoint,
                        Identifier));
               end if;
               Cap :=
                 Rose.Server.Get_Instance_Cap
                   (Server_Instance,
                    Commit_Endpoint,
                    Identifier);
            else
               Cap := Commit_Cap;
            end if;
            Rose.System_Calls.Send_Cap (Parameters, Cap);
         end if;
         if 1 in First .. (First + Page - 1) then
            if Rollback_Cap = Rose.Capabilities.Null_Capability then
               if not Rose.Server.Has_Instance
                 (Server_Instance,
                  Rollback_Endpoint,
                  Identifier)
               then
                  Rose.Server.Set_Instance_Cap
                    (Server_Instance,
                     Rollback_Endpoint,
                     Identifier,
                     Rose.Server.Create_Endpoint
                       (Rollback_Endpoint,
                        Identifier));
               end if;
               Cap :=
                 Rose.Server.Get_Instance_Cap
                   (Server_Instance,
                    Rollback_Endpoint,
                    Identifier);
            else
               Cap := Rollback_Cap;
            end if;
            Rose.System_Calls.Send_Cap (Parameters, Cap);
         end if;
      end if;
   end Handle_Get_Transactional_Interface;

   ------------------------------------------------------
   -- Handle_Get_Transactional_Writable_File_Interface --
   ------------------------------------------------------

   procedure Handle_Get_Transactional_Writable_File_Interface
     (Parameters : in out Rose.Invocation.Invocation_Record)
   is
      use type Rose.Capabilities.Capability;
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
         if First >= 9 then
            Rose.System_Calls.Send_Error
              (Parameters,
               Rose.Invocation.Invalid_Operation);
         else
            if 0 in First .. (First + Page - 1) then
               if Size_Cap = Rose.Capabilities.Null_Capability then
                  if not Rose.Server.Has_Instance
                    (Server_Instance,
                     Size_Endpoint,
                     Identifier)
                  then
                     Rose.Server.Set_Instance_Cap
                       (Server_Instance,
                        Size_Endpoint,
                        Identifier,
                        Rose.Server.Create_Endpoint
                          (Size_Endpoint,
                           Identifier));
                  end if;
                  Cap :=
                    Rose.Server.Get_Instance_Cap
                      (Server_Instance,
                       Size_Endpoint,
                       Identifier);
               else
                  Cap := Size_Cap;
               end if;
               Rose.System_Calls.Send_Cap (Parameters, Cap);
            end if;
            if 1 in First .. (First + Page - 1) then
               if Open_Reader_Cap = Rose.Capabilities.Null_Capability then
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
               else
                  Cap := Open_Reader_Cap;
               end if;
               Rose.System_Calls.Send_Cap (Parameters, Cap);
            end if;
            if 2 in First .. (First + Page - 1) then
               if Open_Seekable_Reader_Cap = Rose.Capabilities.Null_Capability
               then
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
               else
                  Cap := Open_Seekable_Reader_Cap;
               end if;
               Rose.System_Calls.Send_Cap (Parameters, Cap);
            end if;
            if 3 in First .. (First + Page - 1) then
               if Write_Cap = Rose.Capabilities.Null_Capability then
                  if not Rose.Server.Has_Instance
                    (Server_Instance,
                     Write_Endpoint,
                     Identifier)
                  then
                     Rose.Server.Set_Instance_Cap
                       (Server_Instance,
                        Write_Endpoint,
                        Identifier,
                        Rose.Server.Create_Endpoint
                          (Write_Endpoint,
                           Identifier));
                  end if;
                  Cap :=
                    Rose.Server.Get_Instance_Cap
                      (Server_Instance,
                       Write_Endpoint,
                       Identifier);
               else
                  Cap := Write_Cap;
               end if;
               Rose.System_Calls.Send_Cap (Parameters, Cap);
            end if;
            if 4 in First .. (First + Page - 1) then
               if Truncate_Cap = Rose.Capabilities.Null_Capability then
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
               else
                  Cap := Truncate_Cap;
               end if;
               Rose.System_Calls.Send_Cap (Parameters, Cap);
            end if;
            if 5 in First .. (First + Page - 1) then
               if New_Version_Cap = Rose.Capabilities.Null_Capability then
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
               else
                  Cap := New_Version_Cap;
               end if;
               Rose.System_Calls.Send_Cap (Parameters, Cap);
            end if;
            if 6 in First .. (First + Page - 1) then
               if Commit_Cap = Rose.Capabilities.Null_Capability then
                  if not Rose.Server.Has_Instance
                    (Server_Instance,
                     Commit_Endpoint,
                     Identifier)
                  then
                     Rose.Server.Set_Instance_Cap
                       (Server_Instance,
                        Commit_Endpoint,
                        Identifier,
                        Rose.Server.Create_Endpoint
                          (Commit_Endpoint,
                           Identifier));
                  end if;
                  Cap :=
                    Rose.Server.Get_Instance_Cap
                      (Server_Instance,
                       Commit_Endpoint,
                       Identifier);
               else
                  Cap := Commit_Cap;
               end if;
               Rose.System_Calls.Send_Cap (Parameters, Cap);
            end if;
            if 7 in First .. (First + Page - 1) then
               if Rollback_Cap = Rose.Capabilities.Null_Capability then
                  if not Rose.Server.Has_Instance
                    (Server_Instance,
                     Rollback_Endpoint,
                     Identifier)
                  then
                     Rose.Server.Set_Instance_Cap
                       (Server_Instance,
                        Rollback_Endpoint,
                        Identifier,
                        Rose.Server.Create_Endpoint
                          (Rollback_Endpoint,
                           Identifier));
                  end if;
                  Cap :=
                    Rose.Server.Get_Instance_Cap
                      (Server_Instance,
                       Rollback_Endpoint,
                       Identifier);
               else
                  Cap := Rollback_Cap;
               end if;
               Rose.System_Calls.Send_Cap (Parameters, Cap);
            end if;
            if 8 in First .. (First + Page - 1) then
               if Release_Cap = Rose.Capabilities.Null_Capability then
                  if not Rose.Server.Has_Instance
                    (Server_Instance,
                     Release_Endpoint,
                     Identifier)
                  then
                     Rose.Server.Set_Instance_Cap
                       (Server_Instance,
                        Release_Endpoint,
                        Identifier,
                        Rose.Server.Create_Endpoint
                          (Release_Endpoint,
                           Identifier));
                  end if;
                  Cap :=
                    Rose.Server.Get_Instance_Cap
                      (Server_Instance,
                       Release_Endpoint,
                       Identifier);
               else
                  Cap := Release_Cap;
               end if;
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
               if Ancestor = 3 then
                  if not Rose.Server.Has_Instance
                    (Server_Instance,
                     Writable_File_Interface,
                     Identifier)
                  then
                     Rose.Server.Set_Instance_Cap
                       (Server_Instance,
                        Writable_File_Interface,
                        Identifier,
                        Rose.Server.Create_Endpoint
                          (Writable_File_Interface,
                           Identifier));
                  end if;
                  Rose.System_Calls.Send_Cap
                    (Parameters,
                     Rose.Server.Get_Instance_Cap
                       (Server_Instance,
                        Writable_File_Interface,
                        Identifier));
               else
                  if Ancestor = 4 then
                     if not Rose.Server.Has_Instance
                       (Server_Instance,
                        Transactional_Interface,
                        Identifier)
                     then
                        Rose.Server.Set_Instance_Cap
                          (Server_Instance,
                           Transactional_Interface,
                           Identifier,
                           Rose.Server.Create_Endpoint
                             (Transactional_Interface,
                              Identifier));
                     end if;
                     Rose.System_Calls.Send_Cap
                       (Parameters,
                        Rose.Server.Get_Instance_Cap
                          (Server_Instance,
                           Transactional_Interface,
                           Identifier));
                  else
                     if Ancestor = 5 then
                        if not Rose.Server.Has_Instance
                          (Server_Instance,
                           Resource_Interface,
                           Identifier)
                        then
                           Rose.Server.Set_Instance_Cap
                             (Server_Instance,
                              Resource_Interface,
                              Identifier,
                              Rose.Server.Create_Endpoint
                                (Resource_Interface,
                                 Identifier));
                        end if;
                        Rose.System_Calls.Send_Cap
                          (Parameters,
                           Rose.Server.Get_Instance_Cap
                             (Server_Instance,
                              Resource_Interface,
                              Identifier));
                     else
                        Rose.System_Calls.Send_Error
                          (Parameters,
                           Rose.Invocation.Invalid_Operation);
                     end if;
                  end if;
               end if;
            end if;
         end if;
      end if;
   end Handle_Get_Transactional_Writable_File_Interface;

   ----------------------------------------
   -- Handle_Get_Writable_File_Interface --
   ----------------------------------------

   procedure Handle_Get_Writable_File_Interface
     (Parameters : in out Rose.Invocation.Invocation_Record)
   is
      use type Rose.Capabilities.Capability;
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
               if Size_Cap = Rose.Capabilities.Null_Capability then
                  if not Rose.Server.Has_Instance
                    (Server_Instance,
                     Size_Endpoint,
                     Identifier)
                  then
                     Rose.Server.Set_Instance_Cap
                       (Server_Instance,
                        Size_Endpoint,
                        Identifier,
                        Rose.Server.Create_Endpoint
                          (Size_Endpoint,
                           Identifier));
                  end if;
                  Cap :=
                    Rose.Server.Get_Instance_Cap
                      (Server_Instance,
                       Size_Endpoint,
                       Identifier);
               else
                  Cap := Size_Cap;
               end if;
               Rose.System_Calls.Send_Cap (Parameters, Cap);
            end if;
            if 1 in First .. (First + Page - 1) then
               if Open_Reader_Cap = Rose.Capabilities.Null_Capability then
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
               else
                  Cap := Open_Reader_Cap;
               end if;
               Rose.System_Calls.Send_Cap (Parameters, Cap);
            end if;
            if 2 in First .. (First + Page - 1) then
               if Open_Seekable_Reader_Cap = Rose.Capabilities.Null_Capability
               then
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
               else
                  Cap := Open_Seekable_Reader_Cap;
               end if;
               Rose.System_Calls.Send_Cap (Parameters, Cap);
            end if;
            if 3 in First .. (First + Page - 1) then
               if Write_Cap = Rose.Capabilities.Null_Capability then
                  if not Rose.Server.Has_Instance
                    (Server_Instance,
                     Write_Endpoint,
                     Identifier)
                  then
                     Rose.Server.Set_Instance_Cap
                       (Server_Instance,
                        Write_Endpoint,
                        Identifier,
                        Rose.Server.Create_Endpoint
                          (Write_Endpoint,
                           Identifier));
                  end if;
                  Cap :=
                    Rose.Server.Get_Instance_Cap
                      (Server_Instance,
                       Write_Endpoint,
                       Identifier);
               else
                  Cap := Write_Cap;
               end if;
               Rose.System_Calls.Send_Cap (Parameters, Cap);
            end if;
            if 4 in First .. (First + Page - 1) then
               if Truncate_Cap = Rose.Capabilities.Null_Capability then
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
               else
                  Cap := Truncate_Cap;
               end if;
               Rose.System_Calls.Send_Cap (Parameters, Cap);
            end if;
            if 5 in First .. (First + Page - 1) then
               if New_Version_Cap = Rose.Capabilities.Null_Capability then
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
               else
                  Cap := New_Version_Cap;
               end if;
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
      Result : constant Rose.Capabilities.Capability :=
        Local_New_Version (Parameters.Identifier);
   begin
      Rose.System_Calls.Initialize_Reply (Parameters, Parameters.Reply_Cap);
      Rose.System_Calls.Send_Cap (Parameters, Result);
   end Handle_New_Version;

   ------------------------
   -- Handle_Open_Reader --
   ------------------------

   procedure Handle_Open_Reader
     (Parameters : in out Rose.Invocation.Invocation_Record)
   is
      Result : constant Rose.Capabilities.Capability :=
        Local_Open_Reader (Parameters.Identifier);
   begin
      Rose.System_Calls.Initialize_Reply (Parameters, Parameters.Reply_Cap);
      Rose.System_Calls.Send_Cap (Parameters, Result);
   end Handle_Open_Reader;

   ---------------------------------
   -- Handle_Open_Seekable_Reader --
   ---------------------------------

   procedure Handle_Open_Seekable_Reader
     (Parameters : in out Rose.Invocation.Invocation_Record)
   is
      Result : constant Rose.Capabilities.Capability :=
        Local_Open_Seekable_Reader (Parameters.Identifier);
   begin
      Rose.System_Calls.Initialize_Reply (Parameters, Parameters.Reply_Cap);
      Rose.System_Calls.Send_Cap (Parameters, Result);
   end Handle_Open_Seekable_Reader;

   --------------------
   -- Handle_Release --
   --------------------

   procedure Handle_Release
     (Parameters : in out Rose.Invocation.Invocation_Record)
   is
   begin
      Local_Release (Parameters.Identifier);
      Rose.Server.Remove_Instance (Server_Instance, Parameters.Identifier);
      Rose.System_Calls.Initialize_Reply (Parameters, Parameters.Reply_Cap);
   end Handle_Release;

   ---------------------
   -- Handle_Rollback --
   ---------------------

   procedure Handle_Rollback
     (Parameters : in out Rose.Invocation.Invocation_Record)
   is
   begin
      Local_Rollback (Parameters.Identifier);
      Rose.System_Calls.Initialize_Reply (Parameters, Parameters.Reply_Cap);
   end Handle_Rollback;

   -----------------
   -- Handle_Size --
   -----------------

   procedure Handle_Size
     (Parameters : in out Rose.Invocation.Invocation_Record)
   is
      Result : constant System.Storage_Elements.Storage_Count :=
        Local_Size (Parameters.Identifier);
   begin
      Rose.System_Calls.Initialize_Reply (Parameters, Parameters.Reply_Cap);
      Rose.System_Calls.Send_Storage_Offset (Parameters, Result);
   end Handle_Size;

   ---------------------
   -- Handle_Truncate --
   ---------------------

   procedure Handle_Truncate
     (Parameters : in out Rose.Invocation.Invocation_Record)
   is
      Size : constant System.Storage_Elements.Storage_Count :=
        System.Storage_Elements.Storage_Count
          (Rose.System_Calls.Get_Word_32 (Parameters, 0));
   begin
      Local_Truncate (Parameters.Identifier, Size);
      Rose.System_Calls.Initialize_Reply (Parameters, Parameters.Reply_Cap);
   end Handle_Truncate;

   ------------------
   -- Handle_Write --
   ------------------

   procedure Handle_Write
     (Parameters : in out Rose.Invocation.Invocation_Record)
   is
      Buffer : System.Storage_Elements.Storage_Array
        (1 .. Parameters.Buffer_Length)
        with Import, Address => Parameters.Buffer_Address;
   begin
      Local_Write (Parameters.Identifier, Buffer);
      Rose.System_Calls.Initialize_Reply (Parameters, Parameters.Reply_Cap);
   end Handle_Write;

   -----------------------
   -- Publish_Interface --
   -----------------------

   procedure Publish_Interface
     (Server_Context       : in out Rose.Server.Server_Context;
      Size                 : Size_Handler;
      Open_Reader          : Open_Reader_Handler;
      Open_Seekable_Reader : Open_Seekable_Reader_Handler;
      Write                : Write_Handler;
      Truncate             : Truncate_Handler;
      New_Version          : New_Version_Handler;
      Commit               : Commit_Handler;
      Rollback             : Rollback_Handler;
      Release              : Release_Handler)
   is
   begin
      Local_Size := Size;
      Local_Open_Reader := Open_Reader;
      Local_Open_Seekable_Reader := Open_Seekable_Reader;
      Local_Write := Write;
      Local_Truncate := Truncate;
      Local_New_Version := New_Version;
      Local_Commit := Commit;
      Local_Rollback := Rollback;
      Local_Release := Release;
      Size_Cap := Rose.Server.Create_Endpoint (Size_Endpoint);
      Open_Reader_Cap := Rose.Server.Create_Endpoint (Open_Reader_Endpoint);
      Open_Seekable_Reader_Cap :=
        Rose.Server.Create_Endpoint (Open_Seekable_Reader_Endpoint);
      Write_Cap := Rose.Server.Create_Endpoint (Write_Endpoint);
      Truncate_Cap := Rose.Server.Create_Endpoint (Truncate_Endpoint);
      New_Version_Cap := Rose.Server.Create_Endpoint (New_Version_Endpoint);
      Commit_Cap := Rose.Server.Create_Endpoint (Commit_Endpoint);
      Rollback_Cap := Rose.Server.Create_Endpoint (Rollback_Endpoint);
      Release_Cap := Rose.Server.Create_Endpoint (Release_Endpoint);
      Published_Cap :=
        Rose.Server.Create_Endpoint (Transactional_Writable_File_Interface);
      Rose.Server.Register_Handler
        (Server_Context,
         File_Interface,
         Handle_Get_File_Interface'Access);
      Rose.Server.Register_Handler
        (Server_Context,
         Stream_Writer_Interface,
         Handle_Get_Stream_Writer_Interface'Access);
      Rose.Server.Register_Handler
        (Server_Context,
         Writable_File_Interface,
         Handle_Get_Writable_File_Interface'Access);
      Rose.Server.Register_Handler
        (Server_Context,
         Transactional_Interface,
         Handle_Get_Transactional_Interface'Access);
      Rose.Server.Register_Handler
        (Server_Context,
         Resource_Interface,
         Handle_Get_Resource_Interface'Access);
      Rose.Server.Register_Handler
        (Server_Context,
         Transactional_Writable_File_Interface,
         Handle_Get_Transactional_Writable_File_Interface'Access);
      Rose.Server.Register_Handler
        (Server_Context,
         Size_Endpoint,
         Handle_Size'Access);
      Rose.Server.Register_Handler
        (Server_Context,
         Open_Reader_Endpoint,
         Handle_Open_Reader'Access);
      Rose.Server.Register_Handler
        (Server_Context,
         Open_Seekable_Reader_Endpoint,
         Handle_Open_Seekable_Reader'Access);
      Rose.Server.Register_Handler
        (Server_Context,
         Write_Endpoint,
         Handle_Write'Access);
      Rose.Server.Register_Handler
        (Server_Context,
         Truncate_Endpoint,
         Handle_Truncate'Access);
      Rose.Server.Register_Handler
        (Server_Context,
         New_Version_Endpoint,
         Handle_New_Version'Access);
      Rose.Server.Register_Handler
        (Server_Context,
         Commit_Endpoint,
         Handle_Commit'Access);
      Rose.Server.Register_Handler
        (Server_Context,
         Rollback_Endpoint,
         Handle_Rollback'Access);
      Rose.Server.Register_Handler
        (Server_Context,
         Release_Endpoint,
         Handle_Release'Access);
      Rose.Server.Publish_Interface (Published_Cap);
   end Publish_Interface;

   ---------------------
   -- Remove_Instance --
   ---------------------

   procedure Remove_Instance
     (Identifier : Rose.Objects.Capability_Identifier)
   is
   begin
      Rose.Server.Remove_Instance (Server_Instance, Identifier);
   end Remove_Instance;

end Rose.Interfaces.Transactional_Writable_File.Server;
