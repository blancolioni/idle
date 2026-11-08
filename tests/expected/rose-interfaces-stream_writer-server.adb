with Rose.Invocation;
with Rose.System_Calls;

package body Rose.Interfaces.Stream_Writer.Server is

   Server_Instance : Rose.Server.Server_Instance;

   Local_Write     : Write_Handler;

   Write_Cap       : Rose.Capabilities.Capability :=
     Rose.Capabilities.Null_Capability;

   Published_Cap   : Rose.Capabilities.Capability :=
     Rose.Capabilities.Null_Capability;

   procedure Handle_Get_Stream_Writer_Interface
     (Parameters : in out Rose.Invocation.Invocation_Record);

   procedure Handle_Write
     (Parameters : in out Rose.Invocation.Invocation_Record);

   ----------------------
   -- Attach_Interface --
   ----------------------

   procedure Attach_Interface
     (Server_Context : in out Rose.Server.Server_Context;
      Write          : Write_Handler;
      Instanced      : Boolean := False)
   is
   begin
      Local_Write := Write;
      Rose.Server.Register_Handler
        (Server_Context,
         Stream_Writer_Interface,
         Handle_Get_Stream_Writer_Interface'Access);
      if not Instanced then
         Write_Cap := Rose.Server.Create_Endpoint (Write_Endpoint);
         Rose.Server.Create_Anonymous_Endpoint (Stream_Writer_Interface);
      end if;
      Rose.Server.Register_Handler
        (Server_Context,
         Write_Endpoint,
         Handle_Write'Access);
   end Attach_Interface;

   -------------------
   -- Create_Server --
   -------------------

   procedure Create_Server
     (Server_Context : in out Rose.Server.Server_Context;
      Write          : Write_Handler;
      Instanced      : Boolean := False)
   is
   begin
      Attach_Interface (Server_Context, Write, Instanced);
   end Create_Server;

   -------------------
   -- Get_Write_Cap --
   -------------------

   function Get_Write_Cap return Rose.Capabilities.Capability is (Write_Cap);

   ----------------------------------------
   -- Handle_Get_Stream_Writer_Interface --
   ----------------------------------------

   procedure Handle_Get_Stream_Writer_Interface
     (Parameters : in out Rose.Invocation.Invocation_Record)
   is
      use type Rose.Capabilities.Capability;
      Cap        : Rose.Capabilities.Capability;
      Identifier : constant Rose.Objects.Capability_Identifier :=
        Parameters.Identifier;
   begin
      Rose.System_Calls.Initialize_Reply (Parameters, Parameters.Reply_Cap);
      if Write_Cap = Rose.Capabilities.Null_Capability then
         if not Rose.Server.Has_Instance
           (Server_Instance,
            Write_Endpoint,
            Identifier)
         then
            Rose.Server.Set_Instance_Cap
              (Server_Instance,
               Write_Endpoint,
               Identifier,
               Rose.Server.Create_Endpoint (Write_Endpoint, Identifier));
         end if;
         Cap :=
           Rose.Server.Get_Instance_Cap
             (Server_Instance,
              Write_Endpoint,
              Identifier);
      else
         Cap := Write_Cap;
      end if;
      Rose.System_Calls.Send_Cap (Parameters, Cap);
   end Handle_Get_Stream_Writer_Interface;

   ------------------
   -- Handle_Write --
   ------------------

   procedure Handle_Write
     (Parameters : in out Rose.Invocation.Invocation_Record)
   is
      Buffer : System.Storage_Elements.Storage_Array
        (1 .. Parameters.Buffer_Length)
        with Import, Address => Parameters.Buffer_Address;
   begin
      Local_Write (Parameters.Identifier, Buffer);
      Rose.System_Calls.Initialize_Reply (Parameters, Parameters.Reply_Cap);
   end Handle_Write;

   -----------------------
   -- Publish_Interface --
   -----------------------

   procedure Publish_Interface
     (Server_Context : in out Rose.Server.Server_Context;
      Write          : Write_Handler)
   is
   begin
      Local_Write := Write;
      Write_Cap := Rose.Server.Create_Endpoint (Write_Endpoint);
      Published_Cap := Rose.Server.Create_Endpoint (Stream_Writer_Interface);
      Rose.Server.Register_Handler
        (Server_Context,
         Stream_Writer_Interface,
         Handle_Get_Stream_Writer_Interface'Access);
      Rose.Server.Register_Handler
        (Server_Context,
         Write_Endpoint,
         Handle_Write'Access);
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

end Rose.Interfaces.Stream_Writer.Server;
