with Rose.Interfaces.File;
with Rose.Interfaces.Objects;
with Rose.Invocation;
with Rose.System_Calls;
with Rose.Texts;
with System;
with System.Storage_Elements;

package body Rose.Interfaces.Directory.Server is

   Server_Instance : Rose.Server.Server_Instance;

   type Object_Access is access all Directory_Interface'Class;

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

   subtype File_Object_Class is
     Rose.Interfaces.File.File_Object'Class;

   subtype Directory_Object_Class is
     Rose.Interfaces.Directory.Directory_Object'Class;

   function Find
     (Identifier : Rose.Objects.Capability_Identifier)
      return Object_Access;

   procedure Handle_Get_Directory_Interface
     (Parameters : in out Rose.Invocation.Invocation_Record);

   procedure Handle_Directory_Entry_Count
     (Parameters : in out Rose.Invocation.Invocation_Record);

   procedure Handle_Directory_Entry_Name
     (Parameters : in out Rose.Invocation.Invocation_Record);

   procedure Handle_Directory_Entry_Kind
     (Parameters : in out Rose.Invocation.Invocation_Record);

   procedure Handle_Directory_Entry_Size
     (Parameters : in out Rose.Invocation.Invocation_Record);

   procedure Handle_Find_Entry
     (Parameters : in out Rose.Invocation.Invocation_Record);

   procedure Handle_Get_Ordinary_File
     (Parameters : in out Rose.Invocation.Invocation_Record);

   procedure Handle_Get_Directory
     (Parameters : in out Rose.Invocation.Invocation_Record);

   ------------
   -- Attach --
   ------------

   procedure Attach
     (Server_Context : in out Rose.Server.Server_Context;
      Object         : not null access Directory_Interface'Class)
   is
   begin
      if not Registered then
         Rose.Server.Register_Handler
           (Server_Context,
            Rose.Interfaces.Directory.Directory_Interface,
            Handle_Get_Directory_Interface'Access);
         Rose.Server.Register_Handler
           (Server_Context,
            Directory_Entry_Count_Endpoint,
            Handle_Directory_Entry_Count'Access);
         Rose.Server.Register_Handler
           (Server_Context,
            Directory_Entry_Name_Endpoint,
            Handle_Directory_Entry_Name'Access);
         Rose.Server.Register_Handler
           (Server_Context,
            Directory_Entry_Kind_Endpoint,
            Handle_Directory_Entry_Kind'Access);
         Rose.Server.Register_Handler
           (Server_Context,
            Directory_Entry_Size_Endpoint,
            Handle_Directory_Entry_Size'Access);
         Rose.Server.Register_Handler
           (Server_Context,
            Find_Entry_Endpoint,
            Handle_Find_Entry'Access);
         Rose.Server.Register_Handler
           (Server_Context,
            Get_Ordinary_File_Endpoint,
            Handle_Get_Ordinary_File'Access);
         Rose.Server.Register_Handler
           (Server_Context,
            Get_Directory_Endpoint,
            Handle_Get_Directory'Access);
         Registered := True;
      end if;
      if Attached_Count = Max_Attached then
         raise Constraint_Error with "Directory.Server: too many objects";
      end if;
      Attached (Attached_Count).Object := Object_Access (Object);
      Attached (Attached_Count).Cap :=
        Rose.Server.Create_Endpoint
          (Rose.Interfaces.Directory.Directory_Interface,
           Rose.Objects.Capability_Identifier (Attached_Count));
      Attached_Count := Attached_Count + 1;
   end Attach;

   ------------
   -- Cap_Of --
   ------------

   function Cap_Of
     (Object       : Directory_Interface'Class;
      Interface_Id : Rose.Objects.Endpoint_Id :=
        Rose.Interfaces.Directory.Directory_Interface)
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
            if Interface_Id = Rose.Interfaces.Directory.Directory_Interface
            then
               return Item.Cap;
            end if;
         end if;
         Identifier := Identifier + 1;
      end loop;
      raise Rose.Interfaces.Objects.Not_Served
        with "Rose.Interfaces.Directory.Server.Cap_Of";
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

   ----------------------------------
   -- Handle_Directory_Entry_Count --
   ----------------------------------

   procedure Handle_Directory_Entry_Count
     (Parameters : in out Rose.Invocation.Invocation_Record)
   is
   begin
      declare
         Object : constant Object_Access := Find (Parameters.Identifier);
         Result : Natural;
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
         Result := Object.Directory_Entry_Count;
         Rose.System_Calls.Initialize_Reply (Parameters, Parameters.Reply_Cap);
         Rose.System_Calls.Send_Word (Parameters, Result);
      exception
         when others =>
            Rose.System_Calls.Initialize_Reply
              (Parameters,
               Parameters.Reply_Cap);
            Rose.System_Calls.Send_Error
              (Parameters,
               Rose.Invocation.Exception_Raised);
      end;
   end Handle_Directory_Entry_Count;

   ---------------------------------
   -- Handle_Directory_Entry_Kind --
   ---------------------------------

   procedure Handle_Directory_Entry_Kind
     (Parameters : in out Rose.Invocation.Invocation_Record)
   is
   begin
      declare
         Object : constant Object_Access := Find (Parameters.Identifier);
         Index  : constant Positive :=
           Positive (Rose.System_Calls.Get_Word_32 (Parameters, 0));
         Result : Rose.Interfaces.Directory.File_Kind;
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
         Result := Object.Directory_Entry_Kind (Index);
         Rose.System_Calls.Initialize_Reply (Parameters, Parameters.Reply_Cap);
         Rose.System_Calls.Send_Word
           (Parameters,
            Natural (Rose.Interfaces.Directory.File_Kind'Pos (Result)));
      exception
         when others =>
            Rose.System_Calls.Initialize_Reply
              (Parameters,
               Parameters.Reply_Cap);
            Rose.System_Calls.Send_Error
              (Parameters,
               Rose.Invocation.Exception_Raised);
      end;
   end Handle_Directory_Entry_Kind;

   ---------------------------------
   -- Handle_Directory_Entry_Name --
   ---------------------------------

   procedure Handle_Directory_Entry_Name
     (Parameters : in out Rose.Invocation.Invocation_Record)
   is
   begin
      declare
         Object : constant Object_Access := Find (Parameters.Identifier);
         Index  : constant Positive :=
           Positive (Rose.System_Calls.Get_Word_32 (Parameters, 0));
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
         Rose.Texts.Copy (Object.Directory_Entry_Name (Index), Result, Last);
         Rose.System_Calls.Initialize_Reply (Parameters, Parameters.Reply_Cap);
         Rose.System_Calls.Send_Word (Parameters, Last);
      exception
         when others =>
            Rose.System_Calls.Initialize_Reply
              (Parameters,
               Parameters.Reply_Cap);
            Rose.System_Calls.Send_Error
              (Parameters,
               Rose.Invocation.Exception_Raised);
      end;
   end Handle_Directory_Entry_Name;

   ---------------------------------
   -- Handle_Directory_Entry_Size --
   ---------------------------------

   procedure Handle_Directory_Entry_Size
     (Parameters : in out Rose.Invocation.Invocation_Record)
   is
   begin
      declare
         Object : constant Object_Access := Find (Parameters.Identifier);
         Index  : constant Positive :=
           Positive (Rose.System_Calls.Get_Word_32 (Parameters, 0));
         Result : System.Storage_Elements.Storage_Count;
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
         Result := Object.Directory_Entry_Size (Index);
         Rose.System_Calls.Initialize_Reply (Parameters, Parameters.Reply_Cap);
         Rose.System_Calls.Send_Storage_Offset (Parameters, Result);
      exception
         when others =>
            Rose.System_Calls.Initialize_Reply
              (Parameters,
               Parameters.Reply_Cap);
            Rose.System_Calls.Send_Error
              (Parameters,
               Rose.Invocation.Exception_Raised);
      end;
   end Handle_Directory_Entry_Size;

   -----------------------
   -- Handle_Find_Entry --
   -----------------------

   procedure Handle_Find_Entry
     (Parameters : in out Rose.Invocation.Invocation_Record)
   is
   begin
      declare
         Object : constant Object_Access := Find (Parameters.Identifier);
         Name   : String (1 .. Natural (Parameters.Buffer_Length))
           with Import, Address => Parameters.Buffer_Address;
         Result : Natural;
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
         Result := Object.Find_Entry (Name);
         Rose.System_Calls.Initialize_Reply (Parameters, Parameters.Reply_Cap);
         Rose.System_Calls.Send_Word (Parameters, Result);
      exception
         when others =>
            Rose.System_Calls.Initialize_Reply
              (Parameters,
               Parameters.Reply_Cap);
            Rose.System_Calls.Send_Error
              (Parameters,
               Rose.Invocation.Exception_Raised);
      end;
   end Handle_Find_Entry;

   --------------------------
   -- Handle_Get_Directory --
   --------------------------

   procedure Handle_Get_Directory
     (Parameters : in out Rose.Invocation.Invocation_Record)
   is
   begin
      declare
         Object : constant Object_Access := Find (Parameters.Identifier);
         Index  : constant Positive :=
           Positive (Rose.System_Calls.Get_Word_32 (Parameters, 0));
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
         declare
            Result : Directory_Object_Class := Object.Get_Directory (Index);
         begin
            Rose.System_Calls.Initialize_Reply
              (Parameters,
               Parameters.Reply_Cap);
            Rose.System_Calls.Send_Cap (Parameters, Result.Directory_Cap);
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
   end Handle_Get_Directory;

   ------------------------------------
   -- Handle_Get_Directory_Interface --
   ------------------------------------

   procedure Handle_Get_Directory_Interface
     (Parameters : in out Rose.Invocation.Invocation_Record)
   is
      Cap        : Rose.Capabilities.Capability;
      Identifier : constant Rose.Objects.Capability_Identifier :=
        Parameters.Identifier;
   begin
      Rose.System_Calls.Initialize_Reply (Parameters, Parameters.Reply_Cap);
      if not Rose.Server.Has_Instance
        (Server_Instance,
         Directory_Entry_Count_Endpoint,
         Identifier)
      then
         Rose.Server.Set_Instance_Cap
           (Server_Instance,
            Directory_Entry_Count_Endpoint,
            Identifier,
            Rose.Server.Create_Endpoint
              (Directory_Entry_Count_Endpoint,
               Identifier));
      end if;
      Cap :=
        Rose.Server.Get_Instance_Cap
          (Server_Instance,
           Directory_Entry_Count_Endpoint,
           Identifier);
      Rose.System_Calls.Send_Cap (Parameters, Cap);
      if not Rose.Server.Has_Instance
        (Server_Instance,
         Directory_Entry_Name_Endpoint,
         Identifier)
      then
         Rose.Server.Set_Instance_Cap
           (Server_Instance,
            Directory_Entry_Name_Endpoint,
            Identifier,
            Rose.Server.Create_Endpoint
              (Directory_Entry_Name_Endpoint,
               Identifier));
      end if;
      Cap :=
        Rose.Server.Get_Instance_Cap
          (Server_Instance,
           Directory_Entry_Name_Endpoint,
           Identifier);
      Rose.System_Calls.Send_Cap (Parameters, Cap);
      if not Rose.Server.Has_Instance
        (Server_Instance,
         Directory_Entry_Kind_Endpoint,
         Identifier)
      then
         Rose.Server.Set_Instance_Cap
           (Server_Instance,
            Directory_Entry_Kind_Endpoint,
            Identifier,
            Rose.Server.Create_Endpoint
              (Directory_Entry_Kind_Endpoint,
               Identifier));
      end if;
      Cap :=
        Rose.Server.Get_Instance_Cap
          (Server_Instance,
           Directory_Entry_Kind_Endpoint,
           Identifier);
      Rose.System_Calls.Send_Cap (Parameters, Cap);
      if not Rose.Server.Has_Instance
        (Server_Instance,
         Directory_Entry_Size_Endpoint,
         Identifier)
      then
         Rose.Server.Set_Instance_Cap
           (Server_Instance,
            Directory_Entry_Size_Endpoint,
            Identifier,
            Rose.Server.Create_Endpoint
              (Directory_Entry_Size_Endpoint,
               Identifier));
      end if;
      Cap :=
        Rose.Server.Get_Instance_Cap
          (Server_Instance,
           Directory_Entry_Size_Endpoint,
           Identifier);
      Rose.System_Calls.Send_Cap (Parameters, Cap);
      if not Rose.Server.Has_Instance
        (Server_Instance,
         Find_Entry_Endpoint,
         Identifier)
      then
         Rose.Server.Set_Instance_Cap
           (Server_Instance,
            Find_Entry_Endpoint,
            Identifier,
            Rose.Server.Create_Endpoint (Find_Entry_Endpoint, Identifier));
      end if;
      Cap :=
        Rose.Server.Get_Instance_Cap
          (Server_Instance,
           Find_Entry_Endpoint,
           Identifier);
      Rose.System_Calls.Send_Cap (Parameters, Cap);
      if not Rose.Server.Has_Instance
        (Server_Instance,
         Get_Ordinary_File_Endpoint,
         Identifier)
      then
         Rose.Server.Set_Instance_Cap
           (Server_Instance,
            Get_Ordinary_File_Endpoint,
            Identifier,
            Rose.Server.Create_Endpoint
              (Get_Ordinary_File_Endpoint,
               Identifier));
      end if;
      Cap :=
        Rose.Server.Get_Instance_Cap
          (Server_Instance,
           Get_Ordinary_File_Endpoint,
           Identifier);
      Rose.System_Calls.Send_Cap (Parameters, Cap);
      if not Rose.Server.Has_Instance
        (Server_Instance,
         Get_Directory_Endpoint,
         Identifier)
      then
         Rose.Server.Set_Instance_Cap
           (Server_Instance,
            Get_Directory_Endpoint,
            Identifier,
            Rose.Server.Create_Endpoint (Get_Directory_Endpoint, Identifier));
      end if;
      Cap :=
        Rose.Server.Get_Instance_Cap
          (Server_Instance,
           Get_Directory_Endpoint,
           Identifier);
      Rose.System_Calls.Send_Cap (Parameters, Cap);
   end Handle_Get_Directory_Interface;

   ------------------------------
   -- Handle_Get_Ordinary_File --
   ------------------------------

   procedure Handle_Get_Ordinary_File
     (Parameters : in out Rose.Invocation.Invocation_Record)
   is
   begin
      declare
         Object : constant Object_Access := Find (Parameters.Identifier);
         Index  : constant Positive :=
           Positive (Rose.System_Calls.Get_Word_32 (Parameters, 0));
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
         declare
            Result : File_Object_Class := Object.Get_Ordinary_File (Index);
         begin
            Rose.System_Calls.Initialize_Reply
              (Parameters,
               Parameters.Reply_Cap);
            Rose.System_Calls.Send_Cap (Parameters, Result.File_Cap);
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
   end Handle_Get_Ordinary_File;

   -------------------
   -- Interface_Cap --
   -------------------

   function Interface_Cap
     (Object : not null access Directory_Interface'Class)
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
      Object         : not null access Directory_Interface'Class)
   is
   begin
      Attach (Server_Context, Object);
      Rose.Server.Publish_Interface (Interface_Cap (Object));
   end Publish;

end Rose.Interfaces.Directory.Server;
