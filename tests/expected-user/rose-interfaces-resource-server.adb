with Rose.Interfaces.Objects;
with Rose.Invocation;
with Rose.System_Calls;
with System;

package body Rose.Interfaces.Resource.Server is

   Server_Instance : Rose.Server.Server_Instance;

   type Object_Access is access all Resource_Interface'Class;

   type Attached_Object is record
      Object     : Object_Access;
      Identifier : Rose.Objects.Capability_Identifier := 0;
      Cap        : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
      Retired    : Boolean := False;
   end record;

   Max_Attached    : constant := 16;

   type Attached_Array is array (0 .. (Max_Attached - 1)) of Attached_Object;

   Attached        : Attached_Array;

   Attached_Count  : Natural := 0;

   Registered      : Boolean := False;

   function Find
     (Identifier : Rose.Objects.Capability_Identifier)
      return Object_Access;

   function Owns
     (Identifier : Rose.Objects.Capability_Identifier)
      return Boolean;

   function Free_Slot return Natural;

   function Slot_Of
     (Identifier : Rose.Objects.Capability_Identifier)
      return Natural;

   procedure Detach (Identifier : Rose.Objects.Capability_Identifier);

   procedure Handle_Get_Resource_Interface
     (Parameters : in out Rose.Invocation.Invocation_Record);

   procedure Handle_Release
     (Parameters : in out Rose.Invocation.Invocation_Record);

   ------------
   -- Attach --
   ------------

   procedure Attach
     (Server_Context : in out Rose.Server.Server_Context;
      Object         : not null access Resource_Interface'Class)
   is
      Slot : constant Natural := Free_Slot;
   begin
      if not Registered then
         Rose.Server.Register_Handler
           (Server_Context,
            Rose.Interfaces.Resource.Resource_Interface,
            Handle_Get_Resource_Interface'Access,
            Owns'Access);
         Rose.Server.Register_Handler
           (Server_Context,
            Release_Endpoint,
            Handle_Release'Access,
            Owns'Access);
         Registered := True;
      end if;
      if Slot = Max_Attached then
         raise Constraint_Error with "Resource.Server: too many objects";
      end if;
      Attached (Slot).Object := Object_Access (Object);
      Attached (Slot).Identifier := Rose.Server.New_Identifier;
      Attached (Slot).Cap :=
        Rose.Server.Create_Endpoint
          (Rose.Interfaces.Resource.Resource_Interface,
           Attached (Slot).Identifier);
      if Slot = Attached_Count then
         Attached_Count := Attached_Count + 1;
      end if;
   end Attach;

   ------------
   -- Cap_Of --
   ------------

   function Cap_Of
     (Object       : Resource_Interface'Class;
      Interface_Id : Rose.Objects.Endpoint_Id :=
        Rose.Interfaces.Resource.Resource_Interface)
      return Rose.Capabilities.Capability
   is
      use type System.Address;
      use type Rose.Objects.Endpoint_Id;
   begin
      for Item of Attached loop
         if Item.Object /= null
           and then Item.Object.all'Address = Object'Address
         then
            if Interface_Id = Rose.Interfaces.Resource.Resource_Interface then
               return Item.Cap;
            end if;
         end if;
      end loop;
      raise Rose.Interfaces.Objects.Not_Served
        with "Rose.Interfaces.Resource.Server.Cap_Of";
   end Cap_Of;

   ------------
   -- Detach --
   ------------

   procedure Detach (Identifier : Rose.Objects.Capability_Identifier) is
      use type Rose.Capabilities.Capability;
      use type Rose.Objects.Capability_Identifier;
      Slot : constant Natural := Slot_Of (Identifier);
   begin
      if Slot = Max_Attached then
         return;
      end if;
      if Rose.System_Calls.Rescind_Cap_Capability = Rose.Capabilities
        .Null_Capability
      then
         Attached (Slot).Retired := True;
      else
         Rose.System_Calls.Rescind_Cap (Attached (Slot).Cap);
         if Rose.Server.Has_Instance
           (Server_Instance,
            Release_Endpoint,
            Identifier)
         then
            Rose.System_Calls.Rescind_Cap
              (Rose.Server.Get_Instance_Cap
                 (Server_Instance,
                  Release_Endpoint,
                  Identifier));
         end if;
         if Rose.Server.Has_Instance
           (Server_Instance,
            Rose.Interfaces.Resource.Resource_Interface,
            Identifier)
         then
            Rose.System_Calls.Rescind_Cap
              (Rose.Server.Get_Instance_Cap
                 (Server_Instance,
                  Rose.Interfaces.Resource.Resource_Interface,
                  Identifier));
         end if;
         if Identifier /= 0 then
            Rose.Server.Free_Identifier (Identifier);
         end if;
      end if;
      Rose.Server.Remove_Instance (Server_Instance, Identifier);
      Rose.System_Calls.Delete_Cap (Attached (Slot).Cap);
      Attached (Slot).Object := null;
      Attached (Slot).Cap := Rose.Capabilities.Null_Capability;
   end Detach;

   ----------
   -- Find --
   ----------

   function Find
     (Identifier : Rose.Objects.Capability_Identifier)
      return Object_Access
   is
      use type Rose.Objects.Capability_Identifier;
   begin
      if Identifier = 0 then
         return Attached (0).Object;
      end if;
      for Item of Attached loop
         if Item.Object /= null and then Item.Identifier = Identifier then
            return Item.Object;
         end if;
      end loop;
      return null;
   end Find;

   ---------------
   -- Free_Slot --
   ---------------

   function Free_Slot return Natural is
      Index : Natural := 0;
   begin
      for Item of Attached loop
         if Index < Attached_Count and then Item.Object = null
           and then not Item.Retired
         then
            return Index;
         end if;
         Index := Index + 1;
      end loop;
      return Attached_Count;
   end Free_Slot;

   -----------------------------------
   -- Handle_Get_Resource_Interface --
   -----------------------------------

   procedure Handle_Get_Resource_Interface
     (Parameters : in out Rose.Invocation.Invocation_Record)
   is
      Cap        : Rose.Capabilities.Capability;
      Identifier : constant Rose.Objects.Capability_Identifier :=
        Parameters.Identifier;
   begin
      Rose.System_Calls.Initialize_Reply (Parameters, Parameters.Reply_Cap);
      if not Rose.Server.Has_Instance
        (Server_Instance,
         Release_Endpoint,
         Identifier)
      then
         Rose.Server.Set_Instance_Cap
           (Server_Instance,
            Release_Endpoint,
            Identifier,
            Rose.Server.Create_Endpoint (Release_Endpoint, Identifier));
      end if;
      Cap :=
        Rose.Server.Get_Instance_Cap
          (Server_Instance,
           Release_Endpoint,
           Identifier);
      Rose.System_Calls.Send_Cap (Parameters, Cap);
   end Handle_Get_Resource_Interface;

   --------------------
   -- Handle_Release --
   --------------------

   procedure Handle_Release
     (Parameters : in out Rose.Invocation.Invocation_Record)
   is
   begin
      begin
         declare
            Object : constant Object_Access := Find (Parameters.Identifier);
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
            Object.Release;
            Detach (Parameters.Identifier);
            Rose.System_Calls.Initialize_Reply
              (Parameters,
               Parameters.Reply_Cap);
         end;
      exception
         when others =>
            Rose.System_Calls.Initialize_Reply
              (Parameters,
               Parameters.Reply_Cap);
            Rose.System_Calls.Send_Error
              (Parameters,
               Rose.Invocation.Exception_Raised);
      end;
   end Handle_Release;

   -------------------
   -- Interface_Cap --
   -------------------

   function Interface_Cap
     (Object : not null access Resource_Interface'Class)
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

   ----------
   -- Owns --
   ----------

   function Owns
     (Identifier : Rose.Objects.Capability_Identifier)
      return Boolean
   is
   begin
      return Find (Identifier) /= null;
   end Owns;

   -------------
   -- Publish --
   -------------

   procedure Publish
     (Server_Context : in out Rose.Server.Server_Context;
      Object         : not null access Resource_Interface'Class)
   is
   begin
      Attach (Server_Context, Object);
      Rose.Server.Publish_Interface (Interface_Cap (Object));
   end Publish;

   -------------
   -- Slot_Of --
   -------------

   function Slot_Of
     (Identifier : Rose.Objects.Capability_Identifier)
      return Natural
   is
      use type Rose.Objects.Capability_Identifier;
      Index : Natural := 0;
   begin
      if Identifier = 0 then
         return 0;
      end if;
      for Item of Attached loop
         if Item.Object /= null and then Item.Identifier = Identifier then
            return Index;
         end if;
         Index := Index + 1;
      end loop;
      return Max_Attached;
   end Slot_Of;

end Rose.Interfaces.Resource.Server;
