with Ada.Containers.Vectors;
with Interfaces;
with Rose.Interfaces.Objects;
with Rose.Invocation;
with Rose.System_Calls;
with Rose.Words;
with System;

package body Rose.Interfaces.Signed.Server is

   Server_Instance : Rose.Server.Server_Instance;

   type Object_Access is access all Signed_Interface'Class;

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

   ------------
   -- Attach --
   ------------

   procedure Attach
     (Server_Context : in out Rose.Server.Server_Context;
      Object         : not null access Signed_Interface'Class;
      Identifier     : Rose.Objects.Capability_Identifier := 0)
   is
      use type Rose.Objects.Capability_Identifier;
   begin
      if not Registered then
         Rose.Server.Register_Handler
           (Server_Context,
            Rose.Interfaces.Signed.Signed_Interface,
            Handle_Get_Signed_Interface'Access,
            Owns'Access);
         Rose.Server.Register_Handler
           (Server_Context,
            Clamp_Endpoint,
            Handle_Clamp'Access,
            Owns'Access);
         Rose.Server.Register_Handler
           (Server_Context,
            Position_Endpoint,
            Handle_Position'Access,
            Owns'Access);
         Rose.Server.Register_Handler
           (Server_Context,
            Offset_Endpoint,
            Handle_Offset'Access,
            Owns'Access);
         Rose.Server.Register_Handler
           (Server_Context,
            Difference_Endpoint,
            Handle_Difference'Access,
            Owns'Access);
         Rose.Server.Register_Handler
           (Server_Context,
            Bounds_Endpoint,
            Handle_Bounds'Access,
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
          (Rose.Interfaces.Signed.Signed_Interface,
           Attached (Attached.Last_Index).Identifier);
   end Attach;

   ------------
   -- Cap_Of --
   ------------

   function Cap_Of
     (Object       : Signed_Interface'Class;
      Interface_Id : Rose.Objects.Endpoint_Id :=
        Rose.Interfaces.Signed.Signed_Interface)
      return Rose.Capabilities.Capability
   is
      use type System.Address;
      use type Rose.Objects.Endpoint_Id;
   begin
      for Item of Attached loop
         if Item.Object /= null
           and then Item.Object.all'Address = Object'Address
         then
            if Interface_Id = Rose.Interfaces.Signed.Signed_Interface then
               return Item.Cap;
            end if;
         end if;
      end loop;
      raise Rose.Interfaces.Objects.Not_Served
        with "Rose.Interfaces.Signed.Server.Cap_Of";
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

   -------------------
   -- Handle_Bounds --
   -------------------

   procedure Handle_Bounds
     (Parameters : in out Rose.Invocation.Invocation_Record)
   is
   begin
      begin
         declare
            Object : constant Object_Access := Find (Parameters.Identifier);
            Low    : Standard.Interfaces.Integer_64;
            High   : Standard.Interfaces.Integer_64;
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
            Object.Bounds (Low, High);
            Rose.System_Calls.Initialize_Reply
              (Parameters,
               Parameters.Reply_Cap);
            Rose.System_Calls.Send_Integer_64 (Parameters, Low);
            Rose.System_Calls.Send_Integer_64 (Parameters, High);
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
   end Handle_Bounds;

   ------------------
   -- Handle_Clamp --
   ------------------

   procedure Handle_Clamp
     (Parameters : in out Rose.Invocation.Invocation_Record)
   is
   begin
      begin
         declare
            Object : constant Object_Access := Find (Parameters.Identifier);
            Value  : constant Standard.Interfaces.Integer_32 :=
              Rose.System_Calls.Get_Integer_32 (Parameters, 0);
            Low    : constant Standard.Interfaces.Integer_32 :=
              Rose.System_Calls.Get_Integer_32 (Parameters, 1);
            Result : Standard.Interfaces.Integer_32;
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
            Result := Object.Clamp (Value, Low);
            Rose.System_Calls.Initialize_Reply
              (Parameters,
               Parameters.Reply_Cap);
            Rose.System_Calls.Send_Integer_32 (Parameters, Result);
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
   end Handle_Clamp;

   -----------------------
   -- Handle_Difference --
   -----------------------

   procedure Handle_Difference
     (Parameters : in out Rose.Invocation.Invocation_Record)
   is
   begin
      begin
         declare
            Object : constant Object_Access := Find (Parameters.Identifier);
            Left   : constant Standard.Interfaces.Integer_64 :=
              Rose.System_Calls.Get_Integer_64 (Parameters, 0);
            Right  : constant Standard.Interfaces.Integer_64 :=
              Rose.System_Calls.Get_Integer_64 (Parameters, 2);
            Result : Standard.Interfaces.Integer_64;
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
            Result := Object.Difference (Left, Right);
            Rose.System_Calls.Initialize_Reply
              (Parameters,
               Parameters.Reply_Cap);
            Rose.System_Calls.Send_Integer_64 (Parameters, Result);
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
   end Handle_Difference;

   ---------------------------------
   -- Handle_Get_Signed_Interface --
   ---------------------------------

   procedure Handle_Get_Signed_Interface
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
      if First >= 5 then
         Rose.System_Calls.Send_Error
           (Parameters,
            Rose.Invocation.Invalid_Operation);
      else
         if 0 in First .. (First + Page - 1) then
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
            Rose.System_Calls.Send_Cap (Parameters, Cap);
         end if;
         if 1 in First .. (First + Page - 1) then
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
            Rose.System_Calls.Send_Cap (Parameters, Cap);
         end if;
         if 2 in First .. (First + Page - 1) then
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
            Rose.System_Calls.Send_Cap (Parameters, Cap);
         end if;
         if 3 in First .. (First + Page - 1) then
            if not Rose.Server.Has_Instance
              (Server_Instance,
               Difference_Endpoint,
               Identifier)
            then
               Rose.Server.Set_Instance_Cap
                 (Server_Instance,
                  Difference_Endpoint,
                  Identifier,
                  Rose.Server.Create_Endpoint
                    (Difference_Endpoint,
                     Identifier));
            end if;
            Cap :=
              Rose.Server.Get_Instance_Cap
                (Server_Instance,
                 Difference_Endpoint,
                 Identifier);
            Rose.System_Calls.Send_Cap (Parameters, Cap);
         end if;
         if 4 in First .. (First + Page - 1) then
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
            Rose.System_Calls.Send_Cap (Parameters, Cap);
         end if;
      end if;
   end Handle_Get_Signed_Interface;

   -------------------
   -- Handle_Offset --
   -------------------

   procedure Handle_Offset
     (Parameters : in out Rose.Invocation.Invocation_Record)
   is
   begin
      begin
         declare
            Object  : constant Object_Access := Find (Parameters.Identifier);
            Delta_X : Standard.Interfaces.Integer_32 :=
              Rose.System_Calls.Get_Integer_32 (Parameters, 0);
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
            Object.Offset (Delta_X);
            Rose.System_Calls.Initialize_Reply
              (Parameters,
               Parameters.Reply_Cap);
            Rose.System_Calls.Send_Integer_32 (Parameters, Delta_X);
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
   end Handle_Offset;

   ---------------------
   -- Handle_Position --
   ---------------------

   procedure Handle_Position
     (Parameters : in out Rose.Invocation.Invocation_Record)
   is
   begin
      begin
         declare
            Object : constant Object_Access := Find (Parameters.Identifier);
            Index  : constant Rose.Words.Word :=
              Rose.System_Calls.Get_Word_32 (Parameters, 0);
            X      : Standard.Interfaces.Integer_32;
            Y      : Standard.Interfaces.Integer_32;
            Count  : Natural;
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
            Object.Position (Index, X, Y, Count);
            Rose.System_Calls.Initialize_Reply
              (Parameters,
               Parameters.Reply_Cap);
            Rose.System_Calls.Send_Integer_32 (Parameters, X);
            Rose.System_Calls.Send_Integer_32 (Parameters, Y);
            Rose.System_Calls.Send_Word (Parameters, Count);
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
   end Handle_Position;

   -------------------
   -- Identifier_Of --
   -------------------

   function Identifier_Of
     (Object : not null access Signed_Interface'Class)
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
     (Object : not null access Signed_Interface'Class)
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
      Object         : not null access Signed_Interface'Class)
   is
   begin
      Attach (Server_Context, Object);
      Rose.Server.Publish_Interface (Interface_Cap (Object));
   end Publish;

end Rose.Interfaces.Signed.Server;
