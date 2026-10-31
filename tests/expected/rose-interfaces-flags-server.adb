with Rose.Invocation;
with Rose.System_Calls;

package body Rose.Interfaces.Flags.Server is

   use type Rose.Words.Word_32;

   Server_Instance : Rose.Server.Server_Instance;

   Local_Is_Set    : Is_Set_Handler;

   Is_Set_Cap      : Rose.Capabilities.Capability :=
     Rose.Capabilities.Null_Capability;

   Local_Query     : Query_Handler;

   Query_Cap       : Rose.Capabilities.Capability :=
     Rose.Capabilities.Null_Capability;

   Local_Toggle    : Toggle_Handler;

   Toggle_Cap      : Rose.Capabilities.Capability :=
     Rose.Capabilities.Null_Capability;

   Published_Cap   : Rose.Capabilities.Capability :=
     Rose.Capabilities.Null_Capability;

   procedure Handle_Get_Flags_Interface
     (Parameters : in out Rose.Invocation.Invocation_Record);

   procedure Handle_Is_Set
     (Parameters : in out Rose.Invocation.Invocation_Record);

   procedure Handle_Query
     (Parameters : in out Rose.Invocation.Invocation_Record);

   procedure Handle_Toggle
     (Parameters : in out Rose.Invocation.Invocation_Record);

   ----------------------
   -- Attach_Interface --
   ----------------------

   procedure Attach_Interface
     (Server_Context : in out Rose.Server.Server_Context;
      Is_Set         : Is_Set_Handler;
      Query          : Query_Handler;
      Toggle         : Toggle_Handler;
      Instanced      : Boolean := False)
   is
   begin
      Local_Is_Set := Is_Set;
      Local_Query := Query;
      Local_Toggle := Toggle;
      Rose.Server.Register_Handler
        (Server_Context,
         Flags_Interface,
         Handle_Get_Flags_Interface'Access);
      if not Instanced then
         Is_Set_Cap := Rose.Server.Create_Endpoint (Is_Set_Endpoint);
         Query_Cap := Rose.Server.Create_Endpoint (Query_Endpoint);
         Toggle_Cap := Rose.Server.Create_Endpoint (Toggle_Endpoint);
         Rose.Server.Create_Anonymous_Endpoint (Flags_Interface);
      end if;
      Rose.Server.Register_Handler
        (Server_Context,
         Is_Set_Endpoint,
         Handle_Is_Set'Access);
      Rose.Server.Register_Handler
        (Server_Context,
         Query_Endpoint,
         Handle_Query'Access);
      Rose.Server.Register_Handler
        (Server_Context,
         Toggle_Endpoint,
         Handle_Toggle'Access);
   end Attach_Interface;

   -------------------
   -- Create_Server --
   -------------------

   procedure Create_Server
     (Server_Context : in out Rose.Server.Server_Context;
      Is_Set         : Is_Set_Handler;
      Query          : Query_Handler;
      Toggle         : Toggle_Handler;
      Instanced      : Boolean := False)
   is
   begin
      Attach_Interface (Server_Context, Is_Set, Query, Toggle, Instanced);
   end Create_Server;

   --------------------
   -- Get_Is_Set_Cap --
   --------------------

   function Get_Is_Set_Cap return Rose.Capabilities.Capability is (Is_Set_Cap);

   -------------------
   -- Get_Query_Cap --
   -------------------

   function Get_Query_Cap return Rose.Capabilities.Capability is (Query_Cap);

   --------------------
   -- Get_Toggle_Cap --
   --------------------

   function Get_Toggle_Cap return Rose.Capabilities.Capability is (Toggle_Cap);

   --------------------------------
   -- Handle_Get_Flags_Interface --
   --------------------------------

   procedure Handle_Get_Flags_Interface
     (Parameters : in out Rose.Invocation.Invocation_Record)
   is
      use type Rose.Capabilities.Capability;
      Cap        : Rose.Capabilities.Capability;
      Identifier : constant Rose.Objects.Capability_Identifier :=
        Parameters.Identifier;
   begin
      Rose.System_Calls.Initialize_Reply (Parameters, Parameters.Reply_Cap);
      if Is_Set_Cap = Rose.Capabilities.Null_Capability then
         if not Rose.Server.Has_Instance
           (Server_Instance,
            Is_Set_Endpoint,
            Identifier)
         then
            Rose.Server.Set_Instance_Cap
              (Server_Instance,
               Is_Set_Endpoint,
               Identifier,
               Rose.Server.Create_Endpoint (Is_Set_Endpoint, Identifier));
         end if;
         Cap :=
           Rose.Server.Get_Instance_Cap
             (Server_Instance,
              Is_Set_Endpoint,
              Identifier);
      else
         Cap := Is_Set_Cap;
      end if;
      Rose.System_Calls.Send_Cap (Parameters, Cap);
      if Query_Cap = Rose.Capabilities.Null_Capability then
         if not Rose.Server.Has_Instance
           (Server_Instance,
            Query_Endpoint,
            Identifier)
         then
            Rose.Server.Set_Instance_Cap
              (Server_Instance,
               Query_Endpoint,
               Identifier,
               Rose.Server.Create_Endpoint (Query_Endpoint, Identifier));
         end if;
         Cap :=
           Rose.Server.Get_Instance_Cap
             (Server_Instance,
              Query_Endpoint,
              Identifier);
      else
         Cap := Query_Cap;
      end if;
      Rose.System_Calls.Send_Cap (Parameters, Cap);
      if Toggle_Cap = Rose.Capabilities.Null_Capability then
         if not Rose.Server.Has_Instance
           (Server_Instance,
            Toggle_Endpoint,
            Identifier)
         then
            Rose.Server.Set_Instance_Cap
              (Server_Instance,
               Toggle_Endpoint,
               Identifier,
               Rose.Server.Create_Endpoint (Toggle_Endpoint, Identifier));
         end if;
         Cap :=
           Rose.Server.Get_Instance_Cap
             (Server_Instance,
              Toggle_Endpoint,
              Identifier);
      else
         Cap := Toggle_Cap;
      end if;
      Rose.System_Calls.Send_Cap (Parameters, Cap);
   end Handle_Get_Flags_Interface;

   -------------------
   -- Handle_Is_Set --
   -------------------

   procedure Handle_Is_Set
     (Parameters : in out Rose.Invocation.Invocation_Record)
   is
      Name    : String (1 .. Natural (Parameters.Buffer_Length))
        with Import, Address => Parameters.Buffer_Address;
      Default : constant Boolean :=
        Rose.System_Calls.Get_Word_32 (Parameters, 0) /= 0;
      Result  : constant Boolean :=
        Local_Is_Set (Parameters.Identifier, Name, Default);
   begin
      Rose.System_Calls.Initialize_Reply (Parameters, Parameters.Reply_Cap);
      Rose.System_Calls.Send_Word (Parameters, Natural (Boolean'Pos (Result)));
   end Handle_Is_Set;

   ------------------
   -- Handle_Query --
   ------------------

   procedure Handle_Query
     (Parameters : in out Rose.Invocation.Invocation_Record)
   is
      Index   : constant Rose.Words.Word :=
        Rose.System_Calls.Get_Word_32 (Parameters, 0);
      Trusted : Boolean;
      Count   : Natural;
   begin
      Local_Query (Parameters.Identifier, Index, Trusted, Count);
      Rose.System_Calls.Initialize_Reply (Parameters, Parameters.Reply_Cap);
      Rose.System_Calls.Send_Word
        (Parameters,
         Natural (Boolean'Pos (Trusted)));
      Rose.System_Calls.Send_Word (Parameters, Count);
   end Handle_Query;

   -------------------
   -- Handle_Toggle --
   -------------------

   procedure Handle_Toggle
     (Parameters : in out Rose.Invocation.Invocation_Record)
   is
      Value : Boolean := Rose.System_Calls.Get_Word_32 (Parameters, 0) /= 0;
   begin
      Local_Toggle (Parameters.Identifier, Value);
      Rose.System_Calls.Initialize_Reply (Parameters, Parameters.Reply_Cap);
      Rose.System_Calls.Send_Word (Parameters, Natural (Boolean'Pos (Value)));
   end Handle_Toggle;

   -----------------------
   -- Publish_Interface --
   -----------------------

   procedure Publish_Interface
     (Server_Context : in out Rose.Server.Server_Context;
      Is_Set         : Is_Set_Handler;
      Query          : Query_Handler;
      Toggle         : Toggle_Handler)
   is
   begin
      Local_Is_Set := Is_Set;
      Local_Query := Query;
      Local_Toggle := Toggle;
      Is_Set_Cap := Rose.Server.Create_Endpoint (Is_Set_Endpoint);
      Query_Cap := Rose.Server.Create_Endpoint (Query_Endpoint);
      Toggle_Cap := Rose.Server.Create_Endpoint (Toggle_Endpoint);
      Published_Cap := Rose.Server.Create_Endpoint (Flags_Interface);
      Rose.Server.Register_Handler
        (Server_Context,
         Flags_Interface,
         Handle_Get_Flags_Interface'Access);
      Rose.Server.Register_Handler
        (Server_Context,
         Is_Set_Endpoint,
         Handle_Is_Set'Access);
      Rose.Server.Register_Handler
        (Server_Context,
         Query_Endpoint,
         Handle_Query'Access);
      Rose.Server.Register_Handler
        (Server_Context,
         Toggle_Endpoint,
         Handle_Toggle'Access);
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

end Rose.Interfaces.Flags.Server;
