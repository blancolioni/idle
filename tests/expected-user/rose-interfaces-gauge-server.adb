with Rose.Invocation;
with Rose.Objects;
with Rose.System_Calls;
with Rose.Words;

package body Rose.Interfaces.Gauge.Server is

   Server_Instance : Rose.Server.Server_Instance;

   type Object_Access is access all Gauge_Interface'Class;

   type Attached_Object is record
      Object : Object_Access;
      Cap    : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
   end record;

   Max_Attached    : constant := 16;

   type Attached_Array is array (0 .. (Max_Attached - 1)) of Attached_Object;

   Attached        : Attached_Array;

   Attached_Count  : Natural := 0;

   Registered      : Boolean := False;

   function Find
     (Identifier : Rose.Objects.Capability_Identifier)
      return Object_Access;

   procedure Handle_Get_Named_Interface
     (Parameters : in out Rose.Invocation.Invocation_Record);

   procedure Handle_Get_Counter_Interface
     (Parameters : in out Rose.Invocation.Invocation_Record);

   procedure Handle_Get_Labelled_Interface
     (Parameters : in out Rose.Invocation.Invocation_Record);

   procedure Handle_Get_Gauge_Interface
     (Parameters : in out Rose.Invocation.Invocation_Record);

   procedure Handle_Badge
     (Parameters : in out Rose.Invocation.Invocation_Record);

   procedure Handle_Increment
     (Parameters : in out Rose.Invocation.Invocation_Record);

   procedure Handle_Value
     (Parameters : in out Rose.Invocation.Invocation_Record);

   procedure Handle_Set_Label
     (Parameters : in out Rose.Invocation.Invocation_Record);

   procedure Handle_Reset
     (Parameters : in out Rose.Invocation.Invocation_Record);

   ------------
   -- Attach --
   ------------

   procedure Attach
     (Server_Context : in out Rose.Server.Server_Context;
      Object         : not null access Gauge_Interface'Class)
   is
   begin
      if not Registered then
         Rose.Server.Register_Handler
           (Server_Context,
            Rose.Interfaces.Gauge.Named_Interface,
            Handle_Get_Named_Interface'Access);
         Rose.Server.Register_Handler
           (Server_Context,
            Rose.Interfaces.Gauge.Counter_Interface,
            Handle_Get_Counter_Interface'Access);
         Rose.Server.Register_Handler
           (Server_Context,
            Rose.Interfaces.Gauge.Labelled_Interface,
            Handle_Get_Labelled_Interface'Access);
         Rose.Server.Register_Handler
           (Server_Context,
            Rose.Interfaces.Gauge.Gauge_Interface,
            Handle_Get_Gauge_Interface'Access);
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
            Set_Label_Endpoint,
            Handle_Set_Label'Access);
         Rose.Server.Register_Handler
           (Server_Context,
            Reset_Endpoint,
            Handle_Reset'Access);
         Rose.Server.Register_Handler
           (Server_Context,
            16#3E0F_A7AD_9812_58AB#,
            Handle_Badge'Access);
         Registered := True;
      end if;
      if Attached_Count = Max_Attached then
         raise Constraint_Error
           with "Rose.Interfaces.Gauge.Server: too many objects";
      end if;
      Attached (Attached_Count).Object := Object_Access (Object);
      Attached (Attached_Count).Cap :=
        Rose.Server.Create_Endpoint
          (Rose.Interfaces.Gauge.Gauge_Interface,
           Rose.Objects.Capability_Identifier (Attached_Count));
      Attached_Count := Attached_Count + 1;
   end Attach;

   ----------
   -- Find --
   ----------

   function Find
     (Identifier : Rose.Objects.Capability_Identifier)
      return Object_Access
   is
      use type Rose.Objects.Capability_Identifier;
   begin
      if Identifier >= Rose.Objects.Capability_Identifier (Attached_Count) then
         return null;
      end if;
      return Attached (Natural (Identifier)).Object;
   end Find;

   ------------------
   -- Handle_Badge --
   ------------------

   procedure Handle_Badge
     (Parameters : in out Rose.Invocation.Invocation_Record)
   is
      Object : constant Object_Access := Find (Parameters.Identifier);
      Result : Rose.Capabilities.Capability;
   begin
      if Object = null then
         Rose.System_Calls.Initialize_Reply (Parameters, Parameters.Reply_Cap);
         Rose.System_Calls.Send_Error
           (Parameters,
            Rose.Invocation.Invalid_Operation);
         return;
      end if;
      Result := Object.Badge;
      Rose.System_Calls.Initialize_Reply (Parameters, Parameters.Reply_Cap);
      Rose.System_Calls.Send_Cap (Parameters, Result);
   end Handle_Badge;

   ----------------------------------
   -- Handle_Get_Counter_Interface --
   ----------------------------------

   procedure Handle_Get_Counter_Interface
     (Parameters : in out Rose.Invocation.Invocation_Record)
   is
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
         Rose.System_Calls.Send_Cap (Parameters, Cap);
         if not Rose.Server.Has_Instance
           (Server_Instance,
            Increment_Endpoint,
            Identifier)
         then
            Rose.Server.Set_Instance_Cap
              (Server_Instance,
               Increment_Endpoint,
               Identifier,
               Rose.Server.Create_Endpoint (Increment_Endpoint, Identifier));
         end if;
         Cap :=
           Rose.Server.Get_Instance_Cap
             (Server_Instance,
              Increment_Endpoint,
              Identifier);
         Rose.System_Calls.Send_Cap (Parameters, Cap);
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
   -- Handle_Get_Gauge_Interface --
   --------------------------------

   procedure Handle_Get_Gauge_Interface
     (Parameters : in out Rose.Invocation.Invocation_Record)
   is
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
         Rose.System_Calls.Send_Cap (Parameters, Cap);
         if not Rose.Server.Has_Instance
           (Server_Instance,
            Increment_Endpoint,
            Identifier)
         then
            Rose.Server.Set_Instance_Cap
              (Server_Instance,
               Increment_Endpoint,
               Identifier,
               Rose.Server.Create_Endpoint (Increment_Endpoint, Identifier));
         end if;
         Cap :=
           Rose.Server.Get_Instance_Cap
             (Server_Instance,
              Increment_Endpoint,
              Identifier);
         Rose.System_Calls.Send_Cap (Parameters, Cap);
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
         Rose.System_Calls.Send_Cap (Parameters, Cap);
         if not Rose.Server.Has_Instance
           (Server_Instance,
            Set_Label_Endpoint,
            Identifier)
         then
            Rose.Server.Set_Instance_Cap
              (Server_Instance,
               Set_Label_Endpoint,
               Identifier,
               Rose.Server.Create_Endpoint (Set_Label_Endpoint, Identifier));
         end if;
         Cap :=
           Rose.Server.Get_Instance_Cap
             (Server_Instance,
              Set_Label_Endpoint,
              Identifier);
         Rose.System_Calls.Send_Cap (Parameters, Cap);
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
               if Ancestor = 3 then
                  if not Rose.Server.Has_Instance
                    (Server_Instance,
                     Labelled_Interface,
                     Identifier)
                  then
                     Rose.Server.Set_Instance_Cap
                       (Server_Instance,
                        Labelled_Interface,
                        Identifier,
                        Rose.Server.Create_Endpoint
                          (Labelled_Interface,
                           Identifier));
                  end if;
                  Rose.System_Calls.Send_Cap
                    (Parameters,
                     Rose.Server.Get_Instance_Cap
                       (Server_Instance,
                        Labelled_Interface,
                        Identifier));
               else
                  Rose.System_Calls.Send_Error
                    (Parameters,
                     Rose.Invocation.Invalid_Operation);
               end if;
            end if;
         end if;
      end if;
   end Handle_Get_Gauge_Interface;

   -----------------------------------
   -- Handle_Get_Labelled_Interface --
   -----------------------------------

   procedure Handle_Get_Labelled_Interface
     (Parameters : in out Rose.Invocation.Invocation_Record)
   is
      Cap        : Rose.Capabilities.Capability;
      Identifier : constant Rose.Objects.Capability_Identifier :=
        Parameters.Identifier;
   begin
      Rose.System_Calls.Initialize_Reply (Parameters, Parameters.Reply_Cap);
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
      Rose.System_Calls.Send_Cap (Parameters, Cap);
      if not Rose.Server.Has_Instance
        (Server_Instance,
         Set_Label_Endpoint,
         Identifier)
      then
         Rose.Server.Set_Instance_Cap
           (Server_Instance,
            Set_Label_Endpoint,
            Identifier,
            Rose.Server.Create_Endpoint (Set_Label_Endpoint, Identifier));
      end if;
      Cap :=
        Rose.Server.Get_Instance_Cap
          (Server_Instance,
           Set_Label_Endpoint,
           Identifier);
      Rose.System_Calls.Send_Cap (Parameters, Cap);
   end Handle_Get_Labelled_Interface;

   --------------------------------
   -- Handle_Get_Named_Interface --
   --------------------------------

   procedure Handle_Get_Named_Interface
     (Parameters : in out Rose.Invocation.Invocation_Record)
   is
      Cap        : Rose.Capabilities.Capability;
      Identifier : constant Rose.Objects.Capability_Identifier :=
        Parameters.Identifier;
   begin
      Rose.System_Calls.Initialize_Reply (Parameters, Parameters.Reply_Cap);
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
      Rose.System_Calls.Send_Cap (Parameters, Cap);
   end Handle_Get_Named_Interface;

   ----------------------
   -- Handle_Increment --
   ----------------------

   procedure Handle_Increment
     (Parameters : in out Rose.Invocation.Invocation_Record)
   is
      Object : constant Object_Access := Find (Parameters.Identifier);
      By     : constant Rose.Words.Word :=
        Rose.System_Calls.Get_Word_32 (Parameters, 0);
   begin
      if Object = null then
         Rose.System_Calls.Initialize_Reply (Parameters, Parameters.Reply_Cap);
         Rose.System_Calls.Send_Error
           (Parameters,
            Rose.Invocation.Invalid_Operation);
         return;
      end if;
      Object.Increment (By);
      Rose.System_Calls.Initialize_Reply (Parameters, Parameters.Reply_Cap);
   end Handle_Increment;

   ------------------
   -- Handle_Reset --
   ------------------

   procedure Handle_Reset
     (Parameters : in out Rose.Invocation.Invocation_Record)
   is
      Object : constant Object_Access := Find (Parameters.Identifier);
   begin
      if Object = null then
         Rose.System_Calls.Initialize_Reply (Parameters, Parameters.Reply_Cap);
         Rose.System_Calls.Send_Error
           (Parameters,
            Rose.Invocation.Invalid_Operation);
         return;
      end if;
      Object.Reset;
      Rose.System_Calls.Initialize_Reply (Parameters, Parameters.Reply_Cap);
   end Handle_Reset;

   ----------------------
   -- Handle_Set_Label --
   ----------------------

   procedure Handle_Set_Label
     (Parameters : in out Rose.Invocation.Invocation_Record)
   is
      Object : constant Object_Access := Find (Parameters.Identifier);
      Label  : constant Rose.Words.Word :=
        Rose.System_Calls.Get_Word_32 (Parameters, 0);
   begin
      if Object = null then
         Rose.System_Calls.Initialize_Reply (Parameters, Parameters.Reply_Cap);
         Rose.System_Calls.Send_Error
           (Parameters,
            Rose.Invocation.Invalid_Operation);
         return;
      end if;
      Object.Set_Label (Label);
      Rose.System_Calls.Initialize_Reply (Parameters, Parameters.Reply_Cap);
   end Handle_Set_Label;

   ------------------
   -- Handle_Value --
   ------------------

   procedure Handle_Value
     (Parameters : in out Rose.Invocation.Invocation_Record)
   is
      Object : constant Object_Access := Find (Parameters.Identifier);
      Result : Rose.Words.Word;
   begin
      if Object = null then
         Rose.System_Calls.Initialize_Reply (Parameters, Parameters.Reply_Cap);
         Rose.System_Calls.Send_Error
           (Parameters,
            Rose.Invocation.Invalid_Operation);
         return;
      end if;
      Result := Object.Value;
      Rose.System_Calls.Initialize_Reply (Parameters, Parameters.Reply_Cap);
      Rose.System_Calls.Send_Word (Parameters, Result);
   end Handle_Value;

   -------------------
   -- Interface_Cap --
   -------------------

   function Interface_Cap
     (Object : not null access Gauge_Interface'Class)
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

   -------------
   -- Publish --
   -------------

   procedure Publish
     (Server_Context : in out Rose.Server.Server_Context;
      Object         : not null access Gauge_Interface'Class)
   is
   begin
      Attach (Server_Context, Object);
      Rose.Server.Publish_Interface (Interface_Cap (Object));
   end Publish;

end Rose.Interfaces.Gauge.Server;
