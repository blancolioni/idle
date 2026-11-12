with Ada.Containers.Vectors;
with Rose.Interfaces.Objects;
with Rose.Interfaces.Process;
with Rose.Invocation;
with Rose.System_Calls;
with Rose.Texts;
with System;
with System.Storage_Elements;

package body Rose.Interfaces.Launch.Server is

   Server_Instance : Rose.Server.Server_Instance;

   type Object_Access is access all Launch_Interface'Class;

   type Attached_Object is record
      Object     : Object_Access;
      Identifier : Rose.Objects.Capability_Identifier := 0;
      Cap        : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
   end record;

   package Attached_Vectors is
     new Ada.Containers.Vectors (Natural, Attached_Object);

   Attached        : Attached_Vectors.Vector;

   Registered      : Boolean := False;

   subtype Process_Object_Class is
     Rose.Interfaces.Process.Process_Object'Class;

   function Find
     (Identifier : Rose.Objects.Capability_Identifier)
      return Object_Access;

   function Owns
     (Identifier : Rose.Objects.Capability_Identifier)
      return Boolean;

   procedure Handle_Get_Launch_Interface
     (Parameters : in out Rose.Invocation.Invocation_Record);

   procedure Handle_Launch
     (Parameters : in out Rose.Invocation.Invocation_Record);

   procedure Handle_Launch_Command
     (Parameters : in out Rose.Invocation.Invocation_Record);

   procedure Handle_Metadata
     (Parameters : in out Rose.Invocation.Invocation_Record);

   ------------
   -- Attach --
   ------------

   procedure Attach
     (Server_Context : in out Rose.Server.Server_Context;
      Object         : not null access Launch_Interface'Class;
      Identifier     : Rose.Objects.Capability_Identifier := 0)
   is
      use type Rose.Objects.Capability_Identifier;
   begin
      if not Registered then
         Rose.Server.Register_Handler
           (Server_Context,
            Rose.Interfaces.Launch.Launch_Interface,
            Handle_Get_Launch_Interface'Access,
            Owns'Access);
         Rose.Server.Register_Handler
           (Server_Context,
            Launch_Endpoint,
            Handle_Launch'Access,
            Owns'Access);
         Rose.Server.Register_Handler
           (Server_Context,
            Launch_Command_Endpoint,
            Handle_Launch_Command'Access,
            Owns'Access);
         Rose.Server.Register_Handler
           (Server_Context,
            Metadata_Endpoint,
            Handle_Metadata'Access,
            Owns'Access);
         Registered := True;
      end if;
      Attached.Append (Attached_Object'(others => <>));
      Attached (Attached.Last_Index).Object := Object_Access (Object);
      if Identifier = 0 then
         Attached (Attached.Last_Index).Identifier :=
           Rose.Server.New_Identifier;
      else
         Attached (Attached.Last_Index).Identifier := Identifier;
      end if;
      Attached (Attached.Last_Index).Cap :=
        Rose.Server.Create_Endpoint
          (Rose.Interfaces.Launch.Launch_Interface,
           Attached (Attached.Last_Index).Identifier);
   end Attach;

   ------------
   -- Cap_Of --
   ------------

   function Cap_Of
     (Object       : Launch_Interface'Class;
      Interface_Id : Rose.Objects.Endpoint_Id :=
        Rose.Interfaces.Launch.Launch_Interface)
      return Rose.Capabilities.Capability
   is
      use type System.Address;
      use type Rose.Objects.Endpoint_Id;
   begin
      for Item of Attached loop
         if Item.Object /= null
           and then Item.Object.all'Address = Object'Address
         then
            if Interface_Id = Rose.Interfaces.Launch.Launch_Interface then
               return Item.Cap;
            end if;
         end if;
      end loop;
      raise Rose.Interfaces.Objects.Not_Served
        with "Rose.Interfaces.Launch.Server.Cap_Of";
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
      if Identifier = 0 then
         if Attached.Is_Empty then
            return null;
         end if;
         return Attached (0).Object;
      end if;
      for Item of Attached loop
         if Item.Object /= null and then Item.Identifier = Identifier then
            return Item.Object;
         end if;
      end loop;
      return null;
   end Find;

   ---------------------------------
   -- Handle_Get_Launch_Interface --
   ---------------------------------

   procedure Handle_Get_Launch_Interface
     (Parameters : in out Rose.Invocation.Invocation_Record)
   is
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
      if First >= 3 then
         Rose.System_Calls.Send_Error
           (Parameters,
            Rose.Invocation.Invalid_Operation);
      else
         if 0 in First .. (First + Page - 1) then
            if not Rose.Server.Has_Instance
              (Server_Instance,
               Launch_Endpoint,
               Identifier)
            then
               Rose.Server.Set_Instance_Cap
                 (Server_Instance,
                  Launch_Endpoint,
                  Identifier,
                  Rose.Server.Create_Endpoint (Launch_Endpoint, Identifier));
            end if;
            Cap :=
              Rose.Server.Get_Instance_Cap
                (Server_Instance,
                 Launch_Endpoint,
                 Identifier);
            Rose.System_Calls.Send_Cap (Parameters, Cap);
         end if;
         if 1 in First .. (First + Page - 1) then
            if not Rose.Server.Has_Instance
              (Server_Instance,
               Launch_Command_Endpoint,
               Identifier)
            then
               Rose.Server.Set_Instance_Cap
                 (Server_Instance,
                  Launch_Command_Endpoint,
                  Identifier,
                  Rose.Server.Create_Endpoint
                    (Launch_Command_Endpoint,
                     Identifier));
            end if;
            Cap :=
              Rose.Server.Get_Instance_Cap
                (Server_Instance,
                 Launch_Command_Endpoint,
                 Identifier);
            Rose.System_Calls.Send_Cap (Parameters, Cap);
         end if;
         if 2 in First .. (First + Page - 1) then
            if not Rose.Server.Has_Instance
              (Server_Instance,
               Metadata_Endpoint,
               Identifier)
            then
               Rose.Server.Set_Instance_Cap
                 (Server_Instance,
                  Metadata_Endpoint,
                  Identifier,
                  Rose.Server.Create_Endpoint (Metadata_Endpoint, Identifier));
            end if;
            Cap :=
              Rose.Server.Get_Instance_Cap
                (Server_Instance,
                 Metadata_Endpoint,
                 Identifier);
            Rose.System_Calls.Send_Cap (Parameters, Cap);
         end if;
      end if;
   end Handle_Get_Launch_Interface;

   -------------------
   -- Handle_Launch --
   -------------------

   procedure Handle_Launch
     (Parameters : in out Rose.Invocation.Invocation_Record)
   is
      Received       : Rose.Capabilities.Capability_Array
        (1 .. Rose.Invocation.Max_Capabilities);
      Received_Count : constant Natural :=
        Rose.System_Calls.Copy_Received_Caps (Parameters, 0, Received);
   begin
      begin
         declare
            Object      : constant Object_Access :=
              Find (Parameters.Identifier);
            Caps        : Rose.Capabilities.Capability_Array
              (1 .. Rose.Invocation.Max_Capabilities);
            Caps_Count  : constant Natural :=
              Rose.System_Calls.Copy_Received_Caps (Parameters, 0, Caps);
            Environment : System.Storage_Elements.Storage_Array
              (1 .. Parameters.Buffer_Length)
              with Import, Address => Parameters.Buffer_Address;
         begin
            if Object = null then
               for Cap of Received (1 .. Received_Count) loop
                  Rose.System_Calls.Delete_Cap (Cap);
               end loop;
               Rose.System_Calls.Initialize_Reply
                 (Parameters,
                  Parameters.Reply_Cap);
               Rose.System_Calls.Send_Error
                 (Parameters,
                  Rose.Invocation.Invalid_Operation);
               return;
            end if;
            declare
               Result : Process_Object_Class :=
                 Object.Launch (Caps (1 .. Caps_Count), Environment);
            begin
               Rose.System_Calls.Initialize_Reply
                 (Parameters,
                  Parameters.Reply_Cap);
               Rose.System_Calls.Send_Cap (Parameters, Result.Process_Cap);
            end;
         end;
      exception
         when others =>
            for Cap of Received (1 .. Received_Count) loop
               Rose.System_Calls.Delete_Cap (Cap);
            end loop;
            Rose.System_Calls.Initialize_Reply
              (Parameters,
               Parameters.Reply_Cap);
            Rose.System_Calls.Send_Error
              (Parameters,
               Rose.Invocation.Exception_Raised);
      end;
   end Handle_Launch;

   ---------------------------
   -- Handle_Launch_Command --
   ---------------------------

   procedure Handle_Launch_Command
     (Parameters : in out Rose.Invocation.Invocation_Record)
   is
      Received       : Rose.Capabilities.Capability_Array
        (1 .. Rose.Invocation.Max_Capabilities);
      Received_Count : constant Natural :=
        Rose.System_Calls.Copy_Received_Caps (Parameters, 0, Received);
   begin
      begin
         declare
            Object     : constant Object_Access :=
              Find (Parameters.Identifier);
            Caps       : Rose.Capabilities.Capability_Array
              (1 .. Rose.Invocation.Max_Capabilities);
            Caps_Count : constant Natural :=
              Rose.System_Calls.Copy_Received_Caps (Parameters, 0, Caps);
            Result     : Rose.Capabilities.Capability;
         begin
            if Object = null then
               for Cap of Received (1 .. Received_Count) loop
                  Rose.System_Calls.Delete_Cap (Cap);
               end loop;
               Rose.System_Calls.Initialize_Reply
                 (Parameters,
                  Parameters.Reply_Cap);
               Rose.System_Calls.Send_Error
                 (Parameters,
                  Rose.Invocation.Invalid_Operation);
               return;
            end if;
            Result := Object.Launch_Command (Caps (1 .. Caps_Count));
            Rose.System_Calls.Initialize_Reply
              (Parameters,
               Parameters.Reply_Cap);
            Rose.System_Calls.Send_Cap (Parameters, Result);
         end;
      exception
         when others =>
            for Cap of Received (1 .. Received_Count) loop
               Rose.System_Calls.Delete_Cap (Cap);
            end loop;
            Rose.System_Calls.Initialize_Reply
              (Parameters,
               Parameters.Reply_Cap);
            Rose.System_Calls.Send_Error
              (Parameters,
               Rose.Invocation.Exception_Raised);
      end;
   end Handle_Launch_Command;

   ---------------------
   -- Handle_Metadata --
   ---------------------

   procedure Handle_Metadata
     (Parameters : in out Rose.Invocation.Invocation_Record)
   is
   begin
      begin
         declare
            Object : constant Object_Access := Find (Parameters.Identifier);
            Last   : Natural := 0;
            Result : String (1 .. Natural (Parameters.Buffer_Length))
              with Import, Address => Parameters.Buffer_Address;
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
            Rose.Texts.Copy (Object.Metadata, Result, Last);
            Rose.System_Calls.Initialize_Reply
              (Parameters,
               Parameters.Reply_Cap);
            Rose.System_Calls.Send_Word (Parameters, Last);
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
   end Handle_Metadata;

   -------------------
   -- Identifier_Of --
   -------------------

   function Identifier_Of
     (Object : not null access Launch_Interface'Class)
      return Rose.Objects.Capability_Identifier
   is
   begin
      for Item of Attached loop
         if Item.Object = Object_Access (Object) then
            return Item.Identifier;
         end if;
      end loop;
      return 0;
   end Identifier_Of;

   -------------------
   -- Interface_Cap --
   -------------------

   function Interface_Cap
     (Object : not null access Launch_Interface'Class)
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
      Object         : not null access Launch_Interface'Class)
   is
   begin
      Attach (Server_Context, Object);
      Rose.Server.Publish_Interface (Interface_Cap (Object));
   end Publish;

end Rose.Interfaces.Launch.Server;
