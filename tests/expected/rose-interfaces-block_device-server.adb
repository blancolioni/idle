with Rose.Invocation;
with Rose.System_Calls;
with Rose.Words;

package body Rose.Interfaces.Block_Device.Server is

   Server_Instance      : Rose.Server.Server_Instance;

   Local_Get_Parameters : Get_Parameters_Handler;

   Get_Parameters_Cap   : Rose.Capabilities.Capability :=
     Rose.Capabilities.Null_Capability;

   Local_Read_Blocks    : Read_Blocks_Handler;

   Read_Blocks_Cap      : Rose.Capabilities.Capability :=
     Rose.Capabilities.Null_Capability;

   Local_Write_Blocks   : Write_Blocks_Handler;

   Write_Blocks_Cap     : Rose.Capabilities.Capability :=
     Rose.Capabilities.Null_Capability;

   Published_Cap        : Rose.Capabilities.Capability :=
     Rose.Capabilities.Null_Capability;

   procedure Handle_Get_Block_Device_Interface
     (Parameters : in out Rose.Invocation.Invocation_Record);

   procedure Handle_Get_Parameters
     (Parameters : in out Rose.Invocation.Invocation_Record);

   procedure Handle_Read_Blocks
     (Parameters : in out Rose.Invocation.Invocation_Record);

   procedure Handle_Write_Blocks
     (Parameters : in out Rose.Invocation.Invocation_Record);

   ----------------------
   -- Attach_Interface --
   ----------------------

   procedure Attach_Interface
     (Server_Context : in out Rose.Server.Server_Context;
      Get_Parameters : Get_Parameters_Handler;
      Read_Blocks    : Read_Blocks_Handler;
      Write_Blocks   : Write_Blocks_Handler;
      Instanced      : Boolean := False)
   is
   begin
      Local_Get_Parameters := Get_Parameters;
      Local_Read_Blocks := Read_Blocks;
      Local_Write_Blocks := Write_Blocks;
      Rose.Server.Register_Handler
        (Server_Context,
         Block_Device_Interface,
         Handle_Get_Block_Device_Interface'Access);
      if not Instanced then
         Get_Parameters_Cap :=
           Rose.Server.Create_Endpoint (Get_Parameters_Endpoint);
         Read_Blocks_Cap := Rose.Server.Create_Endpoint (Read_Blocks_Endpoint);
         Write_Blocks_Cap :=
           Rose.Server.Create_Endpoint (Write_Blocks_Endpoint);
         Rose.Server.Create_Anonymous_Endpoint (Block_Device_Interface);
      end if;
      Rose.Server.Register_Handler
        (Server_Context,
         Get_Parameters_Endpoint,
         Handle_Get_Parameters'Access);
      Rose.Server.Register_Handler
        (Server_Context,
         Read_Blocks_Endpoint,
         Handle_Read_Blocks'Access);
      Rose.Server.Register_Handler
        (Server_Context,
         Write_Blocks_Endpoint,
         Handle_Write_Blocks'Access);
   end Attach_Interface;

   -------------------
   -- Create_Server --
   -------------------

   procedure Create_Server
     (Server_Context : in out Rose.Server.Server_Context;
      Get_Parameters : Get_Parameters_Handler;
      Read_Blocks    : Read_Blocks_Handler;
      Write_Blocks   : Write_Blocks_Handler;
      Instanced      : Boolean := False)
   is
   begin
      Attach_Interface
        (Server_Context,
         Get_Parameters,
         Read_Blocks,
         Write_Blocks,
         Instanced);
   end Create_Server;

   ----------------------------
   -- Get_Get_Parameters_Cap --
   ----------------------------

   function Get_Get_Parameters_Cap
      return Rose.Capabilities.Capability
   is (Get_Parameters_Cap);

   -------------------------
   -- Get_Read_Blocks_Cap --
   -------------------------

   function Get_Read_Blocks_Cap
      return Rose.Capabilities.Capability
   is (Read_Blocks_Cap);

   --------------------------
   -- Get_Write_Blocks_Cap --
   --------------------------

   function Get_Write_Blocks_Cap
      return Rose.Capabilities.Capability
   is (Write_Blocks_Cap);

   ---------------------------------------
   -- Handle_Get_Block_Device_Interface --
   ---------------------------------------

   procedure Handle_Get_Block_Device_Interface
     (Parameters : in out Rose.Invocation.Invocation_Record)
   is
      use type Rose.Capabilities.Capability;
      Cap        : Rose.Capabilities.Capability;
      Identifier : constant Rose.Objects.Capability_Identifier :=
        Parameters.Identifier;
   begin
      Rose.System_Calls.Initialize_Reply (Parameters, Parameters.Reply_Cap);
      if Get_Parameters_Cap = Rose.Capabilities.Null_Capability then
         if not Rose.Server.Has_Instance
           (Server_Instance,
            Get_Parameters_Endpoint,
            Identifier)
         then
            Rose.Server.Set_Instance_Cap
              (Server_Instance,
               Get_Parameters_Endpoint,
               Identifier,
               Rose.Server.Create_Endpoint
                 (Get_Parameters_Endpoint,
                  Identifier));
         end if;
         Cap :=
           Rose.Server.Get_Instance_Cap
             (Server_Instance,
              Get_Parameters_Endpoint,
              Identifier);
      else
         Cap := Get_Parameters_Cap;
      end if;
      Rose.System_Calls.Send_Cap (Parameters, Cap);
      if Read_Blocks_Cap = Rose.Capabilities.Null_Capability then
         if not Rose.Server.Has_Instance
           (Server_Instance,
            Read_Blocks_Endpoint,
            Identifier)
         then
            Rose.Server.Set_Instance_Cap
              (Server_Instance,
               Read_Blocks_Endpoint,
               Identifier,
               Rose.Server.Create_Endpoint (Read_Blocks_Endpoint, Identifier));
         end if;
         Cap :=
           Rose.Server.Get_Instance_Cap
             (Server_Instance,
              Read_Blocks_Endpoint,
              Identifier);
      else
         Cap := Read_Blocks_Cap;
      end if;
      Rose.System_Calls.Send_Cap (Parameters, Cap);
      if Write_Blocks_Cap = Rose.Capabilities.Null_Capability then
         if not Rose.Server.Has_Instance
           (Server_Instance,
            Write_Blocks_Endpoint,
            Identifier)
         then
            Rose.Server.Set_Instance_Cap
              (Server_Instance,
               Write_Blocks_Endpoint,
               Identifier,
               Rose.Server.Create_Endpoint
                 (Write_Blocks_Endpoint,
                  Identifier));
         end if;
         Cap :=
           Rose.Server.Get_Instance_Cap
             (Server_Instance,
              Write_Blocks_Endpoint,
              Identifier);
      else
         Cap := Write_Blocks_Cap;
      end if;
      Rose.System_Calls.Send_Cap (Parameters, Cap);
   end Handle_Get_Block_Device_Interface;

   ---------------------------
   -- Handle_Get_Parameters --
   ---------------------------

   procedure Handle_Get_Parameters
     (Parameters : in out Rose.Invocation.Invocation_Record)
   is
   begin
      declare
         Block_Count : Rose.Interfaces.Block_Device.Block_Address_Type;
         Block_Size  : Rose.Interfaces.Block_Device.Block_Size_Type;
      begin
         Local_Get_Parameters (Parameters.Identifier, Block_Count, Block_Size);
         Rose.System_Calls.Initialize_Reply (Parameters, Parameters.Reply_Cap);
         Rose.System_Calls.Send_Word
           (Parameters,
            Rose.Words.Word_64 (Block_Count));
         Rose.System_Calls.Send_Word
           (Parameters,
            Rose.Words.Word (Block_Size));
      exception
         when others =>
            Rose.System_Calls.Initialize_Reply
              (Parameters,
               Parameters.Reply_Cap);
            Rose.System_Calls.Send_Error
              (Parameters,
               Rose.Invocation.Exception_Raised);
      end;
   end Handle_Get_Parameters;

   ------------------------
   -- Handle_Read_Blocks --
   ------------------------

   procedure Handle_Read_Blocks
     (Parameters : in out Rose.Invocation.Invocation_Record)
   is
   begin
      declare
         Start  : constant Rose.Interfaces.Block_Device.Block_Address_Type :=
           Rose.Interfaces.Block_Device.Block_Address_Type
             (Rose.System_Calls.Get_Word_64 (Parameters, 0));
         Count  : constant Natural :=
           Natural (Rose.System_Calls.Get_Word_32 (Parameters, 2));
         Blocks : System.Storage_Elements.Storage_Array
           (1 .. Parameters.Buffer_Length)
           with Import, Address => Parameters.Buffer_Address;
      begin
         Local_Read_Blocks (Parameters.Identifier, Start, Count, Blocks);
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
   end Handle_Read_Blocks;

   -------------------------
   -- Handle_Write_Blocks --
   -------------------------

   procedure Handle_Write_Blocks
     (Parameters : in out Rose.Invocation.Invocation_Record)
   is
   begin
      declare
         Start  : constant Rose.Interfaces.Block_Device.Block_Address_Type :=
           Rose.Interfaces.Block_Device.Block_Address_Type
             (Rose.System_Calls.Get_Word_64 (Parameters, 0));
         Count  : constant Natural :=
           Natural (Rose.System_Calls.Get_Word_32 (Parameters, 2));
         Blocks : System.Storage_Elements.Storage_Array
           (1 .. Parameters.Buffer_Length)
           with Import, Address => Parameters.Buffer_Address;
      begin
         Local_Write_Blocks (Parameters.Identifier, Start, Count, Blocks);
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
   end Handle_Write_Blocks;

   -----------------------
   -- Publish_Interface --
   -----------------------

   procedure Publish_Interface
     (Server_Context : in out Rose.Server.Server_Context;
      Get_Parameters : Get_Parameters_Handler;
      Read_Blocks    : Read_Blocks_Handler;
      Write_Blocks   : Write_Blocks_Handler)
   is
   begin
      Local_Get_Parameters := Get_Parameters;
      Local_Read_Blocks := Read_Blocks;
      Local_Write_Blocks := Write_Blocks;
      Get_Parameters_Cap :=
        Rose.Server.Create_Endpoint (Get_Parameters_Endpoint);
      Read_Blocks_Cap := Rose.Server.Create_Endpoint (Read_Blocks_Endpoint);
      Write_Blocks_Cap := Rose.Server.Create_Endpoint (Write_Blocks_Endpoint);
      Published_Cap := Rose.Server.Create_Endpoint (Block_Device_Interface);
      Rose.Server.Register_Handler
        (Server_Context,
         Block_Device_Interface,
         Handle_Get_Block_Device_Interface'Access);
      Rose.Server.Register_Handler
        (Server_Context,
         Get_Parameters_Endpoint,
         Handle_Get_Parameters'Access);
      Rose.Server.Register_Handler
        (Server_Context,
         Read_Blocks_Endpoint,
         Handle_Read_Blocks'Access);
      Rose.Server.Register_Handler
        (Server_Context,
         Write_Blocks_Endpoint,
         Handle_Write_Blocks'Access);
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

end Rose.Interfaces.Block_Device.Server;
