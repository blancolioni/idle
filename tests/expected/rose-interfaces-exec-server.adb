with Rose.Invocation;
with Rose.System_Calls;

package body Rose.Interfaces.Exec.Server is

   Server_Instance           : Rose.Server.Server_Instance;

   Local_Launch              : Launch_Handler;

   Launch_Cap                : Rose.Capabilities.Capability :=
     Rose.Capabilities.Null_Capability;

   Local_Launch_Command      : Launch_Command_Handler;

   Launch_Command_Cap        : Rose.Capabilities.Capability :=
     Rose.Capabilities.Null_Capability;

   Local_Metadata            : Metadata_Handler;

   Metadata_Cap              : Rose.Capabilities.Capability :=
     Rose.Capabilities.Null_Capability;

   Local_Install             : Install_Handler;

   Install_Cap               : Rose.Capabilities.Capability :=
     Rose.Capabilities.Null_Capability;

   Local_Set_Standard_Output : Set_Standard_Output_Handler;

   Set_Standard_Output_Cap   : Rose.Capabilities.Capability :=
     Rose.Capabilities.Null_Capability;

   Published_Cap             : Rose.Capabilities.Capability :=
     Rose.Capabilities.Null_Capability;

   procedure Handle_Get_Launch_Interface
     (Parameters : in out Rose.Invocation.Invocation_Record);

   procedure Handle_Get_Exec_Interface
     (Parameters : in out Rose.Invocation.Invocation_Record);

   procedure Handle_Launch
     (Parameters : in out Rose.Invocation.Invocation_Record);

   procedure Handle_Launch_Command
     (Parameters : in out Rose.Invocation.Invocation_Record);

   procedure Handle_Metadata
     (Parameters : in out Rose.Invocation.Invocation_Record);

   procedure Handle_Install
     (Parameters : in out Rose.Invocation.Invocation_Record);

   procedure Handle_Set_Standard_Output
     (Parameters : in out Rose.Invocation.Invocation_Record);

   ----------------------
   -- Attach_Interface --
   ----------------------

   procedure Attach_Interface
     (Server_Context      : in out Rose.Server.Server_Context;
      Launch              : Launch_Handler;
      Launch_Command      : Launch_Command_Handler;
      Metadata            : Metadata_Handler;
      Install             : Install_Handler;
      Set_Standard_Output : Set_Standard_Output_Handler;
      Instanced           : Boolean := False)
   is
   begin
      Local_Launch := Launch;
      Local_Launch_Command := Launch_Command;
      Local_Metadata := Metadata;
      Local_Install := Install;
      Local_Set_Standard_Output := Set_Standard_Output;
      Rose.Server.Register_Handler
        (Server_Context,
         Launch_Interface,
         Handle_Get_Launch_Interface'Access);
      Rose.Server.Register_Handler
        (Server_Context,
         Exec_Interface,
         Handle_Get_Exec_Interface'Access);
      if not Instanced then
         Launch_Cap := Rose.Server.Create_Endpoint (Launch_Endpoint);
         Launch_Command_Cap :=
           Rose.Server.Create_Endpoint (Launch_Command_Endpoint);
         Metadata_Cap := Rose.Server.Create_Endpoint (Metadata_Endpoint);
         Install_Cap := Rose.Server.Create_Endpoint (Install_Endpoint);
         Set_Standard_Output_Cap :=
           Rose.Server.Create_Endpoint (Set_Standard_Output_Endpoint);
         Rose.Server.Create_Anonymous_Endpoint (Launch_Interface);
         Rose.Server.Create_Anonymous_Endpoint (Exec_Interface);
      end if;
      Rose.Server.Register_Handler
        (Server_Context,
         Launch_Endpoint,
         Handle_Launch'Access);
      Rose.Server.Register_Handler
        (Server_Context,
         Launch_Command_Endpoint,
         Handle_Launch_Command'Access);
      Rose.Server.Register_Handler
        (Server_Context,
         Metadata_Endpoint,
         Handle_Metadata'Access);
      Rose.Server.Register_Handler
        (Server_Context,
         Install_Endpoint,
         Handle_Install'Access);
      Rose.Server.Register_Handler
        (Server_Context,
         Set_Standard_Output_Endpoint,
         Handle_Set_Standard_Output'Access);
   end Attach_Interface;

   -------------------
   -- Create_Server --
   -------------------

   procedure Create_Server
     (Server_Context      : in out Rose.Server.Server_Context;
      Launch              : Launch_Handler;
      Launch_Command      : Launch_Command_Handler;
      Metadata            : Metadata_Handler;
      Install             : Install_Handler;
      Set_Standard_Output : Set_Standard_Output_Handler;
      Instanced           : Boolean := False)
   is
   begin
      Attach_Interface
        (Server_Context,
         Launch,
         Launch_Command,
         Metadata,
         Install,
         Set_Standard_Output,
         Instanced);
   end Create_Server;

   ---------------------
   -- Get_Install_Cap --
   ---------------------

   function Get_Install_Cap
      return Rose.Capabilities.Capability
   is (Install_Cap);

   --------------------
   -- Get_Launch_Cap --
   --------------------

   function Get_Launch_Cap return Rose.Capabilities.Capability is (Launch_Cap);

   ----------------------------
   -- Get_Launch_Command_Cap --
   ----------------------------

   function Get_Launch_Command_Cap
      return Rose.Capabilities.Capability
   is (Launch_Command_Cap);

   ----------------------
   -- Get_Metadata_Cap --
   ----------------------

   function Get_Metadata_Cap
      return Rose.Capabilities.Capability
   is (Metadata_Cap);

   ---------------------------------
   -- Get_Set_Standard_Output_Cap --
   ---------------------------------

   function Get_Set_Standard_Output_Cap
      return Rose.Capabilities.Capability
   is (Set_Standard_Output_Cap);

   -------------------------------
   -- Handle_Get_Exec_Interface --
   -------------------------------

   procedure Handle_Get_Exec_Interface
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
         if Launch_Cap = Rose.Capabilities.Null_Capability then
            if not Rose.Server.Has_Instance
              (Server_Instance,
               Launch_Endpoint,
               Identifier)
            then
               Rose.Server.Set_Instance_Cap
                 (Server_Instance,
                  Launch_Endpoint,
                  Identifier,
                  Rose.Server.Create_Endpoint (Launch_Endpoint, Identifier));
            end if;
            Cap :=
              Rose.Server.Get_Instance_Cap
                (Server_Instance,
                 Launch_Endpoint,
                 Identifier);
         else
            Cap := Launch_Cap;
         end if;
         Rose.System_Calls.Send_Cap (Parameters, Cap);
         if Launch_Command_Cap = Rose.Capabilities.Null_Capability then
            if not Rose.Server.Has_Instance
              (Server_Instance,
               Launch_Command_Endpoint,
               Identifier)
            then
               Rose.Server.Set_Instance_Cap
                 (Server_Instance,
                  Launch_Command_Endpoint,
                  Identifier,
                  Rose.Server.Create_Endpoint
                    (Launch_Command_Endpoint,
                     Identifier));
            end if;
            Cap :=
              Rose.Server.Get_Instance_Cap
                (Server_Instance,
                 Launch_Command_Endpoint,
                 Identifier);
         else
            Cap := Launch_Command_Cap;
         end if;
         Rose.System_Calls.Send_Cap (Parameters, Cap);
         if Metadata_Cap = Rose.Capabilities.Null_Capability then
            if not Rose.Server.Has_Instance
              (Server_Instance,
               Metadata_Endpoint,
               Identifier)
            then
               Rose.Server.Set_Instance_Cap
                 (Server_Instance,
                  Metadata_Endpoint,
                  Identifier,
                  Rose.Server.Create_Endpoint (Metadata_Endpoint, Identifier));
            end if;
            Cap :=
              Rose.Server.Get_Instance_Cap
                (Server_Instance,
                 Metadata_Endpoint,
                 Identifier);
         else
            Cap := Metadata_Cap;
         end if;
         Rose.System_Calls.Send_Cap (Parameters, Cap);
         if Install_Cap = Rose.Capabilities.Null_Capability then
            if not Rose.Server.Has_Instance
              (Server_Instance,
               Install_Endpoint,
               Identifier)
            then
               Rose.Server.Set_Instance_Cap
                 (Server_Instance,
                  Install_Endpoint,
                  Identifier,
                  Rose.Server.Create_Endpoint (Install_Endpoint, Identifier));
            end if;
            Cap :=
              Rose.Server.Get_Instance_Cap
                (Server_Instance,
                 Install_Endpoint,
                 Identifier);
         else
            Cap := Install_Cap;
         end if;
         Rose.System_Calls.Send_Cap (Parameters, Cap);
         if Set_Standard_Output_Cap = Rose.Capabilities.Null_Capability then
            if not Rose.Server.Has_Instance
              (Server_Instance,
               Set_Standard_Output_Endpoint,
               Identifier)
            then
               Rose.Server.Set_Instance_Cap
                 (Server_Instance,
                  Set_Standard_Output_Endpoint,
                  Identifier,
                  Rose.Server.Create_Endpoint
                    (Set_Standard_Output_Endpoint,
                     Identifier));
            end if;
            Cap :=
              Rose.Server.Get_Instance_Cap
                (Server_Instance,
                 Set_Standard_Output_Endpoint,
                 Identifier);
         else
            Cap := Set_Standard_Output_Cap;
         end if;
         Rose.System_Calls.Send_Cap (Parameters, Cap);
      else
         if Ancestor = 1 then
            if not Rose.Server.Has_Instance
              (Server_Instance,
               Launch_Interface,
               Identifier)
            then
               Rose.Server.Set_Instance_Cap
                 (Server_Instance,
                  Launch_Interface,
                  Identifier,
                  Rose.Server.Create_Endpoint (Launch_Interface, Identifier));
            end if;
            Rose.System_Calls.Send_Cap
              (Parameters,
               Rose.Server.Get_Instance_Cap
                 (Server_Instance,
                  Launch_Interface,
                  Identifier));
         else
            Rose.System_Calls.Send_Error
              (Parameters,
               Rose.Invocation.Invalid_Operation);
         end if;
      end if;
   end Handle_Get_Exec_Interface;

   ---------------------------------
   -- Handle_Get_Launch_Interface --
   ---------------------------------

   procedure Handle_Get_Launch_Interface
     (Parameters : in out Rose.Invocation.Invocation_Record)
   is
      use type Rose.Capabilities.Capability;
      Cap        : Rose.Capabilities.Capability;
      Identifier : constant Rose.Objects.Capability_Identifier :=
        Parameters.Identifier;
   begin
      Rose.System_Calls.Initialize_Reply (Parameters, Parameters.Reply_Cap);
      if Launch_Cap = Rose.Capabilities.Null_Capability then
         if not Rose.Server.Has_Instance
           (Server_Instance,
            Launch_Endpoint,
            Identifier)
         then
            Rose.Server.Set_Instance_Cap
              (Server_Instance,
               Launch_Endpoint,
               Identifier,
               Rose.Server.Create_Endpoint (Launch_Endpoint, Identifier));
         end if;
         Cap :=
           Rose.Server.Get_Instance_Cap
             (Server_Instance,
              Launch_Endpoint,
              Identifier);
      else
         Cap := Launch_Cap;
      end if;
      Rose.System_Calls.Send_Cap (Parameters, Cap);
      if Launch_Command_Cap = Rose.Capabilities.Null_Capability then
         if not Rose.Server.Has_Instance
           (Server_Instance,
            Launch_Command_Endpoint,
            Identifier)
         then
            Rose.Server.Set_Instance_Cap
              (Server_Instance,
               Launch_Command_Endpoint,
               Identifier,
               Rose.Server.Create_Endpoint
                 (Launch_Command_Endpoint,
                  Identifier));
         end if;
         Cap :=
           Rose.Server.Get_Instance_Cap
             (Server_Instance,
              Launch_Command_Endpoint,
              Identifier);
      else
         Cap := Launch_Command_Cap;
      end if;
      Rose.System_Calls.Send_Cap (Parameters, Cap);
      if Metadata_Cap = Rose.Capabilities.Null_Capability then
         if not Rose.Server.Has_Instance
           (Server_Instance,
            Metadata_Endpoint,
            Identifier)
         then
            Rose.Server.Set_Instance_Cap
              (Server_Instance,
               Metadata_Endpoint,
               Identifier,
               Rose.Server.Create_Endpoint (Metadata_Endpoint, Identifier));
         end if;
         Cap :=
           Rose.Server.Get_Instance_Cap
             (Server_Instance,
              Metadata_Endpoint,
              Identifier);
      else
         Cap := Metadata_Cap;
      end if;
      Rose.System_Calls.Send_Cap (Parameters, Cap);
   end Handle_Get_Launch_Interface;

   --------------------
   -- Handle_Install --
   --------------------

   procedure Handle_Install
     (Parameters : in out Rose.Invocation.Invocation_Record)
   is
   begin
      declare
         Executable         : constant Rose.Capabilities.Capability :=
           Parameters.Caps (0);
         Name               : String (1 .. Natural (Parameters.Buffer_Length))
           with Import, Address => Parameters.Buffer_Address;
         Install_Caps       : Rose.Capabilities.Capability_Array
           (1 .. Rose.Invocation.Max_Capabilities);
         Install_Caps_Count : constant Natural :=
           Rose.System_Calls.Copy_Received_Caps (Parameters, 1, Install_Caps);
         Result             : constant Rose.Capabilities.Capability :=
           Local_Install
             (Parameters.Identifier,
              Executable,
              Name,
              Install_Caps (1 .. Install_Caps_Count));
      begin
         Rose.System_Calls.Initialize_Reply (Parameters, Parameters.Reply_Cap);
         Rose.System_Calls.Send_Cap (Parameters, Result);
      exception
         when others =>
            Rose.System_Calls.Initialize_Reply
              (Parameters,
               Parameters.Reply_Cap);
            Rose.System_Calls.Send_Error
              (Parameters,
               Rose.Invocation.Exception_Raised);
      end;
   end Handle_Install;

   -------------------
   -- Handle_Launch --
   -------------------

   procedure Handle_Launch
     (Parameters : in out Rose.Invocation.Invocation_Record)
   is
   begin
      declare
         Caps        : Rose.Capabilities.Capability_Array
           (1 .. Rose.Invocation.Max_Capabilities);
         Caps_Count  : constant Natural :=
           Rose.System_Calls.Copy_Received_Caps (Parameters, 0, Caps);
         Environment : System.Storage_Elements.Storage_Array
           (1 .. Parameters.Buffer_Length)
           with Import, Address => Parameters.Buffer_Address;
         Result      : constant Rose.Capabilities.Capability :=
           Local_Launch
             (Parameters.Identifier,
              Caps (1 .. Caps_Count),
              Environment);
      begin
         Rose.System_Calls.Initialize_Reply (Parameters, Parameters.Reply_Cap);
         Rose.System_Calls.Send_Cap (Parameters, Result);
      exception
         when others =>
            Rose.System_Calls.Initialize_Reply
              (Parameters,
               Parameters.Reply_Cap);
            Rose.System_Calls.Send_Error
              (Parameters,
               Rose.Invocation.Exception_Raised);
      end;
   end Handle_Launch;

   ---------------------------
   -- Handle_Launch_Command --
   ---------------------------

   procedure Handle_Launch_Command
     (Parameters : in out Rose.Invocation.Invocation_Record)
   is
   begin
      declare
         Caps       : Rose.Capabilities.Capability_Array
           (1 .. Rose.Invocation.Max_Capabilities);
         Caps_Count : constant Natural :=
           Rose.System_Calls.Copy_Received_Caps (Parameters, 0, Caps);
         Result     : constant Rose.Capabilities.Capability :=
           Local_Launch_Command
             (Parameters.Identifier,
              Caps (1 .. Caps_Count));
      begin
         Rose.System_Calls.Initialize_Reply (Parameters, Parameters.Reply_Cap);
         Rose.System_Calls.Send_Cap (Parameters, Result);
      exception
         when others =>
            Rose.System_Calls.Initialize_Reply
              (Parameters,
               Parameters.Reply_Cap);
            Rose.System_Calls.Send_Error
              (Parameters,
               Rose.Invocation.Exception_Raised);
      end;
   end Handle_Launch_Command;

   ---------------------
   -- Handle_Metadata --
   ---------------------

   procedure Handle_Metadata
     (Parameters : in out Rose.Invocation.Invocation_Record)
   is
   begin
      declare
         Last   : Natural := 0;
         Result : String (1 .. Natural (Parameters.Buffer_Length))
           with Import, Address => Parameters.Buffer_Address;
      begin
         Local_Metadata (Parameters.Identifier, Result, Last);
         Rose.System_Calls.Initialize_Reply (Parameters, Parameters.Reply_Cap);
         Rose.System_Calls.Send_Word (Parameters, Last);
      exception
         when others =>
            Rose.System_Calls.Initialize_Reply
              (Parameters,
               Parameters.Reply_Cap);
            Rose.System_Calls.Send_Error
              (Parameters,
               Rose.Invocation.Exception_Raised);
      end;
   end Handle_Metadata;

   --------------------------------
   -- Handle_Set_Standard_Output --
   --------------------------------

   procedure Handle_Set_Standard_Output
     (Parameters : in out Rose.Invocation.Invocation_Record)
   is
   begin
      declare
         Output : constant Rose.Capabilities.Capability := Parameters.Caps (0);
      begin
         Local_Set_Standard_Output (Parameters.Identifier, Output);
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
   end Handle_Set_Standard_Output;

   -----------------------
   -- Publish_Interface --
   -----------------------

   procedure Publish_Interface
     (Server_Context      : in out Rose.Server.Server_Context;
      Launch              : Launch_Handler;
      Launch_Command      : Launch_Command_Handler;
      Metadata            : Metadata_Handler;
      Install             : Install_Handler;
      Set_Standard_Output : Set_Standard_Output_Handler)
   is
   begin
      Local_Launch := Launch;
      Local_Launch_Command := Launch_Command;
      Local_Metadata := Metadata;
      Local_Install := Install;
      Local_Set_Standard_Output := Set_Standard_Output;
      Launch_Cap := Rose.Server.Create_Endpoint (Launch_Endpoint);
      Launch_Command_Cap :=
        Rose.Server.Create_Endpoint (Launch_Command_Endpoint);
      Metadata_Cap := Rose.Server.Create_Endpoint (Metadata_Endpoint);
      Install_Cap := Rose.Server.Create_Endpoint (Install_Endpoint);
      Set_Standard_Output_Cap :=
        Rose.Server.Create_Endpoint (Set_Standard_Output_Endpoint);
      Published_Cap := Rose.Server.Create_Endpoint (Exec_Interface);
      Rose.Server.Register_Handler
        (Server_Context,
         Launch_Interface,
         Handle_Get_Launch_Interface'Access);
      Rose.Server.Register_Handler
        (Server_Context,
         Exec_Interface,
         Handle_Get_Exec_Interface'Access);
      Rose.Server.Register_Handler
        (Server_Context,
         Launch_Endpoint,
         Handle_Launch'Access);
      Rose.Server.Register_Handler
        (Server_Context,
         Launch_Command_Endpoint,
         Handle_Launch_Command'Access);
      Rose.Server.Register_Handler
        (Server_Context,
         Metadata_Endpoint,
         Handle_Metadata'Access);
      Rose.Server.Register_Handler
        (Server_Context,
         Install_Endpoint,
         Handle_Install'Access);
      Rose.Server.Register_Handler
        (Server_Context,
         Set_Standard_Output_Endpoint,
         Handle_Set_Standard_Output'Access);
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

end Rose.Interfaces.Exec.Server;
