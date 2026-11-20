with Rose.Invocation;
with Rose.System_Calls;

package body Rose.Interfaces.Measures.Counter.Server is

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

   Local_Label     : Label_Handler;

   Label_Cap       : Rose.Capabilities.Capability :=
     Rose.Capabilities.Null_Capability;

   Local_Twin      : Twin_Handler;

   Twin_Cap        : Rose.Capabilities.Capability :=
     Rose.Capabilities.Null_Capability;

   Published_Cap   : Rose.Capabilities.Capability :=
     Rose.Capabilities.Null_Capability;

   Local_Owns      : Owns_Function := null;

   procedure Handle_Get_Named_Interface
     (Parameters : in out Rose.Invocation.Invocation_Record);

   procedure Handle_Get_Counter_Interface
     (Parameters : in out Rose.Invocation.Invocation_Record);

   procedure Handle_Badge
     (Parameters : in out Rose.Invocation.Invocation_Record);

   procedure Handle_Increment
     (Parameters : in out Rose.Invocation.Invocation_Record);

   procedure Handle_Value
     (Parameters : in out Rose.Invocation.Invocation_Record);

   procedure Handle_Label
     (Parameters : in out Rose.Invocation.Invocation_Record);

   procedure Handle_Twin
     (Parameters : in out Rose.Invocation.Invocation_Record);

   ----------------------
   -- Attach_Interface --
   ----------------------

   procedure Attach_Interface
     (Server_Context : in out Rose.Server.Server_Context;
      Badge          : Badge_Handler;
      Increment      : Increment_Handler;
      Value          : Value_Handler;
      Label          : Label_Handler;
      Twin           : Twin_Handler;
      Instanced      : Boolean := False)
   is
   begin
      Local_Badge := Badge;
      Local_Increment := Increment;
      Local_Value := Value;
      Local_Label := Label;
      Local_Twin := Twin;
      Rose.Server.Register_Handler
        (Server_Context,
         Named_Interface,
         Handle_Get_Named_Interface'Access);
      Rose.Server.Register_Handler
        (Server_Context,
         Counter_Interface,
         Handle_Get_Counter_Interface'Access);
      if not Instanced then
         Badge_Cap := Rose.Server.Create_Endpoint (Badge_Endpoint);
         Increment_Cap := Rose.Server.Create_Endpoint (Increment_Endpoint);
         Value_Cap := Rose.Server.Create_Endpoint (Value_Endpoint);
         Label_Cap := Rose.Server.Create_Endpoint (Label_Endpoint);
         Twin_Cap := Rose.Server.Create_Endpoint (Twin_Endpoint);
         Rose.Server.Create_Anonymous_Endpoint (Named_Interface);
         Rose.Server.Create_Anonymous_Endpoint (Counter_Interface);
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
         Label_Endpoint,
         Handle_Label'Access);
      Rose.Server.Register_Handler
        (Server_Context,
         Twin_Endpoint,
         Handle_Twin'Access);
   end Attach_Interface;

   -------------------
   -- Create_Server --
   -------------------

   procedure Create_Server
     (Server_Context : in out Rose.Server.Server_Context;
      Badge          : Badge_Handler;
      Increment      : Increment_Handler;
      Value          : Value_Handler;
      Label          : Label_Handler;
      Twin           : Twin_Handler;
      Instanced      : Boolean := False)
   is
   begin
      Attach_Interface
        (Server_Context,
         Badge,
         Increment,
         Value,
         Label,
         Twin,
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
   -- Get_Label_Cap --
   -------------------

   function Get_Label_Cap return Rose.Capabilities.Capability is (Label_Cap);

   ------------------
   -- Get_Twin_Cap --
   ------------------

   function Get_Twin_Cap return Rose.Capabilities.Capability is (Twin_Cap);

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
      Result : constant Rose.Capabilities.Capability :=
        Local_Badge (Parameters.Identifier);
   begin
      Rose.System_Calls.Initialize_Reply (Parameters, Parameters.Reply_Cap);
      Rose.System_Calls.Send_Cap (Parameters, Result);
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
      if Local_Owns /= null and then not Local_Owns (Identifier) then
         Rose.System_Calls.Send_Error
           (Parameters,
            Rose.Invocation.Invalid_Object);
      else
         if Ancestor = 0 then
            if First >= 5 then
               Rose.System_Calls.Send_Error
                 (Parameters,
                  Rose.Invocation.Invalid_Operation);
            else
               if 0 in First .. (First + Page - 1) then
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
                           Rose.Server.Create_Endpoint
                             (Badge_Endpoint,
                              Identifier));
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
               end if;
               if 1 in First .. (First + Page - 1) then
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
               end if;
               if 2 in First .. (First + Page - 1) then
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
                           Rose.Server.Create_Endpoint
                             (Value_Endpoint,
                              Identifier));
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
               end if;
               if 3 in First .. (First + Page - 1) then
                  if Label_Cap = Rose.Capabilities.Null_Capability then
                     if not Rose.Server.Has_Instance
                       (Server_Instance,
                        Label_Endpoint,
                        Identifier)
                     then
                        Rose.Server.Set_Instance_Cap
                          (Server_Instance,
                           Label_Endpoint,
                           Identifier,
                           Rose.Server.Create_Endpoint
                             (Label_Endpoint,
                              Identifier));
                     end if;
                     Cap :=
                       Rose.Server.Get_Instance_Cap
                         (Server_Instance,
                          Label_Endpoint,
                          Identifier);
                  else
                     Cap := Label_Cap;
                  end if;
                  Rose.System_Calls.Send_Cap (Parameters, Cap);
               end if;
               if 4 in First .. (First + Page - 1) then
                  if Twin_Cap = Rose.Capabilities.Null_Capability then
                     if not Rose.Server.Has_Instance
                       (Server_Instance,
                        Twin_Endpoint,
                        Identifier)
                     then
                        Rose.Server.Set_Instance_Cap
                          (Server_Instance,
                           Twin_Endpoint,
                           Identifier,
                           Rose.Server.Create_Endpoint
                             (Twin_Endpoint,
                              Identifier));
                     end if;
                     Cap :=
                       Rose.Server.Get_Instance_Cap
                         (Server_Instance,
                          Twin_Endpoint,
                          Identifier);
                  else
                     Cap := Twin_Cap;
                  end if;
                  Rose.System_Calls.Send_Cap (Parameters, Cap);
               end if;
            end if;
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
                     Rose.Server.Create_Endpoint
                       (Named_Interface,
                        Identifier));
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
      end if;
   end Handle_Get_Counter_Interface;

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
      if Local_Owns /= null and then not Local_Owns (Identifier) then
         Rose.System_Calls.Send_Error
           (Parameters,
            Rose.Invocation.Invalid_Object);
      else
         if First >= 1 then
            Rose.System_Calls.Send_Error
              (Parameters,
               Rose.Invocation.Invalid_Operation);
         else
            if 0 in First .. (First + Page - 1) then
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
                        Rose.Server.Create_Endpoint
                          (Badge_Endpoint,
                           Identifier));
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
            end if;
         end if;
      end if;
   end Handle_Get_Named_Interface;

   ----------------------
   -- Handle_Increment --
   ----------------------

   procedure Handle_Increment
     (Parameters : in out Rose.Invocation.Invocation_Record)
   is
      By : constant Rose.Words.Word :=
        Rose.System_Calls.Get_Word_32 (Parameters, 0);
   begin
      Local_Increment (Parameters.Identifier, By);
      Rose.System_Calls.Initialize_Reply (Parameters, Parameters.Reply_Cap);
   end Handle_Increment;

   ------------------
   -- Handle_Label --
   ------------------

   procedure Handle_Label
     (Parameters : in out Rose.Invocation.Invocation_Record)
   is
      Result : constant Rose.Capabilities.Capability :=
        Local_Label (Parameters.Identifier);
   begin
      Rose.System_Calls.Initialize_Reply (Parameters, Parameters.Reply_Cap);
      Rose.System_Calls.Send_Cap (Parameters, Result);
   end Handle_Label;

   -----------------
   -- Handle_Twin --
   -----------------

   procedure Handle_Twin
     (Parameters : in out Rose.Invocation.Invocation_Record)
   is
      Result : constant Rose.Capabilities.Capability :=
        Local_Twin (Parameters.Identifier);
   begin
      Rose.System_Calls.Initialize_Reply (Parameters, Parameters.Reply_Cap);
      Rose.System_Calls.Send_Cap (Parameters, Result);
   end Handle_Twin;

   ------------------
   -- Handle_Value --
   ------------------

   procedure Handle_Value
     (Parameters : in out Rose.Invocation.Invocation_Record)
   is
      Result : constant Rose.Words.Word := Local_Value (Parameters.Identifier);
   begin
      Rose.System_Calls.Initialize_Reply (Parameters, Parameters.Reply_Cap);
      Rose.System_Calls.Send_Word (Parameters, Result);
   end Handle_Value;

   -----------------------
   -- Publish_Interface --
   -----------------------

   procedure Publish_Interface
     (Server_Context : in out Rose.Server.Server_Context;
      Badge          : Badge_Handler;
      Increment      : Increment_Handler;
      Value          : Value_Handler;
      Label          : Label_Handler;
      Twin           : Twin_Handler)
   is
   begin
      Local_Badge := Badge;
      Local_Increment := Increment;
      Local_Value := Value;
      Local_Label := Label;
      Local_Twin := Twin;
      Badge_Cap := Rose.Server.Create_Endpoint (Badge_Endpoint);
      Increment_Cap := Rose.Server.Create_Endpoint (Increment_Endpoint);
      Value_Cap := Rose.Server.Create_Endpoint (Value_Endpoint);
      Label_Cap := Rose.Server.Create_Endpoint (Label_Endpoint);
      Twin_Cap := Rose.Server.Create_Endpoint (Twin_Endpoint);
      Published_Cap := Rose.Server.Create_Endpoint (Counter_Interface);
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
         Label_Endpoint,
         Handle_Label'Access);
      Rose.Server.Register_Handler
        (Server_Context,
         Twin_Endpoint,
         Handle_Twin'Access);
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

   --------------
   -- Set_Owns --
   --------------

   procedure Set_Owns (Owns : Owns_Function) is
   begin
      Local_Owns := Owns;
   end Set_Owns;

end Rose.Interfaces.Measures.Counter.Server;
