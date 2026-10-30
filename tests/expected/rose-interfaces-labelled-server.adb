with Rose.Invocation;
with Rose.System_Calls;

package body Rose.Interfaces.Labelled.Server is

   Server_Instance : Rose.Server.Server_Instance;

   Local_Badge     : Badge_Handler;

   Badge_Cap       : Rose.Capabilities.Capability :=
     Rose.Capabilities.Null_Capability;

   Local_Set_Label : Set_Label_Handler;

   Set_Label_Cap   : Rose.Capabilities.Capability :=
     Rose.Capabilities.Null_Capability;

   Published_Cap   : Rose.Capabilities.Capability :=
     Rose.Capabilities.Null_Capability;

   procedure Handle_Get_Labelled_Interface
     (Parameters : in out Rose.Invocation.Invocation_Record);

   procedure Handle_Badge
     (Parameters : in out Rose.Invocation.Invocation_Record);

   procedure Handle_Set_Label
     (Parameters : in out Rose.Invocation.Invocation_Record);

   ----------------------
   -- Attach_Interface --
   ----------------------

   procedure Attach_Interface
     (Server_Context : in out Rose.Server.Server_Context;
      Badge          : Badge_Handler;
      Set_Label      : Set_Label_Handler;
      Instanced      : Boolean := False)
   is
   begin
      Local_Badge := Badge;
      Local_Set_Label := Set_Label;
      Rose.Server.Register_Handler
        (Server_Context,
         Labelled_Interface,
         Handle_Get_Labelled_Interface'Access);
      if not Instanced then
         Badge_Cap := Rose.Server.Create_Endpoint (Badge_Endpoint);
         Set_Label_Cap := Rose.Server.Create_Endpoint (Set_Label_Endpoint);
         Rose.Server.Create_Anonymous_Endpoint (Labelled_Interface);
      end if;
      Rose.Server.Register_Handler
        (Server_Context,
         Badge_Endpoint,
         Handle_Badge'Access);
      Rose.Server.Register_Handler
        (Server_Context,
         Set_Label_Endpoint,
         Handle_Set_Label'Access);
   end Attach_Interface;

   -------------------
   -- Create_Server --
   -------------------

   procedure Create_Server
     (Server_Context : in out Rose.Server.Server_Context;
      Badge          : Badge_Handler;
      Set_Label      : Set_Label_Handler;
      Instanced      : Boolean := False)
   is
   begin
      Attach_Interface (Server_Context, Badge, Set_Label, Instanced);
   end Create_Server;

   -------------------
   -- Get_Badge_Cap --
   -------------------

   function Get_Badge_Cap return Rose.Capabilities.Capability is (Badge_Cap);

   -----------------------
   -- Get_Set_Label_Cap --
   -----------------------

   function Get_Set_Label_Cap
      return Rose.Capabilities.Capability
   is (Set_Label_Cap);

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

   -----------------------------------
   -- Handle_Get_Labelled_Interface --
   -----------------------------------

   procedure Handle_Get_Labelled_Interface
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
      if Set_Label_Cap = Rose.Capabilities.Null_Capability then
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
      else
         Cap := Set_Label_Cap;
      end if;
      Rose.System_Calls.Send_Cap (Parameters, Cap);
   end Handle_Get_Labelled_Interface;

   ----------------------
   -- Handle_Set_Label --
   ----------------------

   procedure Handle_Set_Label
     (Parameters : in out Rose.Invocation.Invocation_Record)
   is
      Label : constant Rose.Words.Word :=
        Rose.System_Calls.Get_Word_32 (Parameters, 0);
   begin
      Local_Set_Label (Parameters.Identifier, Label);
      Rose.System_Calls.Initialize_Reply (Parameters, Parameters.Reply_Cap);
   end Handle_Set_Label;

   -----------------------
   -- Publish_Interface --
   -----------------------

   procedure Publish_Interface
     (Server_Context : in out Rose.Server.Server_Context;
      Badge          : Badge_Handler;
      Set_Label      : Set_Label_Handler)
   is
   begin
      Local_Badge := Badge;
      Local_Set_Label := Set_Label;
      Badge_Cap := Rose.Server.Create_Endpoint (Badge_Endpoint);
      Set_Label_Cap := Rose.Server.Create_Endpoint (Set_Label_Endpoint);
      Published_Cap := Rose.Server.Create_Endpoint (Labelled_Interface);
      Rose.Server.Register_Handler
        (Server_Context,
         Labelled_Interface,
         Handle_Get_Labelled_Interface'Access);
      Rose.Server.Register_Handler
        (Server_Context,
         Badge_Endpoint,
         Handle_Badge'Access);
      Rose.Server.Register_Handler
        (Server_Context,
         Set_Label_Endpoint,
         Handle_Set_Label'Access);
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

end Rose.Interfaces.Labelled.Server;
