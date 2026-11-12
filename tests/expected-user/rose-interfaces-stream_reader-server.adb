with Ada.Containers.Vectors;
with Rose.Interfaces.Objects;
with Rose.Invocation;
with Rose.System_Calls;
with System;
with System.Storage_Elements;

package body Rose.Interfaces.Stream_Reader.Server is

   Server_Instance : Rose.Server.Server_Instance;

   type Object_Access is access all Stream_Reader_Interface'Class;

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

   function Find
     (Identifier : Rose.Objects.Capability_Identifier)
      return Object_Access;

   function Owns
     (Identifier : Rose.Objects.Capability_Identifier)
      return Boolean;

   procedure Handle_Get_Stream_Reader_Interface
     (Parameters : in out Rose.Invocation.Invocation_Record);

   procedure Handle_Read
     (Parameters : in out Rose.Invocation.Invocation_Record);

   ------------
   -- Attach --
   ------------

   procedure Attach
     (Server_Context : in out Rose.Server.Server_Context;
      Object         : not null access Stream_Reader_Interface'Class;
      Identifier     : Rose.Objects.Capability_Identifier := 0)
   is
      use type Rose.Objects.Capability_Identifier;
   begin
      if not Registered then
         Rose.Server.Register_Handler
           (Server_Context,
            Rose.Interfaces.Stream_Reader.Stream_Reader_Interface,
            Handle_Get_Stream_Reader_Interface'Access,
            Owns'Access);
         Rose.Server.Register_Handler
           (Server_Context,
            Read_Endpoint,
            Handle_Read'Access,
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
          (Rose.Interfaces.Stream_Reader.Stream_Reader_Interface,
           Attached (Attached.Last_Index).Identifier);
   end Attach;

   ------------
   -- Cap_Of --
   ------------

   function Cap_Of
     (Object       : Stream_Reader_Interface'Class;
      Interface_Id : Rose.Objects.Endpoint_Id :=
        Rose.Interfaces.Stream_Reader.Stream_Reader_Interface)
      return Rose.Capabilities.Capability
   is
      use type System.Address;
      use type Rose.Objects.Endpoint_Id;
   begin
      for Item of Attached loop
         if Item.Object /= null
           and then Item.Object.all'Address = Object'Address
         then
            if Interface_Id = Rose.Interfaces.Stream_Reader
              .Stream_Reader_Interface
            then
               return Item.Cap;
            end if;
         end if;
      end loop;
      raise Rose.Interfaces.Objects.Not_Served
        with "Rose.Interfaces.Stream_Reader.Server.Cap_Of";
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

   ----------------------------------------
   -- Handle_Get_Stream_Reader_Interface --
   ----------------------------------------

   procedure Handle_Get_Stream_Reader_Interface
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
      if First >= 1 then
         Rose.System_Calls.Send_Error
           (Parameters,
            Rose.Invocation.Invalid_Operation);
      else
         if 0 in First .. (First + Page - 1) then
            if not Rose.Server.Has_Instance
              (Server_Instance,
               Read_Endpoint,
               Identifier)
            then
               Rose.Server.Set_Instance_Cap
                 (Server_Instance,
                  Read_Endpoint,
                  Identifier,
                  Rose.Server.Create_Endpoint (Read_Endpoint, Identifier));
            end if;
            Cap :=
              Rose.Server.Get_Instance_Cap
                (Server_Instance,
                 Read_Endpoint,
                 Identifier);
            Rose.System_Calls.Send_Cap (Parameters, Cap);
         end if;
      end if;
   end Handle_Get_Stream_Reader_Interface;

   -----------------
   -- Handle_Read --
   -----------------

   procedure Handle_Read
     (Parameters : in out Rose.Invocation.Invocation_Record)
   is
   begin
      begin
         declare
            Object : constant Object_Access := Find (Parameters.Identifier);
            Buffer : System.Storage_Elements.Storage_Array
              (1 .. Parameters.Buffer_Length)
              with Import, Address => Parameters.Buffer_Address;
            Last   : System.Storage_Elements.Storage_Count;
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
            Object.Read (Buffer, Last);
            Rose.System_Calls.Initialize_Reply
              (Parameters,
               Parameters.Reply_Cap);
            Rose.System_Calls.Send_Storage_Offset (Parameters, Last);
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
   end Handle_Read;

   -------------------
   -- Identifier_Of --
   -------------------

   function Identifier_Of
     (Object : not null access Stream_Reader_Interface'Class)
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
     (Object : not null access Stream_Reader_Interface'Class)
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
      Object         : not null access Stream_Reader_Interface'Class)
   is
   begin
      Attach (Server_Context, Object);
      Rose.Server.Publish_Interface (Interface_Cap (Object));
   end Publish;

end Rose.Interfaces.Stream_Reader.Server;
