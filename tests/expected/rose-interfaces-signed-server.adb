with Rose.Invocation;
with Rose.System_Calls;

package body Rose.Interfaces.Signed.Server is

   Server_Instance  : Rose.Server.Server_Instance;

   Local_Clamp      : Clamp_Handler;

   Clamp_Cap        : Rose.Capabilities.Capability :=
     Rose.Capabilities.Null_Capability;

   Local_Position   : Position_Handler;

   Position_Cap     : Rose.Capabilities.Capability :=
     Rose.Capabilities.Null_Capability;

   Local_Offset     : Offset_Handler;

   Offset_Cap       : Rose.Capabilities.Capability :=
     Rose.Capabilities.Null_Capability;

   Local_Difference : Difference_Handler;

   Difference_Cap   : Rose.Capabilities.Capability :=
     Rose.Capabilities.Null_Capability;

   Local_Bounds     : Bounds_Handler;

   Bounds_Cap       : Rose.Capabilities.Capability :=
     Rose.Capabilities.Null_Capability;

   Published_Cap    : Rose.Capabilities.Capability :=
     Rose.Capabilities.Null_Capability;

   procedure Handle_Get_Signed_Interface
     (Parameters : in out Rose.Invocation.Invocation_Record);

   procedure Handle_Clamp
     (Parameters : in out Rose.Invocation.Invocation_Record);

   procedure Handle_Position
     (Parameters : in out Rose.Invocation.Invocation_Record);

   procedure Handle_Offset
     (Parameters : in out Rose.Invocation.Invocation_Record);

   procedure Handle_Difference
     (Parameters : in out Rose.Invocation.Invocation_Record);

   procedure Handle_Bounds
     (Parameters : in out Rose.Invocation.Invocation_Record);

   ----------------------
   -- Attach_Interface --
   ----------------------

   procedure Attach_Interface
     (Server_Context : in out Rose.Server.Server_Context;
      Clamp          : Clamp_Handler;
      Position       : Position_Handler;
      Offset         : Offset_Handler;
      Difference     : Difference_Handler;
      Bounds         : Bounds_Handler;
      Instanced      : Boolean := False)
   is
   begin
      Local_Clamp := Clamp;
      Local_Position := Position;
      Local_Offset := Offset;
      Local_Difference := Difference;
      Local_Bounds := Bounds;
      Rose.Server.Register_Handler
        (Server_Context,
         Signed_Interface,
         Handle_Get_Signed_Interface'Access);
      if not Instanced then
         Clamp_Cap := Rose.Server.Create_Endpoint (Clamp_Endpoint);
         Position_Cap := Rose.Server.Create_Endpoint (Position_Endpoint);
         Offset_Cap := Rose.Server.Create_Endpoint (Offset_Endpoint);
         Difference_Cap := Rose.Server.Create_Endpoint (Difference_Endpoint);
         Bounds_Cap := Rose.Server.Create_Endpoint (Bounds_Endpoint);
         Rose.Server.Create_Anonymous_Endpoint (Signed_Interface);
      end if;
      Rose.Server.Register_Handler
        (Server_Context,
         Clamp_Endpoint,
         Handle_Clamp'Access);
      Rose.Server.Register_Handler
        (Server_Context,
         Position_Endpoint,
         Handle_Position'Access);
      Rose.Server.Register_Handler
        (Server_Context,
         Offset_Endpoint,
         Handle_Offset'Access);
      Rose.Server.Register_Handler
        (Server_Context,
         Difference_Endpoint,
         Handle_Difference'Access);
      Rose.Server.Register_Handler
        (Server_Context,
         Bounds_Endpoint,
         Handle_Bounds'Access);
   end Attach_Interface;

   -------------------
   -- Create_Server --
   -------------------

   procedure Create_Server
     (Server_Context : in out Rose.Server.Server_Context;
      Clamp          : Clamp_Handler;
      Position       : Position_Handler;
      Offset         : Offset_Handler;
      Difference     : Difference_Handler;
      Bounds         : Bounds_Handler;
      Instanced      : Boolean := False)
   is
   begin
      Attach_Interface
        (Server_Context,
         Clamp,
         Position,
         Offset,
         Difference,
         Bounds,
         Instanced);
   end Create_Server;

   --------------------
   -- Get_Bounds_Cap --
   --------------------

   function Get_Bounds_Cap return Rose.Capabilities.Capability is (Bounds_Cap);

   -------------------
   -- Get_Clamp_Cap --
   -------------------

   function Get_Clamp_Cap return Rose.Capabilities.Capability is (Clamp_Cap);

   ------------------------
   -- Get_Difference_Cap --
   ------------------------

   function Get_Difference_Cap
      return Rose.Capabilities.Capability
   is (Difference_Cap);

   --------------------
   -- Get_Offset_Cap --
   --------------------

   function Get_Offset_Cap return Rose.Capabilities.Capability is (Offset_Cap);

   ----------------------
   -- Get_Position_Cap --
   ----------------------

   function Get_Position_Cap
      return Rose.Capabilities.Capability
   is (Position_Cap);

   -------------------
   -- Handle_Bounds --
   -------------------

   procedure Handle_Bounds
     (Parameters : in out Rose.Invocation.Invocation_Record)
   is
      Low  : Long_Long_Integer;
      High : Long_Long_Integer;
   begin
      Local_Bounds (Parameters.Identifier, Low, High);
      Rose.System_Calls.Initialize_Reply (Parameters, Parameters.Reply_Cap);
      Rose.System_Calls.Send_Integer_64 (Parameters, Low);
      Rose.System_Calls.Send_Integer_64 (Parameters, High);
   end Handle_Bounds;

   ------------------
   -- Handle_Clamp --
   ------------------

   procedure Handle_Clamp
     (Parameters : in out Rose.Invocation.Invocation_Record)
   is
      Value  : constant Integer :=
        Rose.System_Calls.Get_Integer (Parameters, 0);
      Low    : constant Integer :=
        Rose.System_Calls.Get_Integer (Parameters, 1);
      Result : constant Integer :=
        Local_Clamp (Parameters.Identifier, Value, Low);
   begin
      Rose.System_Calls.Initialize_Reply (Parameters, Parameters.Reply_Cap);
      Rose.System_Calls.Send_Integer (Parameters, Result);
   end Handle_Clamp;

   -----------------------
   -- Handle_Difference --
   -----------------------

   procedure Handle_Difference
     (Parameters : in out Rose.Invocation.Invocation_Record)
   is
      Left   : constant Long_Long_Integer :=
        Rose.System_Calls.Get_Integer_64 (Parameters, 0);
      Right  : constant Long_Long_Integer :=
        Rose.System_Calls.Get_Integer_64 (Parameters, 2);
      Result : constant Long_Long_Integer :=
        Local_Difference (Parameters.Identifier, Left, Right);
   begin
      Rose.System_Calls.Initialize_Reply (Parameters, Parameters.Reply_Cap);
      Rose.System_Calls.Send_Integer_64 (Parameters, Result);
   end Handle_Difference;

   ---------------------------------
   -- Handle_Get_Signed_Interface --
   ---------------------------------

   procedure Handle_Get_Signed_Interface
     (Parameters : in out Rose.Invocation.Invocation_Record)
   is
      use type Rose.Capabilities.Capability;
      Cap        : Rose.Capabilities.Capability;
      Identifier : constant Rose.Objects.Capability_Identifier :=
        Parameters.Identifier;
   begin
      Rose.System_Calls.Initialize_Reply (Parameters, Parameters.Reply_Cap);
      if Clamp_Cap = Rose.Capabilities.Null_Capability then
         if not Rose.Server.Has_Instance
           (Server_Instance,
            Clamp_Endpoint,
            Identifier)
         then
            Rose.Server.Set_Instance_Cap
              (Server_Instance,
               Clamp_Endpoint,
               Identifier,
               Rose.Server.Create_Endpoint (Clamp_Endpoint, Identifier));
         end if;
         Cap :=
           Rose.Server.Get_Instance_Cap
             (Server_Instance,
              Clamp_Endpoint,
              Identifier);
      else
         Cap := Clamp_Cap;
      end if;
      Rose.System_Calls.Send_Cap (Parameters, Cap);
      if Position_Cap = Rose.Capabilities.Null_Capability then
         if not Rose.Server.Has_Instance
           (Server_Instance,
            Position_Endpoint,
            Identifier)
         then
            Rose.Server.Set_Instance_Cap
              (Server_Instance,
               Position_Endpoint,
               Identifier,
               Rose.Server.Create_Endpoint (Position_Endpoint, Identifier));
         end if;
         Cap :=
           Rose.Server.Get_Instance_Cap
             (Server_Instance,
              Position_Endpoint,
              Identifier);
      else
         Cap := Position_Cap;
      end if;
      Rose.System_Calls.Send_Cap (Parameters, Cap);
      if Offset_Cap = Rose.Capabilities.Null_Capability then
         if not Rose.Server.Has_Instance
           (Server_Instance,
            Offset_Endpoint,
            Identifier)
         then
            Rose.Server.Set_Instance_Cap
              (Server_Instance,
               Offset_Endpoint,
               Identifier,
               Rose.Server.Create_Endpoint (Offset_Endpoint, Identifier));
         end if;
         Cap :=
           Rose.Server.Get_Instance_Cap
             (Server_Instance,
              Offset_Endpoint,
              Identifier);
      else
         Cap := Offset_Cap;
      end if;
      Rose.System_Calls.Send_Cap (Parameters, Cap);
      if Difference_Cap = Rose.Capabilities.Null_Capability then
         if not Rose.Server.Has_Instance
           (Server_Instance,
            Difference_Endpoint,
            Identifier)
         then
            Rose.Server.Set_Instance_Cap
              (Server_Instance,
               Difference_Endpoint,
               Identifier,
               Rose.Server.Create_Endpoint (Difference_Endpoint, Identifier));
         end if;
         Cap :=
           Rose.Server.Get_Instance_Cap
             (Server_Instance,
              Difference_Endpoint,
              Identifier);
      else
         Cap := Difference_Cap;
      end if;
      Rose.System_Calls.Send_Cap (Parameters, Cap);
      if Bounds_Cap = Rose.Capabilities.Null_Capability then
         if not Rose.Server.Has_Instance
           (Server_Instance,
            Bounds_Endpoint,
            Identifier)
         then
            Rose.Server.Set_Instance_Cap
              (Server_Instance,
               Bounds_Endpoint,
               Identifier,
               Rose.Server.Create_Endpoint (Bounds_Endpoint, Identifier));
         end if;
         Cap :=
           Rose.Server.Get_Instance_Cap
             (Server_Instance,
              Bounds_Endpoint,
              Identifier);
      else
         Cap := Bounds_Cap;
      end if;
      Rose.System_Calls.Send_Cap (Parameters, Cap);
   end Handle_Get_Signed_Interface;

   -------------------
   -- Handle_Offset --
   -------------------

   procedure Handle_Offset
     (Parameters : in out Rose.Invocation.Invocation_Record)
   is
      Delta_X : Integer := Rose.System_Calls.Get_Integer (Parameters, 0);
   begin
      Local_Offset (Parameters.Identifier, Delta_X);
      Rose.System_Calls.Initialize_Reply (Parameters, Parameters.Reply_Cap);
      Rose.System_Calls.Send_Integer (Parameters, Delta_X);
   end Handle_Offset;

   ---------------------
   -- Handle_Position --
   ---------------------

   procedure Handle_Position
     (Parameters : in out Rose.Invocation.Invocation_Record)
   is
      Index : constant Rose.Words.Word :=
        Rose.System_Calls.Get_Word_32 (Parameters, 0);
      X     : Integer;
      Y     : Integer;
      Count : Natural;
   begin
      Local_Position (Parameters.Identifier, Index, X, Y, Count);
      Rose.System_Calls.Initialize_Reply (Parameters, Parameters.Reply_Cap);
      Rose.System_Calls.Send_Integer (Parameters, X);
      Rose.System_Calls.Send_Integer (Parameters, Y);
      Rose.System_Calls.Send_Word (Parameters, Count);
   end Handle_Position;

   -----------------------
   -- Publish_Interface --
   -----------------------

   procedure Publish_Interface
     (Server_Context : in out Rose.Server.Server_Context;
      Clamp          : Clamp_Handler;
      Position       : Position_Handler;
      Offset         : Offset_Handler;
      Difference     : Difference_Handler;
      Bounds         : Bounds_Handler)
   is
   begin
      Local_Clamp := Clamp;
      Local_Position := Position;
      Local_Offset := Offset;
      Local_Difference := Difference;
      Local_Bounds := Bounds;
      Clamp_Cap := Rose.Server.Create_Endpoint (Clamp_Endpoint);
      Position_Cap := Rose.Server.Create_Endpoint (Position_Endpoint);
      Offset_Cap := Rose.Server.Create_Endpoint (Offset_Endpoint);
      Difference_Cap := Rose.Server.Create_Endpoint (Difference_Endpoint);
      Bounds_Cap := Rose.Server.Create_Endpoint (Bounds_Endpoint);
      Published_Cap := Rose.Server.Create_Endpoint (Signed_Interface);
      Rose.Server.Register_Handler
        (Server_Context,
         Signed_Interface,
         Handle_Get_Signed_Interface'Access);
      Rose.Server.Register_Handler
        (Server_Context,
         Clamp_Endpoint,
         Handle_Clamp'Access);
      Rose.Server.Register_Handler
        (Server_Context,
         Position_Endpoint,
         Handle_Position'Access);
      Rose.Server.Register_Handler
        (Server_Context,
         Offset_Endpoint,
         Handle_Offset'Access);
      Rose.Server.Register_Handler
        (Server_Context,
         Difference_Endpoint,
         Handle_Difference'Access);
      Rose.Server.Register_Handler
        (Server_Context,
         Bounds_Endpoint,
         Handle_Bounds'Access);
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

end Rose.Interfaces.Signed.Server;
