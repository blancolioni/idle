with Rose.Invocation;
with Rose.System_Calls;
with Rose.Words;

package body Rose.Interfaces.Meter.Server is

   Server_Instance : Rose.Server.Server_Instance;

   Local_Sample    : Sample_Handler;

   Sample_Cap      : Rose.Capabilities.Capability :=
     Rose.Capabilities.Null_Capability;

   Local_Kind      : Kind_Handler;

   Kind_Cap        : Rose.Capabilities.Capability :=
     Rose.Capabilities.Null_Capability;

   Published_Cap   : Rose.Capabilities.Capability :=
     Rose.Capabilities.Null_Capability;

   Local_Owns      : Owns_Function := null;

   procedure Handle_Get_Meter_Interface
     (Parameters : in out Rose.Invocation.Invocation_Record);

   procedure Handle_Sample
     (Parameters : in out Rose.Invocation.Invocation_Record);

   procedure Handle_Kind
     (Parameters : in out Rose.Invocation.Invocation_Record);

   ----------------------
   -- Attach_Interface --
   ----------------------

   procedure Attach_Interface
     (Server_Context : in out Rose.Server.Server_Context;
      Sample         : Sample_Handler;
      Kind           : Kind_Handler;
      Instanced      : Boolean := False)
   is
   begin
      Local_Sample := Sample;
      Local_Kind := Kind;
      Rose.Server.Register_Handler
        (Server_Context,
         Meter_Interface,
         Handle_Get_Meter_Interface'Access);
      if not Instanced then
         Sample_Cap := Rose.Server.Create_Endpoint (Sample_Endpoint);
         Kind_Cap := Rose.Server.Create_Endpoint (Kind_Endpoint);
         Rose.Server.Create_Anonymous_Endpoint (Meter_Interface);
      end if;
      Rose.Server.Register_Handler
        (Server_Context,
         Sample_Endpoint,
         Handle_Sample'Access);
      Rose.Server.Register_Handler
        (Server_Context,
         Kind_Endpoint,
         Handle_Kind'Access);
   end Attach_Interface;

   -------------------
   -- Create_Server --
   -------------------

   procedure Create_Server
     (Server_Context : in out Rose.Server.Server_Context;
      Sample         : Sample_Handler;
      Kind           : Kind_Handler;
      Instanced      : Boolean := False)
   is
   begin
      Attach_Interface (Server_Context, Sample, Kind, Instanced);
   end Create_Server;

   ------------------
   -- Get_Kind_Cap --
   ------------------

   function Get_Kind_Cap return Rose.Capabilities.Capability is (Kind_Cap);

   --------------------
   -- Get_Sample_Cap --
   --------------------

   function Get_Sample_Cap return Rose.Capabilities.Capability is (Sample_Cap);

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
         if First >= 2 then
            Rose.System_Calls.Send_Error
              (Parameters,
               Rose.Invocation.Invalid_Operation);
         else
            if 0 in First .. (First + Page - 1) then
               if Sample_Cap = Rose.Capabilities.Null_Capability then
                  if not Rose.Server.Has_Instance
                    (Server_Instance,
                     Sample_Endpoint,
                     Identifier)
                  then
                     Rose.Server.Set_Instance_Cap
                       (Server_Instance,
                        Sample_Endpoint,
                        Identifier,
                        Rose.Server.Create_Endpoint
                          (Sample_Endpoint,
                           Identifier));
                  end if;
                  Cap :=
                    Rose.Server.Get_Instance_Cap
                      (Server_Instance,
                       Sample_Endpoint,
                       Identifier);
               else
                  Cap := Sample_Cap;
               end if;
               Rose.System_Calls.Send_Cap (Parameters, Cap);
            end if;
            if 1 in First .. (First + Page - 1) then
               if Kind_Cap = Rose.Capabilities.Null_Capability then
                  if not Rose.Server.Has_Instance
                    (Server_Instance,
                     Kind_Endpoint,
                     Identifier)
                  then
                     Rose.Server.Set_Instance_Cap
                       (Server_Instance,
                        Kind_Endpoint,
                        Identifier,
                        Rose.Server.Create_Endpoint
                          (Kind_Endpoint,
                           Identifier));
                  end if;
                  Cap :=
                    Rose.Server.Get_Instance_Cap
                      (Server_Instance,
                       Kind_Endpoint,
                       Identifier);
               else
                  Cap := Kind_Cap;
               end if;
               Rose.System_Calls.Send_Cap (Parameters, Cap);
            end if;
         end if;
      end if;
   end Handle_Get_Meter_Interface;

   -----------------
   -- Handle_Kind --
   -----------------

   procedure Handle_Kind
     (Parameters : in out Rose.Invocation.Invocation_Record)
   is
      Result : constant Rose.Interfaces.Core.Units.Unit_Kind :=
        Local_Kind (Parameters.Identifier);
   begin
      Rose.System_Calls.Initialize_Reply (Parameters, Parameters.Reply_Cap);
      Rose.System_Calls.Send_Word
        (Parameters,
         Natural (Rose.Interfaces.Core.Units.Unit_Kind'Pos (Result)));
   end Handle_Kind;

   -------------------
   -- Handle_Sample --
   -------------------

   procedure Handle_Sample
     (Parameters : in out Rose.Invocation.Invocation_Record)
   is
      Every : constant Rose.Interfaces.Core.Units.Duration :=
        Rose.Interfaces.Core.Units.Duration
          (Rose.System_Calls.Get_Word_64 (Parameters, 0));
      Used  : Rose.Interfaces.Core.Units.Bytes;
   begin
      Local_Sample (Parameters.Identifier, Every, Used);
      Rose.System_Calls.Initialize_Reply (Parameters, Parameters.Reply_Cap);
      Rose.System_Calls.Send_Word (Parameters, Rose.Words.Word_64 (Used));
   end Handle_Sample;

   -----------------------
   -- Publish_Interface --
   -----------------------

   procedure Publish_Interface
     (Server_Context : in out Rose.Server.Server_Context;
      Sample         : Sample_Handler;
      Kind           : Kind_Handler)
   is
   begin
      Local_Sample := Sample;
      Local_Kind := Kind;
      Sample_Cap := Rose.Server.Create_Endpoint (Sample_Endpoint);
      Kind_Cap := Rose.Server.Create_Endpoint (Kind_Endpoint);
      Published_Cap := Rose.Server.Create_Endpoint (Meter_Interface);
      Rose.Server.Register_Handler
        (Server_Context,
         Meter_Interface,
         Handle_Get_Meter_Interface'Access);
      Rose.Server.Register_Handler
        (Server_Context,
         Sample_Endpoint,
         Handle_Sample'Access);
      Rose.Server.Register_Handler
        (Server_Context,
         Kind_Endpoint,
         Handle_Kind'Access);
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

end Rose.Interfaces.Meter.Server;
