with Rose.Interfaces.Objects;
with Rose.Invocation;
with Rose.System_Calls;
with Rose.Words;
with System;

package body Rose.Interfaces.Toggle.Server is

   use type Rose.Words.Word_32;

   Server_Instance : Rose.Server.Server_Instance;

   type Object_Access is access all Toggle_Interface'Class;

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

   procedure Handle_Get_Toggle_Interface
     (Parameters : in out Rose.Invocation.Invocation_Record);

   procedure Handle_Is_On
     (Parameters : in out Rose.Invocation.Invocation_Record);

   procedure Handle_Switch
     (Parameters : in out Rose.Invocation.Invocation_Record);

   ------------
   -- Attach --
   ------------

   procedure Attach
     (Server_Context : in out Rose.Server.Server_Context;
      Object         : not null access Toggle_Interface'Class)
   is
   begin
      if not Registered then
         Rose.Server.Register_Handler
           (Server_Context,
            Rose.Interfaces.Toggle.Toggle_Interface,
            Handle_Get_Toggle_Interface'Access);
         Rose.Server.Register_Handler
           (Server_Context,
            Is_On_Endpoint,
            Handle_Is_On'Access);
         Rose.Server.Register_Handler
           (Server_Context,
            Switch_Endpoint,
            Handle_Switch'Access);
         Registered := True;
      end if;
      if Attached_Count = Max_Attached then
         raise Constraint_Error with "Toggle.Server: too many objects";
      end if;
      Attached (Attached_Count).Object := Object_Access (Object);
      Attached (Attached_Count).Cap :=
        Rose.Server.Create_Endpoint
          (Rose.Interfaces.Toggle.Toggle_Interface,
           Rose.Objects.Capability_Identifier (Attached_Count));
      Attached_Count := Attached_Count + 1;
   end Attach;

   ------------
   -- Cap_Of --
   ------------

   function Cap_Of
     (Object       : Toggle_Interface'Class;
      Interface_Id : Rose.Objects.Endpoint_Id :=
        Rose.Interfaces.Toggle.Toggle_Interface)
      return Rose.Capabilities.Capability
   is
      use type System.Address;
      use type Rose.Objects.Capability_Identifier;
      use type Rose.Objects.Endpoint_Id;
      Identifier : Rose.Objects.Capability_Identifier := 0;
   begin
      for Item of Attached loop
         if Item.Object /= null
           and then Item.Object.all'Address = Object'Address
         then
            if Interface_Id = Rose.Interfaces.Toggle.Toggle_Interface then
               return Item.Cap;
            end if;
         end if;
         Identifier := Identifier + 1;
      end loop;
      raise Rose.Interfaces.Objects.Not_Served
        with "Rose.Interfaces.Toggle.Server.Cap_Of";
   end Cap_Of;

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

   ---------------------------------
   -- Handle_Get_Toggle_Interface --
   ---------------------------------

   procedure Handle_Get_Toggle_Interface
     (Parameters : in out Rose.Invocation.Invocation_Record)
   is
      Cap        : Rose.Capabilities.Capability;
      Identifier : constant Rose.Objects.Capability_Identifier :=
        Parameters.Identifier;
   begin
      Rose.System_Calls.Initialize_Reply (Parameters, Parameters.Reply_Cap);
      if not Rose.Server.Has_Instance
        (Server_Instance,
         Is_On_Endpoint,
         Identifier)
      then
         Rose.Server.Set_Instance_Cap
           (Server_Instance,
            Is_On_Endpoint,
            Identifier,
            Rose.Server.Create_Endpoint (Is_On_Endpoint, Identifier));
      end if;
      Cap :=
        Rose.Server.Get_Instance_Cap
          (Server_Instance,
           Is_On_Endpoint,
           Identifier);
      Rose.System_Calls.Send_Cap (Parameters, Cap);
      if not Rose.Server.Has_Instance
        (Server_Instance,
         Switch_Endpoint,
         Identifier)
      then
         Rose.Server.Set_Instance_Cap
           (Server_Instance,
            Switch_Endpoint,
            Identifier,
            Rose.Server.Create_Endpoint (Switch_Endpoint, Identifier));
      end if;
      Cap :=
        Rose.Server.Get_Instance_Cap
          (Server_Instance,
           Switch_Endpoint,
           Identifier);
      Rose.System_Calls.Send_Cap (Parameters, Cap);
   end Handle_Get_Toggle_Interface;

   ------------------
   -- Handle_Is_On --
   ------------------

   procedure Handle_Is_On
     (Parameters : in out Rose.Invocation.Invocation_Record)
   is
   begin
      declare
         Object : constant Object_Access := Find (Parameters.Identifier);
         Result : Boolean;
      begin
         if Object = null then
            Rose.System_Calls.Initialize_Reply
              (Parameters,
               Parameters.Reply_Cap);
            Rose.System_Calls.Send_Error
              (Parameters,
               Rose.Invocation.Invalid_Operation);
            return;
         end if;
         Result := Object.Is_On;
         Rose.System_Calls.Initialize_Reply (Parameters, Parameters.Reply_Cap);
         Rose.System_Calls.Send_Word
           (Parameters,
            Natural (Boolean'Pos (Result)));
      exception
         when others =>
            Rose.System_Calls.Initialize_Reply
              (Parameters,
               Parameters.Reply_Cap);
            Rose.System_Calls.Send_Error
              (Parameters,
               Rose.Invocation.Exception_Raised);
      end;
   end Handle_Is_On;

   -------------------
   -- Handle_Switch --
   -------------------

   procedure Handle_Switch
     (Parameters : in out Rose.Invocation.Invocation_Record)
   is
   begin
      declare
         Object : constant Object_Access := Find (Parameters.Identifier);
         On     : constant Boolean :=
           Rose.System_Calls.Get_Word_32 (Parameters, 0) /= 0;
      begin
         if Object = null then
            Rose.System_Calls.Initialize_Reply
              (Parameters,
               Parameters.Reply_Cap);
            Rose.System_Calls.Send_Error
              (Parameters,
               Rose.Invocation.Invalid_Operation);
            return;
         end if;
         Object.Switch (On);
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
   end Handle_Switch;

   -------------------
   -- Interface_Cap --
   -------------------

   function Interface_Cap
     (Object : not null access Toggle_Interface'Class)
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
      Object         : not null access Toggle_Interface'Class)
   is
   begin
      Attach (Server_Context, Object);
      Rose.Server.Publish_Interface (Interface_Cap (Object));
   end Publish;

end Rose.Interfaces.Toggle.Server;
