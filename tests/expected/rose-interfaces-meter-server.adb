with Rose.Invocation;
with Rose.System_Calls;

package body Rose.Interfaces.Meter.Server is

   Server_Instance : Rose.Server.Server_Instance;

   Local_Badge     : Badge_Handler;

   Badge_Cap       : Rose.Capabilities.Capability :=
     Rose.Capabilities.Null_Capability;

   Local_Increment : Increment_Handler;

   Increment_Cap   : Rose.Capabilities.Capability :=
     Rose.Capabilities.Null_Capability;

   Local_Value     : Value_Handler;

   Value_Cap       : Rose.Capabilities.Capability :=
     Rose.Capabilities.Null_Capability;

   Local_Reset     : Reset_Handler;

   Reset_Cap       : Rose.Capabilities.Capability :=
     Rose.Capabilities.Null_Capability;

   Published_Cap   : Rose.Capabilities.Capability :=
     Rose.Capabilities.Null_Capability;

   procedure Handle_Get_Named_Interface
     (Parameters : in out Rose.Invocation.Invocation_Record);

   procedure Handle_Get_Counter_Interface
     (Parameters : in out Rose.Invocation.Invocation_Record);

   procedure Handle_Get_Meter_Interface
     (Parameters : in out Rose.Invocation.Invocation_Record);

   procedure Handle_Badge
     (Parameters : in out Rose.Invocation.Invocation_Record);

   procedure Handle_Increment
     (Parameters : in out Rose.Invocation.Invocation_Record);

   procedure Handle_Value
     (Parameters : in out Rose.Invocation.Invocation_Record);

   procedure Handle_Reset
     (Parameters : in out Rose.Invocation.Invocation_Record);

   ----------------------
   -- Attach_Interface --
   ----------------------

   procedure Attach_Interface
     (Server_Context : in out Rose.Server.Server_Context;
      Badge          : Badge_Handler;
      Increment      : Increment_Handler;
      Value          : Value_Handler;
      Reset          : Reset_Handler;
      Instanced      : Boolean := False)
   is
   begin
      Local_Badge := Badge;
      Local_Increment := Increment;
      Local_Value := Value;
      Local_Reset := Reset;
      Rose.Server.Register_Handler
        (Server_Context,
         Named_Interface,
         Handle_Get_Named_Interface'Access);
      Rose.Server.Register_Handler
        (Server_Context,
         Counter_Interface,
         Handle_Get_Counter_Interface'Access);
      Rose.Server.Register_Handler
        (Server_Context,
         Meter_Interface,
         Handle_Get_Meter_Interface'Access);
      if not Instanced then
         Badge_Cap := Rose.Server.Create_Endpoint (Badge_Endpoint);
         Increment_Cap := Rose.Server.Create_Endpoint (Increment_Endpoint);
         Value_Cap := Rose.Server.Create_Endpoint (Value_Endpoint);
         Reset_Cap := Rose.Server.Create_Endpoint (Reset_Endpoint);
         Rose.Server.Create_Anonymous_Endpoint (Named_Interface);
         Rose.Server.Create_Anonymous_Endpoint (Counter_Interface);
         Rose.Server.Create_Anonymous_Endpoint (Meter_Interface);
      end if;
      Rose.Server.Register_Handler
        (Server_Context,
         Badge_Endpoint,
         Handle_Badge'Access);
      Rose.Server.Register_Handler
        (Server_Context,
         Increment_Endpoint,
         Handle_Increment'Access);
      Rose.Server.Register_Handler
        (Server_Context,
         Value_Endpoint,
         Handle_Value'Access);
      Rose.Server.Register_Handler
        (Server_Context,
         Reset_Endpoint,
         Handle_Reset'Access);
   end Attach_Interface;

   -------------------
   -- Create_Server --
   -------------------

   procedure Create_Server
     (Server_Context : in out Rose.Server.Server_Context;
      Badge          : Badge_Handler;
      Increment      : Increment_Handler;
      Value          : Value_Handler;
      Reset          : Reset_Handler;
      Instanced      : Boolean := False)
   is
   begin
      Attach_Interface
        (Server_Context,
         Badge,
         Increment,
         Value,
         Reset,
         Instanced);
   end Create_Server;

   -------------------
   -- Get_Badge_Cap --
   -------------------

   function Get_Badge_Cap return Rose.Capabilities.Capability is (Badge_Cap);

   -----------------------
   -- Get_Increment_Cap --
   -----------------------

   function Get_Increment_Cap
      return Rose.Capabilities.Capability
   is (Increment_Cap);

   -------------------
   -- Get_Reset_Cap --
   -------------------

   function Get_Reset_Cap return Rose.Capabilities.Capability is (Reset_Cap);

   -------------------
   -- Get_Value_Cap --
   -------------------

   function Get_Value_Cap return Rose.Capabilities.Capability is (Value_Cap);

   ------------------
   -- Handle_Badge --
   ------------------

   procedure Handle_Badge
     (Parameters : in out Rose.Invocation.Invocation_Record)
   is
   begin
      declare
         Result : constant Rose.Capabilities.Capability :=
           Local_Badge (Parameters.Identifier);
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
   end Handle_Badge;

   ----------------------------------
   -- Handle_Get_Counter_Interface --
   ----------------------------------

   procedure Handle_Get_Counter_Interface
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
         if Badge_Cap = Rose.Capabilities.Null_Capability then
            if not Rose.Server.Has_Instance
              (Server_Instance,
               Badge_Endpoint,
               Identifier)
            then
               Rose.Server.Set_Instance_Cap
                 (Server_Instance,
                  Badge_Endpoint,
                  Identifier,
                  Rose.Server.Create_Endpoint (Badge_Endpoint, Identifier));
            end if;
            Cap :=
              Rose.Server.Get_Instance_Cap
                (Server_Instance,
                 Badge_Endpoint,
                 Identifier);
         else
            Cap := Badge_Cap;
         end if;
         Rose.System_Calls.Send_Cap (Parameters, Cap);
         if Increment_Cap = Rose.Capabilities.Null_Capability then
            if not Rose.Server.Has_Instance
              (Server_Instance,
               Increment_Endpoint,
               Identifier)
            then
               Rose.Server.Set_Instance_Cap
                 (Server_Instance,
                  Increment_Endpoint,
                  Identifier,
                  Rose.Server.Create_Endpoint
                    (Increment_Endpoint,
                     Identifier));
            end if;
            Cap :=
              Rose.Server.Get_Instance_Cap
                (Server_Instance,
                 Increment_Endpoint,
                 Identifier);
         else
            Cap := Increment_Cap;
         end if;
         Rose.System_Calls.Send_Cap (Parameters, Cap);
         if Value_Cap = Rose.Capabilities.Null_Capability then
            if not Rose.Server.Has_Instance
              (Server_Instance,
               Value_Endpoint,
               Identifier)
            then
               Rose.Server.Set_Instance_Cap
                 (Server_Instance,
                  Value_Endpoint,
                  Identifier,
                  Rose.Server.Create_Endpoint (Value_Endpoint, Identifier));
            end if;
            Cap :=
              Rose.Server.Get_Instance_Cap
                (Server_Instance,
                 Value_Endpoint,
                 Identifier);
         else
            Cap := Value_Cap;
         end if;
         Rose.System_Calls.Send_Cap (Parameters, Cap);
      else
         if Ancestor = 1 then
            if not Rose.Server.Has_Instance
              (Server_Instance,
               Named_Interface,
               Identifier)
            then
               Rose.Server.Set_Instance_Cap
                 (Server_Instance,
                  Named_Interface,
                  Identifier,
                  Rose.Server.Create_Endpoint (Named_Interface, Identifier));
            end if;
            Rose.System_Calls.Send_Cap
              (Parameters,
               Rose.Server.Get_Instance_Cap
                 (Server_Instance,
                  Named_Interface,
                  Identifier));
         else
            Rose.System_Calls.Send_Error
              (Parameters,
               Rose.Invocation.Invalid_Operation);
         end if;
      end if;
   end Handle_Get_Counter_Interface;

   --------------------------------
   -- Handle_Get_Meter_Interface --
   --------------------------------

   procedure Handle_Get_Meter_Interface
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
         if Badge_Cap = Rose.Capabilities.Null_Capability then
            if not Rose.Server.Has_Instance
              (Server_Instance,
               Badge_Endpoint,
               Identifier)
            then
               Rose.Server.Set_Instance_Cap
                 (Server_Instance,
                  Badge_Endpoint,
                  Identifier,
                  Rose.Server.Create_Endpoint (Badge_Endpoint, Identifier));
            end if;
            Cap :=
              Rose.Server.Get_Instance_Cap
                (Server_Instance,
                 Badge_Endpoint,
                 Identifier);
         else
            Cap := Badge_Cap;
         end if;
         Rose.System_Calls.Send_Cap (Parameters, Cap);
         if Increment_Cap = Rose.Capabilities.Null_Capability then
            if not Rose.Server.Has_Instance
              (Server_Instance,
               Increment_Endpoint,
               Identifier)
            then
               Rose.Server.Set_Instance_Cap
                 (Server_Instance,
                  Increment_Endpoint,
                  Identifier,
                  Rose.Server.Create_Endpoint
                    (Increment_Endpoint,
                     Identifier));
            end if;
            Cap :=
              Rose.Server.Get_Instance_Cap
                (Server_Instance,
                 Increment_Endpoint,
                 Identifier);
         else
            Cap := Increment_Cap;
         end if;
         Rose.System_Calls.Send_Cap (Parameters, Cap);
         if Value_Cap = Rose.Capabilities.Null_Capability then
            if not Rose.Server.Has_Instance
              (Server_Instance,
               Value_Endpoint,
               Identifier)
            then
               Rose.Server.Set_Instance_Cap
                 (Server_Instance,
                  Value_Endpoint,
                  Identifier,
                  Rose.Server.Create_Endpoint (Value_Endpoint, Identifier));
            end if;
            Cap :=
              Rose.Server.Get_Instance_Cap
                (Server_Instance,
                 Value_Endpoint,
                 Identifier);
         else
            Cap := Value_Cap;
         end if;
         Rose.System_Calls.Send_Cap (Parameters, Cap);
         if Reset_Cap = Rose.Capabilities.Null_Capability then
            if not Rose.Server.Has_Instance
              (Server_Instance,
               Reset_Endpoint,
               Identifier)
            then
               Rose.Server.Set_Instance_Cap
                 (Server_Instance,
                  Reset_Endpoint,
                  Identifier,
                  Rose.Server.Create_Endpoint (Reset_Endpoint, Identifier));
            end if;
            Cap :=
              Rose.Server.Get_Instance_Cap
                (Server_Instance,
                 Reset_Endpoint,
                 Identifier);
         else
            Cap := Reset_Cap;
         end if;
         Rose.System_Calls.Send_Cap (Parameters, Cap);
      else
         if Ancestor = 1 then
            if not Rose.Server.Has_Instance
              (Server_Instance,
               Named_Interface,
               Identifier)
            then
               Rose.Server.Set_Instance_Cap
                 (Server_Instance,
                  Named_Interface,
                  Identifier,
                  Rose.Server.Create_Endpoint (Named_Interface, Identifier));
            end if;
            Rose.System_Calls.Send_Cap
              (Parameters,
               Rose.Server.Get_Instance_Cap
                 (Server_Instance,
                  Named_Interface,
                  Identifier));
         else
            if Ancestor = 2 then
               if not Rose.Server.Has_Instance
                 (Server_Instance,
                  Counter_Interface,
                  Identifier)
               then
                  Rose.Server.Set_Instance_Cap
                    (Server_Instance,
                     Counter_Interface,
                     Identifier,
                     Rose.Server.Create_Endpoint
                       (Counter_Interface,
                        Identifier));
               end if;
               Rose.System_Calls.Send_Cap
                 (Parameters,
                  Rose.Server.Get_Instance_Cap
                    (Server_Instance,
                     Counter_Interface,
                     Identifier));
            else
               Rose.System_Calls.Send_Error
                 (Parameters,
                  Rose.Invocation.Invalid_Operation);
            end if;
         end if;
      end if;
   end Handle_Get_Meter_Interface;

   --------------------------------
   -- Handle_Get_Named_Interface --
   --------------------------------

   procedure Handle_Get_Named_Interface
     (Parameters : in out Rose.Invocation.Invocation_Record)
   is
      use type Rose.Capabilities.Capability;
      Cap        : Rose.Capabilities.Capability;
      Identifier : constant Rose.Objects.Capability_Identifier :=
        Parameters.Identifier;
   begin
      Rose.System_Calls.Initialize_Reply (Parameters, Parameters.Reply_Cap);
      if Badge_Cap = Rose.Capabilities.Null_Capability then
         if not Rose.Server.Has_Instance
           (Server_Instance,
            Badge_Endpoint,
            Identifier)
         then
            Rose.Server.Set_Instance_Cap
              (Server_Instance,
               Badge_Endpoint,
               Identifier,
               Rose.Server.Create_Endpoint (Badge_Endpoint, Identifier));
         end if;
         Cap :=
           Rose.Server.Get_Instance_Cap
             (Server_Instance,
              Badge_Endpoint,
              Identifier);
      else
         Cap := Badge_Cap;
      end if;
      Rose.System_Calls.Send_Cap (Parameters, Cap);
   end Handle_Get_Named_Interface;

   ----------------------
   -- Handle_Increment --
   ----------------------

   procedure Handle_Increment
     (Parameters : in out Rose.Invocation.Invocation_Record)
   is
   begin
      declare
         By : constant Rose.Words.Word :=
           Rose.System_Calls.Get_Word_32 (Parameters, 0);
      begin
         Local_Increment (Parameters.Identifier, By);
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
   end Handle_Increment;

   ------------------
   -- Handle_Reset --
   ------------------

   procedure Handle_Reset
     (Parameters : in out Rose.Invocation.Invocation_Record)
   is
   begin
      begin
         Local_Reset (Parameters.Identifier);
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
   end Handle_Reset;

   ------------------
   -- Handle_Value --
   ------------------

   procedure Handle_Value
     (Parameters : in out Rose.Invocation.Invocation_Record)
   is
   begin
      declare
         Result : constant Rose.Words.Word :=
           Local_Value (Parameters.Identifier);
      begin
         Rose.System_Calls.Initialize_Reply (Parameters, Parameters.Reply_Cap);
         Rose.System_Calls.Send_Word (Parameters, Result);
      exception
         when others =>
            Rose.System_Calls.Initialize_Reply
              (Parameters,
               Parameters.Reply_Cap);
            Rose.System_Calls.Send_Error
              (Parameters,
               Rose.Invocation.Exception_Raised);
      end;
   end Handle_Value;

   -----------------------
   -- Publish_Interface --
   -----------------------

   procedure Publish_Interface
     (Server_Context : in out Rose.Server.Server_Context;
      Badge          : Badge_Handler;
      Increment      : Increment_Handler;
      Value          : Value_Handler;
      Reset          : Reset_Handler)
   is
   begin
      Local_Badge := Badge;
      Local_Increment := Increment;
      Local_Value := Value;
      Local_Reset := Reset;
      Badge_Cap := Rose.Server.Create_Endpoint (Badge_Endpoint);
      Increment_Cap := Rose.Server.Create_Endpoint (Increment_Endpoint);
      Value_Cap := Rose.Server.Create_Endpoint (Value_Endpoint);
      Reset_Cap := Rose.Server.Create_Endpoint (Reset_Endpoint);
      Published_Cap := Rose.Server.Create_Endpoint (Meter_Interface);
      Rose.Server.Register_Handler
        (Server_Context,
         Named_Interface,
         Handle_Get_Named_Interface'Access);
      Rose.Server.Register_Handler
        (Server_Context,
         Counter_Interface,
         Handle_Get_Counter_Interface'Access);
      Rose.Server.Register_Handler
        (Server_Context,
         Meter_Interface,
         Handle_Get_Meter_Interface'Access);
      Rose.Server.Register_Handler
        (Server_Context,
         Badge_Endpoint,
         Handle_Badge'Access);
      Rose.Server.Register_Handler
        (Server_Context,
         Increment_Endpoint,
         Handle_Increment'Access);
      Rose.Server.Register_Handler
        (Server_Context,
         Value_Endpoint,
         Handle_Value'Access);
      Rose.Server.Register_Handler
        (Server_Context,
         Reset_Endpoint,
         Handle_Reset'Access);
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

end Rose.Interfaces.Meter.Server;
