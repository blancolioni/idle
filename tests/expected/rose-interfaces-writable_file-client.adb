with Rose.System_Calls;

package body Rose.Interfaces.Writable_File.Client is

   use type Rose.Invocation.Invocation_Error;

   Last_Error : Rose.Invocation.Invocation_Error := Rose.Invocation.OK;

   -----------
   -- Close --
   -----------

   procedure Close (Client : in out Writable_File_Client) is
   begin
      Client.Is_Open := False;
      Rose.System_Calls.Delete_Cap (Client.Size);
      Rose.System_Calls.Delete_Cap (Client.Open_Reader);
      Rose.System_Calls.Delete_Cap (Client.Open_Seekable_Reader);
      Rose.System_Calls.Delete_Cap (Client.Write);
      Rose.System_Calls.Delete_Cap (Client.Truncate);
      Rose.System_Calls.Delete_Cap (Client.New_Version);
      Rose.System_Calls.Delete_Cap (Client.Interface_Cap);
   end Close;

   -----------------------
   -- Get_Interface_Cap --
   -----------------------

   function Get_Interface_Cap
     (Item : Writable_File_Client)
      return Rose.Capabilities.Capability
   is (Item.Interface_Cap);

   --------------------
   -- Get_Last_Error --
   --------------------

   function Get_Last_Error
      return Rose.Invocation.Invocation_Error
   is (Last_Error);

   -------------------------
   -- Get_New_Version_Cap --
   -------------------------

   function Get_New_Version_Cap
     (Item : Writable_File_Client)
      return Rose.Capabilities.Capability
   is (Item.New_Version);

   -------------------------
   -- Get_Open_Reader_Cap --
   -------------------------

   function Get_Open_Reader_Cap
     (Item : Writable_File_Client)
      return Rose.Capabilities.Capability
   is (Item.Open_Reader);

   ----------------------------------
   -- Get_Open_Seekable_Reader_Cap --
   ----------------------------------

   function Get_Open_Seekable_Reader_Cap
     (Item : Writable_File_Client)
      return Rose.Capabilities.Capability
   is (Item.Open_Seekable_Reader);

   ------------------
   -- Get_Size_Cap --
   ------------------

   function Get_Size_Cap
     (Item : Writable_File_Client)
      return Rose.Capabilities.Capability
   is (Item.Size);

   ----------------------
   -- Get_Truncate_Cap --
   ----------------------

   function Get_Truncate_Cap
     (Item : Writable_File_Client)
      return Rose.Capabilities.Capability
   is (Item.Truncate);

   -------------------
   -- Get_Write_Cap --
   -------------------

   function Get_Write_Cap
     (Item : Writable_File_Client)
      return Rose.Capabilities.Capability
   is (Item.Write);

   ---------------
   -- Has_Error --
   ---------------

   function Has_Error return Boolean is (Last_Error /= Rose.Invocation.OK);

   -----------------
   -- New_Version --
   -----------------

   function New_Version
     (Item : Writable_File_Client)
      return
        Rose.Interfaces.Transactional_Writable_File.Client
          .Transactional_Writable_File_Client
   is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      Rose.System_Calls.Initialize_Send (Params, Item.New_Version);
      Rose.System_Calls.Receive_Caps (Params, 1);
      Rose.System_Calls.Invoke_Capability (Params);
      Last_Error := Rose.Invocation.OK;
      if Params.Control.Flags (Rose.Invocation.Error) then
         Last_Error := Params.Error;
      end if;
      declare
         Result : Rose.Interfaces.Transactional_Writable_File.Client
           .Transactional_Writable_File_Client;
      begin
         Rose.Interfaces.Transactional_Writable_File.Client.Open
           (Result,
            Params.Caps (0));
         return Result;
      end;
   end New_Version;

   ----------
   -- Open --
   ----------

   procedure Open
     (Client        : out Writable_File_Client;
      Interface_Cap : Rose.Capabilities.Capability)
   is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      Client.Is_Open := False;
      Client.Interface_Cap := Interface_Cap;
      Rose.System_Calls.Initialize_Send (Params, Interface_Cap);
      Rose.System_Calls.Receive_Caps (Params, Subprogram_Count);
      Rose.System_Calls.Invoke_Capability (Params);
      Client.Size := Params.Caps (Size_Index);
      Client.Open_Reader := Params.Caps (Open_Reader_Index);
      Client.Open_Seekable_Reader := Params.Caps (Open_Seekable_Reader_Index);
      Client.Write := Params.Caps (Write_Index);
      Client.Truncate := Params.Caps (Truncate_Index);
      Client.New_Version := Params.Caps (New_Version_Index);
      Client.Is_Open := True;
   end Open;

   ------------------
   -- Open_Cap_Set --
   ------------------

   procedure Open_Cap_Set
     (Client               : out Writable_File_Client;
      Size                 : Rose.Capabilities.Capability;
      Open_Reader          : Rose.Capabilities.Capability;
      Open_Seekable_Reader : Rose.Capabilities.Capability;
      Write                : Rose.Capabilities.Capability;
      Truncate             : Rose.Capabilities.Capability;
      New_Version          : Rose.Capabilities.Capability)
   is
   begin
      Client.Size := Size;
      Client.Open_Reader := Open_Reader;
      Client.Open_Seekable_Reader := Open_Seekable_Reader;
      Client.Write := Write;
      Client.Truncate := Truncate;
      Client.New_Version := New_Version;
      Client.Is_Open := True;
   end Open_Cap_Set;

   -----------------
   -- Open_Reader --
   -----------------

   function Open_Reader
     (Item : Writable_File_Client)
      return Rose.Interfaces.File_Reader.Client.File_Reader_Client
   is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      Rose.System_Calls.Initialize_Send (Params, Item.Open_Reader);
      Rose.System_Calls.Receive_Caps (Params, 1);
      Rose.System_Calls.Invoke_Capability (Params);
      Last_Error := Rose.Invocation.OK;
      if Params.Control.Flags (Rose.Invocation.Error) then
         Last_Error := Params.Error;
      end if;
      declare
         Result : Rose.Interfaces.File_Reader.Client.File_Reader_Client;
      begin
         Rose.Interfaces.File_Reader.Client.Open (Result, Params.Caps (0));
         return Result;
      end;
   end Open_Reader;

   --------------------------
   -- Open_Seekable_Reader --
   --------------------------

   function Open_Seekable_Reader
     (Item : Writable_File_Client)
      return
        Rose.Interfaces.Seekable_File_Reader.Client.Seekable_File_Reader_Client
   is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      Rose.System_Calls.Initialize_Send (Params, Item.Open_Seekable_Reader);
      Rose.System_Calls.Receive_Caps (Params, 1);
      Rose.System_Calls.Invoke_Capability (Params);
      Last_Error := Rose.Invocation.OK;
      if Params.Control.Flags (Rose.Invocation.Error) then
         Last_Error := Params.Error;
      end if;
      declare
         Result : Rose.Interfaces.Seekable_File_Reader.Client
           .Seekable_File_Reader_Client;
      begin
         Rose.Interfaces.Seekable_File_Reader.Client.Open
           (Result,
            Params.Caps (0));
         return Result;
      end;
   end Open_Seekable_Reader;

   ----------
   -- Size --
   ----------

   function Size
     (Item : Writable_File_Client)
      return System.Storage_Elements.Storage_Count
   is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      Rose.System_Calls.Initialize_Send (Params, Item.Size);
      Rose.System_Calls.Receive_Words (Params, 1);
      Rose.System_Calls.Invoke_Capability (Params);
      Last_Error := Rose.Invocation.OK;
      if Params.Control.Flags (Rose.Invocation.Error) then
         Last_Error := Params.Error;
      end if;
      return System.Storage_Elements.Storage_Count
        (Rose.System_Calls.Get_Word_32 (Params, 0));
   end Size;

   --------------
   -- Truncate --
   --------------

   procedure Truncate
     (Item : Writable_File_Client;
      Size : System.Storage_Elements.Storage_Count)
   is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      Rose.System_Calls.Initialize_Send (Params, Item.Truncate);
      Rose.System_Calls.Send_Storage_Offset (Params, Size);
      Rose.System_Calls.Invoke_Capability (Params);
      Last_Error := Rose.Invocation.OK;
      if Params.Control.Flags (Rose.Invocation.Error) then
         Last_Error := Params.Error;
      end if;
   end Truncate;

   -----------
   -- Write --
   -----------

   procedure Write
     (Item   : Writable_File_Client;
      Buffer : System.Storage_Elements.Storage_Array)
   is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      Rose.System_Calls.Initialize_Send (Params, Item.Write);
      Rose.System_Calls.Send_Storage_Array (Params, Buffer, False);
      Rose.System_Calls.Invoke_Capability (Params);
      Last_Error := Rose.Invocation.OK;
      if Params.Control.Flags (Rose.Invocation.Error) then
         Last_Error := Params.Error;
      end if;
   end Write;

end Rose.Interfaces.Writable_File.Client;
