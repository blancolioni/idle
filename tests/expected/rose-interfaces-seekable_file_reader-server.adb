with Rose.Invocation;
with Rose.System_Calls;

package body Rose.Interfaces.Seekable_File_Reader.Server is

   Server_Instance : Rose.Server.Server_Instance;

   Local_Read      : Read_Handler;

   Read_Cap        : Rose.Capabilities.Capability :=
     Rose.Capabilities.Null_Capability;

   Local_Release   : Release_Handler;

   Release_Cap     : Rose.Capabilities.Capability :=
     Rose.Capabilities.Null_Capability;

   Local_Seek      : Seek_Handler;

   Seek_Cap        : Rose.Capabilities.Capability :=
     Rose.Capabilities.Null_Capability;

   Published_Cap   : Rose.Capabilities.Capability :=
     Rose.Capabilities.Null_Capability;

   procedure Handle_Get_Stream_Reader_Interface
     (Parameters : in out Rose.Invocation.Invocation_Record);

   procedure Handle_Get_Resource_Interface
     (Parameters : in out Rose.Invocation.Invocation_Record);

   procedure Handle_Get_File_Reader_Interface
     (Parameters : in out Rose.Invocation.Invocation_Record);

   procedure Handle_Get_Seekable_Interface
     (Parameters : in out Rose.Invocation.Invocation_Record);

   procedure Handle_Get_Seekable_File_Reader_Interface
     (Parameters : in out Rose.Invocation.Invocation_Record);

   procedure Handle_Read
     (Parameters : in out Rose.Invocation.Invocation_Record);

   procedure Handle_Release
     (Parameters : in out Rose.Invocation.Invocation_Record);

   procedure Handle_Seek
     (Parameters : in out Rose.Invocation.Invocation_Record);

   ----------------------
   -- Attach_Interface --
   ----------------------

   procedure Attach_Interface
     (Server_Context : in out Rose.Server.Server_Context;
      Read           : Read_Handler;
      Release        : Release_Handler;
      Seek           : Seek_Handler;
      Instanced      : Boolean := False)
   is
   begin
      Local_Read := Read;
      Local_Release := Release;
      Local_Seek := Seek;
      Rose.Server.Register_Handler
        (Server_Context,
         Stream_Reader_Interface,
         Handle_Get_Stream_Reader_Interface'Access);
      Rose.Server.Register_Handler
        (Server_Context,
         Resource_Interface,
         Handle_Get_Resource_Interface'Access);
      Rose.Server.Register_Handler
        (Server_Context,
         File_Reader_Interface,
         Handle_Get_File_Reader_Interface'Access);
      Rose.Server.Register_Handler
        (Server_Context,
         Seekable_Interface,
         Handle_Get_Seekable_Interface'Access);
      Rose.Server.Register_Handler
        (Server_Context,
         Seekable_File_Reader_Interface,
         Handle_Get_Seekable_File_Reader_Interface'Access);
      if not Instanced then
         Read_Cap := Rose.Server.Create_Endpoint (Read_Endpoint);
         Release_Cap := Rose.Server.Create_Endpoint (Release_Endpoint);
         Seek_Cap := Rose.Server.Create_Endpoint (Seek_Endpoint);
         Rose.Server.Create_Anonymous_Endpoint (Stream_Reader_Interface);
         Rose.Server.Create_Anonymous_Endpoint (Resource_Interface);
         Rose.Server.Create_Anonymous_Endpoint (File_Reader_Interface);
         Rose.Server.Create_Anonymous_Endpoint (Seekable_Interface);
         Rose.Server.Create_Anonymous_Endpoint
           (Seekable_File_Reader_Interface);
      end if;
      Rose.Server.Register_Handler
        (Server_Context,
         Read_Endpoint,
         Handle_Read'Access);
      Rose.Server.Register_Handler
        (Server_Context,
         Release_Endpoint,
         Handle_Release'Access);
      Rose.Server.Register_Handler
        (Server_Context,
         Seek_Endpoint,
         Handle_Seek'Access);
   end Attach_Interface;

   -------------------
   -- Create_Server --
   -------------------

   procedure Create_Server
     (Server_Context : in out Rose.Server.Server_Context;
      Read           : Read_Handler;
      Release        : Release_Handler;
      Seek           : Seek_Handler;
      Instanced      : Boolean := False)
   is
   begin
      Attach_Interface (Server_Context, Read, Release, Seek, Instanced);
   end Create_Server;

   ------------------
   -- Get_Read_Cap --
   ------------------

   function Get_Read_Cap return Rose.Capabilities.Capability is (Read_Cap);

   ---------------------
   -- Get_Release_Cap --
   ---------------------

   function Get_Release_Cap
      return Rose.Capabilities.Capability
   is (Release_Cap);

   ------------------
   -- Get_Seek_Cap --
   ------------------

   function Get_Seek_Cap return Rose.Capabilities.Capability is (Seek_Cap);

   --------------------------------------
   -- Handle_Get_File_Reader_Interface --
   --------------------------------------

   procedure Handle_Get_File_Reader_Interface
     (Parameters : in out Rose.Invocation.Invocation_Record)
   is
      use type Rose.Capabilities.Capability;
      Cap        : Rose.Capabilities.Capability;
      Identifier : constant Rose.Objects.Capability_Identifier :=
        Parameters.Identifier;
      Ancestor   : Natural := 0;
   begin
      if Parameters.Control.Flags (Rose.Invocation.Send_Words) then
         Ancestor := Natural (Parameters.Data (0));
      end if;
      Rose.System_Calls.Initialize_Reply (Parameters, Parameters.Reply_Cap);
      if Ancestor = 0 then
         if Read_Cap = Rose.Capabilities.Null_Capability then
            if not Rose.Server.Has_Instance
              (Server_Instance,
               Read_Endpoint,
               Identifier)
            then
               Rose.Server.Set_Instance_Cap
                 (Server_Instance,
                  Read_Endpoint,
                  Identifier,
                  Rose.Server.Create_Endpoint (Read_Endpoint, Identifier));
            end if;
            Cap :=
              Rose.Server.Get_Instance_Cap
                (Server_Instance,
                 Read_Endpoint,
                 Identifier);
         else
            Cap := Read_Cap;
         end if;
         Rose.System_Calls.Send_Cap (Parameters, Cap);
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
                  Rose.Server.Create_Endpoint (Release_Endpoint, Identifier));
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
      else
         if Ancestor = 1 then
            if not Rose.Server.Has_Instance
              (Server_Instance,
               Stream_Reader_Interface,
               Identifier)
            then
               Rose.Server.Set_Instance_Cap
                 (Server_Instance,
                  Stream_Reader_Interface,
                  Identifier,
                  Rose.Server.Create_Endpoint
                    (Stream_Reader_Interface,
                     Identifier));
            end if;
            Rose.System_Calls.Send_Cap
              (Parameters,
               Rose.Server.Get_Instance_Cap
                 (Server_Instance,
                  Stream_Reader_Interface,
                  Identifier));
         else
            if Ancestor = 2 then
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
   end Handle_Get_File_Reader_Interface;

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
   begin
      Rose.System_Calls.Initialize_Reply (Parameters, Parameters.Reply_Cap);
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
               Rose.Server.Create_Endpoint (Release_Endpoint, Identifier));
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
   end Handle_Get_Resource_Interface;

   -----------------------------------------------
   -- Handle_Get_Seekable_File_Reader_Interface --
   -----------------------------------------------

   procedure Handle_Get_Seekable_File_Reader_Interface
     (Parameters : in out Rose.Invocation.Invocation_Record)
   is
      use type Rose.Capabilities.Capability;
      Cap        : Rose.Capabilities.Capability;
      Identifier : constant Rose.Objects.Capability_Identifier :=
        Parameters.Identifier;
      Ancestor   : Natural := 0;
   begin
      if Parameters.Control.Flags (Rose.Invocation.Send_Words) then
         Ancestor := Natural (Parameters.Data (0));
      end if;
      Rose.System_Calls.Initialize_Reply (Parameters, Parameters.Reply_Cap);
      if Ancestor = 0 then
         if Read_Cap = Rose.Capabilities.Null_Capability then
            if not Rose.Server.Has_Instance
              (Server_Instance,
               Read_Endpoint,
               Identifier)
            then
               Rose.Server.Set_Instance_Cap
                 (Server_Instance,
                  Read_Endpoint,
                  Identifier,
                  Rose.Server.Create_Endpoint (Read_Endpoint, Identifier));
            end if;
            Cap :=
              Rose.Server.Get_Instance_Cap
                (Server_Instance,
                 Read_Endpoint,
                 Identifier);
         else
            Cap := Read_Cap;
         end if;
         Rose.System_Calls.Send_Cap (Parameters, Cap);
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
                  Rose.Server.Create_Endpoint (Release_Endpoint, Identifier));
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
         if Seek_Cap = Rose.Capabilities.Null_Capability then
            if not Rose.Server.Has_Instance
              (Server_Instance,
               Seek_Endpoint,
               Identifier)
            then
               Rose.Server.Set_Instance_Cap
                 (Server_Instance,
                  Seek_Endpoint,
                  Identifier,
                  Rose.Server.Create_Endpoint (Seek_Endpoint, Identifier));
            end if;
            Cap :=
              Rose.Server.Get_Instance_Cap
                (Server_Instance,
                 Seek_Endpoint,
                 Identifier);
         else
            Cap := Seek_Cap;
         end if;
         Rose.System_Calls.Send_Cap (Parameters, Cap);
      else
         if Ancestor = 1 then
            if not Rose.Server.Has_Instance
              (Server_Instance,
               Stream_Reader_Interface,
               Identifier)
            then
               Rose.Server.Set_Instance_Cap
                 (Server_Instance,
                  Stream_Reader_Interface,
                  Identifier,
                  Rose.Server.Create_Endpoint
                    (Stream_Reader_Interface,
                     Identifier));
            end if;
            Rose.System_Calls.Send_Cap
              (Parameters,
               Rose.Server.Get_Instance_Cap
                 (Server_Instance,
                  Stream_Reader_Interface,
                  Identifier));
         else
            if Ancestor = 2 then
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
               if Ancestor = 3 then
                  if not Rose.Server.Has_Instance
                    (Server_Instance,
                     File_Reader_Interface,
                     Identifier)
                  then
                     Rose.Server.Set_Instance_Cap
                       (Server_Instance,
                        File_Reader_Interface,
                        Identifier,
                        Rose.Server.Create_Endpoint
                          (File_Reader_Interface,
                           Identifier));
                  end if;
                  Rose.System_Calls.Send_Cap
                    (Parameters,
                     Rose.Server.Get_Instance_Cap
                       (Server_Instance,
                        File_Reader_Interface,
                        Identifier));
               else
                  if Ancestor = 4 then
                     if not Rose.Server.Has_Instance
                       (Server_Instance,
                        Seekable_Interface,
                        Identifier)
                     then
                        Rose.Server.Set_Instance_Cap
                          (Server_Instance,
                           Seekable_Interface,
                           Identifier,
                           Rose.Server.Create_Endpoint
                             (Seekable_Interface,
                              Identifier));
                     end if;
                     Rose.System_Calls.Send_Cap
                       (Parameters,
                        Rose.Server.Get_Instance_Cap
                          (Server_Instance,
                           Seekable_Interface,
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
   end Handle_Get_Seekable_File_Reader_Interface;

   -----------------------------------
   -- Handle_Get_Seekable_Interface --
   -----------------------------------

   procedure Handle_Get_Seekable_Interface
     (Parameters : in out Rose.Invocation.Invocation_Record)
   is
      use type Rose.Capabilities.Capability;
      Cap        : Rose.Capabilities.Capability;
      Identifier : constant Rose.Objects.Capability_Identifier :=
        Parameters.Identifier;
   begin
      Rose.System_Calls.Initialize_Reply (Parameters, Parameters.Reply_Cap);
      if Seek_Cap = Rose.Capabilities.Null_Capability then
         if not Rose.Server.Has_Instance
           (Server_Instance,
            Seek_Endpoint,
            Identifier)
         then
            Rose.Server.Set_Instance_Cap
              (Server_Instance,
               Seek_Endpoint,
               Identifier,
               Rose.Server.Create_Endpoint (Seek_Endpoint, Identifier));
         end if;
         Cap :=
           Rose.Server.Get_Instance_Cap
             (Server_Instance,
              Seek_Endpoint,
              Identifier);
      else
         Cap := Seek_Cap;
      end if;
      Rose.System_Calls.Send_Cap (Parameters, Cap);
   end Handle_Get_Seekable_Interface;

   ----------------------------------------
   -- Handle_Get_Stream_Reader_Interface --
   ----------------------------------------

   procedure Handle_Get_Stream_Reader_Interface
     (Parameters : in out Rose.Invocation.Invocation_Record)
   is
      use type Rose.Capabilities.Capability;
      Cap        : Rose.Capabilities.Capability;
      Identifier : constant Rose.Objects.Capability_Identifier :=
        Parameters.Identifier;
   begin
      Rose.System_Calls.Initialize_Reply (Parameters, Parameters.Reply_Cap);
      if Read_Cap = Rose.Capabilities.Null_Capability then
         if not Rose.Server.Has_Instance
           (Server_Instance,
            Read_Endpoint,
            Identifier)
         then
            Rose.Server.Set_Instance_Cap
              (Server_Instance,
               Read_Endpoint,
               Identifier,
               Rose.Server.Create_Endpoint (Read_Endpoint, Identifier));
         end if;
         Cap :=
           Rose.Server.Get_Instance_Cap
             (Server_Instance,
              Read_Endpoint,
              Identifier);
      else
         Cap := Read_Cap;
      end if;
      Rose.System_Calls.Send_Cap (Parameters, Cap);
   end Handle_Get_Stream_Reader_Interface;

   -----------------
   -- Handle_Read --
   -----------------

   procedure Handle_Read
     (Parameters : in out Rose.Invocation.Invocation_Record)
   is
   begin
      declare
         Buffer : System.Storage_Elements.Storage_Array
           (1 .. Parameters.Buffer_Length)
           with Import, Address => Parameters.Buffer_Address;
         Last   : System.Storage_Elements.Storage_Count;
      begin
         Local_Read (Parameters.Identifier, Buffer, Last);
         Rose.System_Calls.Initialize_Reply (Parameters, Parameters.Reply_Cap);
         Rose.System_Calls.Send_Storage_Offset (Parameters, Last);
      exception
         when others =>
            Rose.System_Calls.Initialize_Reply
              (Parameters,
               Parameters.Reply_Cap);
            Rose.System_Calls.Send_Error
              (Parameters,
               Rose.Invocation.Exception_Raised);
      end;
   end Handle_Read;

   --------------------
   -- Handle_Release --
   --------------------

   procedure Handle_Release
     (Parameters : in out Rose.Invocation.Invocation_Record)
   is
   begin
      begin
         Local_Release (Parameters.Identifier);
         Rose.Server.Remove_Instance (Server_Instance, Parameters.Identifier);
         Rose.System_Calls.Initialize_Reply (Parameters, Parameters.Reply_Cap);
      exception
         when others =>
            Rose.System_Calls.Initialize_Reply
              (Parameters,
               Parameters.Reply_Cap);
            Rose.System_Calls.Send_Error
              (Parameters,
               Rose.Invocation.Exception_Raised);
      end;
   end Handle_Release;

   -----------------
   -- Handle_Seek --
   -----------------

   procedure Handle_Seek
     (Parameters : in out Rose.Invocation.Invocation_Record)
   is
   begin
      declare
         Offset_From_Start : constant Rose.Words.Word_64 :=
           Rose.System_Calls.Get_Word_64 (Parameters, 0);
      begin
         Local_Seek (Parameters.Identifier, Offset_From_Start);
         Rose.System_Calls.Initialize_Reply (Parameters, Parameters.Reply_Cap);
      exception
         when others =>
            Rose.System_Calls.Initialize_Reply
              (Parameters,
               Parameters.Reply_Cap);
            Rose.System_Calls.Send_Error
              (Parameters,
               Rose.Invocation.Exception_Raised);
      end;
   end Handle_Seek;

   -----------------------
   -- Publish_Interface --
   -----------------------

   procedure Publish_Interface
     (Server_Context : in out Rose.Server.Server_Context;
      Read           : Read_Handler;
      Release        : Release_Handler;
      Seek           : Seek_Handler)
   is
   begin
      Local_Read := Read;
      Local_Release := Release;
      Local_Seek := Seek;
      Read_Cap := Rose.Server.Create_Endpoint (Read_Endpoint);
      Release_Cap := Rose.Server.Create_Endpoint (Release_Endpoint);
      Seek_Cap := Rose.Server.Create_Endpoint (Seek_Endpoint);
      Published_Cap :=
        Rose.Server.Create_Endpoint (Seekable_File_Reader_Interface);
      Rose.Server.Register_Handler
        (Server_Context,
         Stream_Reader_Interface,
         Handle_Get_Stream_Reader_Interface'Access);
      Rose.Server.Register_Handler
        (Server_Context,
         Resource_Interface,
         Handle_Get_Resource_Interface'Access);
      Rose.Server.Register_Handler
        (Server_Context,
         File_Reader_Interface,
         Handle_Get_File_Reader_Interface'Access);
      Rose.Server.Register_Handler
        (Server_Context,
         Seekable_Interface,
         Handle_Get_Seekable_Interface'Access);
      Rose.Server.Register_Handler
        (Server_Context,
         Seekable_File_Reader_Interface,
         Handle_Get_Seekable_File_Reader_Interface'Access);
      Rose.Server.Register_Handler
        (Server_Context,
         Read_Endpoint,
         Handle_Read'Access);
      Rose.Server.Register_Handler
        (Server_Context,
         Release_Endpoint,
         Handle_Release'Access);
      Rose.Server.Register_Handler
        (Server_Context,
         Seek_Endpoint,
         Handle_Seek'Access);
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

end Rose.Interfaces.Seekable_File_Reader.Server;
