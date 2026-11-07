with Rose.Interfaces.File_Reader.Client;
with Rose.Interfaces.Objects;
with Rose.Interfaces.Seekable_File_Reader.Client;
with Rose.Invocation;
with Rose.System_Calls;
with System.Storage_Elements;

package body Rose.Interfaces.Transactional_Writable_File.Client is

   procedure Load (Item : in out Transactional_Writable_File_Client);

   -----------
   -- Close --
   -----------

   procedure Close (Client : in out Transactional_Writable_File_Client) is
      use type Rose.Capabilities.Capability;
   begin
      if Client.Is_Open
        or else Client.Interface_Cap /= Rose.Capabilities.Null_Capability
      then
         Release (Client);
      end if;
      if Client.Is_Open then
         Rose.System_Calls.Delete_Cap (Client.Size);
         Rose.System_Calls.Delete_Cap (Client.Open_Reader);
         Rose.System_Calls.Delete_Cap (Client.Open_Seekable_Reader);
         Rose.System_Calls.Delete_Cap (Client.Write);
         Rose.System_Calls.Delete_Cap (Client.Truncate);
         Rose.System_Calls.Delete_Cap (Client.New_Version);
         Rose.System_Calls.Delete_Cap (Client.Commit);
         Rose.System_Calls.Delete_Cap (Client.Rollback);
         Rose.System_Calls.Delete_Cap (Client.Release);
      end if;
      Client.Is_Open := False;
      if Client.File_Interface_Cap /= Rose.Capabilities.Null_Capability then
         Rose.System_Calls.Delete_Cap (Client.File_Interface_Cap);
         Client.File_Interface_Cap := Rose.Capabilities.Null_Capability;
      end if;
      if Client.Stream_Writer_Interface_Cap /= Rose.Capabilities
        .Null_Capability
      then
         Rose.System_Calls.Delete_Cap (Client.Stream_Writer_Interface_Cap);
         Client.Stream_Writer_Interface_Cap :=
           Rose.Capabilities.Null_Capability;
      end if;
      if Client.Writable_File_Interface_Cap /= Rose.Capabilities
        .Null_Capability
      then
         Rose.System_Calls.Delete_Cap (Client.Writable_File_Interface_Cap);
         Client.Writable_File_Interface_Cap :=
           Rose.Capabilities.Null_Capability;
      end if;
      if Client.Transactional_Interface_Cap /= Rose.Capabilities
        .Null_Capability
      then
         Rose.System_Calls.Delete_Cap (Client.Transactional_Interface_Cap);
         Client.Transactional_Interface_Cap :=
           Rose.Capabilities.Null_Capability;
      end if;
      if Client.Resource_Interface_Cap /= Rose.Capabilities.Null_Capability
      then
         Rose.System_Calls.Delete_Cap (Client.Resource_Interface_Cap);
         Client.Resource_Interface_Cap := Rose.Capabilities.Null_Capability;
      end if;
      Rose.System_Calls.Delete_Cap (Client.Interface_Cap);
   end Close;

   ------------
   -- Commit --
   ------------

   overriding procedure Commit
     (Item : in out Transactional_Writable_File_Client)
   is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      if not Item.Is_Open then
         Load (Item);
      end if;
      Rose.System_Calls.Initialize_Send (Params, Item.Commit);
      Rose.System_Calls.Invoke_Capability (Params);
      if Params.Control.Flags (Rose.Invocation.Error) then
         raise Rose.Interfaces.Objects.Invocation_Error
           with "Transactional_Writable_File.Commit";
      end if;
   end Commit;

   --------------
   -- File_Cap --
   --------------

   overriding function File_Cap
     (Item : in out Transactional_Writable_File_Client)
      return Rose.Capabilities.Capability
   is
      use type Rose.Capabilities.Capability;
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      if Item.File_Interface_Cap = Rose.Capabilities.Null_Capability
        and then Item.Interface_Cap /= Rose.Capabilities.Null_Capability
      then
         Rose.System_Calls.Initialize_Send (Params, Item.Interface_Cap);
         Rose.System_Calls.Send_Word (Params, Natural (1));
         Rose.System_Calls.Receive_Caps (Params, 1);
         Rose.System_Calls.Invoke_Capability (Params);
         if Params.Control.Flags (Rose.Invocation.Error) then
            raise Rose.Interfaces.Objects.Invocation_Error
              with "Transactional_Writable_File.File_Cap";
         end if;
         Item.File_Interface_Cap := Params.Caps (0);
      end if;
      return Item.File_Interface_Cap;
   end File_Cap;

   --------------
   -- From_Cap --
   --------------

   function From_Cap
     (Cap : Rose.Capabilities.Capability)
      return Transactional_Writable_File_Client
   is (Transactional_Writable_File_Client'
         (Interface_Cap => Cap, others => <>));

   --------------------
   -- Get_Commit_Cap --
   --------------------

   function Get_Commit_Cap
     (Item : in out Transactional_Writable_File_Client)
      return Rose.Capabilities.Capability
   is
   begin
      if not Item.Is_Open then
         Load (Item);
      end if;
      return Item.Commit;
   end Get_Commit_Cap;

   -----------------------
   -- Get_Interface_Cap --
   -----------------------

   function Get_Interface_Cap
     (Item : Transactional_Writable_File_Client)
      return Rose.Capabilities.Capability
   is (Item.Interface_Cap);

   -------------------------
   -- Get_New_Version_Cap --
   -------------------------

   function Get_New_Version_Cap
     (Item : in out Transactional_Writable_File_Client)
      return Rose.Capabilities.Capability
   is
   begin
      if not Item.Is_Open then
         Load (Item);
      end if;
      return Item.New_Version;
   end Get_New_Version_Cap;

   -------------------------
   -- Get_Open_Reader_Cap --
   -------------------------

   function Get_Open_Reader_Cap
     (Item : in out Transactional_Writable_File_Client)
      return Rose.Capabilities.Capability
   is
   begin
      if not Item.Is_Open then
         Load (Item);
      end if;
      return Item.Open_Reader;
   end Get_Open_Reader_Cap;

   ----------------------------------
   -- Get_Open_Seekable_Reader_Cap --
   ----------------------------------

   function Get_Open_Seekable_Reader_Cap
     (Item : in out Transactional_Writable_File_Client)
      return Rose.Capabilities.Capability
   is
   begin
      if not Item.Is_Open then
         Load (Item);
      end if;
      return Item.Open_Seekable_Reader;
   end Get_Open_Seekable_Reader_Cap;

   ---------------------
   -- Get_Release_Cap --
   ---------------------

   function Get_Release_Cap
     (Item : in out Transactional_Writable_File_Client)
      return Rose.Capabilities.Capability
   is
   begin
      if not Item.Is_Open then
         Load (Item);
      end if;
      return Item.Release;
   end Get_Release_Cap;

   ----------------------
   -- Get_Rollback_Cap --
   ----------------------

   function Get_Rollback_Cap
     (Item : in out Transactional_Writable_File_Client)
      return Rose.Capabilities.Capability
   is
   begin
      if not Item.Is_Open then
         Load (Item);
      end if;
      return Item.Rollback;
   end Get_Rollback_Cap;

   ------------------
   -- Get_Size_Cap --
   ------------------

   function Get_Size_Cap
     (Item : in out Transactional_Writable_File_Client)
      return Rose.Capabilities.Capability
   is
   begin
      if not Item.Is_Open then
         Load (Item);
      end if;
      return Item.Size;
   end Get_Size_Cap;

   ----------------------
   -- Get_Truncate_Cap --
   ----------------------

   function Get_Truncate_Cap
     (Item : in out Transactional_Writable_File_Client)
      return Rose.Capabilities.Capability
   is
   begin
      if not Item.Is_Open then
         Load (Item);
      end if;
      return Item.Truncate;
   end Get_Truncate_Cap;

   -------------------
   -- Get_Write_Cap --
   -------------------

   function Get_Write_Cap
     (Item : in out Transactional_Writable_File_Client)
      return Rose.Capabilities.Capability
   is
   begin
      if not Item.Is_Open then
         Load (Item);
      end if;
      return Item.Write;
   end Get_Write_Cap;

   ----------
   -- Load --
   ----------

   procedure Load (Item : in out Transactional_Writable_File_Client) is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      Rose.System_Calls.Initialize_Send (Params, Item.Interface_Cap);
      Rose.System_Calls.Receive_Caps (Params, Subprogram_Count);
      Rose.System_Calls.Invoke_Capability (Params);
      if Params.Control.Flags (Rose.Invocation.Error) then
         raise Rose.Interfaces.Objects.Invocation_Error
           with "Transactional_Writable_File.Open";
      end if;
      Item.Size := Params.Caps (Size_Index);
      Item.Open_Reader := Params.Caps (Open_Reader_Index);
      Item.Open_Seekable_Reader := Params.Caps (Open_Seekable_Reader_Index);
      Item.Write := Params.Caps (Write_Index);
      Item.Truncate := Params.Caps (Truncate_Index);
      Item.New_Version := Params.Caps (New_Version_Index);
      Item.Commit := Params.Caps (Commit_Index);
      Item.Rollback := Params.Caps (Rollback_Index);
      Item.Release := Params.Caps (Release_Index);
      Item.Is_Open := True;
   end Load;

   -----------------
   -- New_Version --
   -----------------

   overriding function New_Version
     (Item : in out Transactional_Writable_File_Client)
      return
        Rose.Interfaces.Transactional_Writable_File
          .Transactional_Writable_File_Object'Class
   is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      if not Item.Is_Open then
         Load (Item);
      end if;
      Rose.System_Calls.Initialize_Send (Params, Item.New_Version);
      Rose.System_Calls.Receive_Caps (Params, 1);
      Rose.System_Calls.Invoke_Capability (Params);
      if Params.Control.Flags (Rose.Invocation.Error) then
         raise Rose.Interfaces.Objects.Invocation_Error
           with "Transactional_Writable_File.New_Version";
      end if;
      return From_Cap (Params.Caps (0));
   end New_Version;

   ----------
   -- Open --
   ----------

   procedure Open
     (Client        : out Transactional_Writable_File_Client;
      Interface_Cap : Rose.Capabilities.Capability)
   is
   begin
      Client.Is_Open := False;
      Client.Interface_Cap := Interface_Cap;
      Client.File_Interface_Cap := Rose.Capabilities.Null_Capability;
      Client.Stream_Writer_Interface_Cap := Rose.Capabilities.Null_Capability;
      Client.Writable_File_Interface_Cap := Rose.Capabilities.Null_Capability;
      Client.Transactional_Interface_Cap := Rose.Capabilities.Null_Capability;
      Client.Resource_Interface_Cap := Rose.Capabilities.Null_Capability;
   end Open;

   ------------------
   -- Open_Cap_Set --
   ------------------

   procedure Open_Cap_Set
     (Client               : out Transactional_Writable_File_Client;
      Size                 : Rose.Capabilities.Capability;
      Open_Reader          : Rose.Capabilities.Capability;
      Open_Seekable_Reader : Rose.Capabilities.Capability;
      Write                : Rose.Capabilities.Capability;
      Truncate             : Rose.Capabilities.Capability;
      New_Version          : Rose.Capabilities.Capability;
      Commit               : Rose.Capabilities.Capability;
      Rollback             : Rose.Capabilities.Capability;
      Release              : Rose.Capabilities.Capability)
   is
   begin
      Client.Size := Size;
      Client.Open_Reader := Open_Reader;
      Client.Open_Seekable_Reader := Open_Seekable_Reader;
      Client.Write := Write;
      Client.Truncate := Truncate;
      Client.New_Version := New_Version;
      Client.Commit := Commit;
      Client.Rollback := Rollback;
      Client.Release := Release;
      Client.Is_Open := True;
   end Open_Cap_Set;

   -----------------
   -- Open_Reader --
   -----------------

   overriding function Open_Reader
     (Item : in out Transactional_Writable_File_Client)
      return Rose.Interfaces.File_Reader.File_Reader_Object'Class
   is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      if not Item.Is_Open then
         Load (Item);
      end if;
      Rose.System_Calls.Initialize_Send (Params, Item.Open_Reader);
      Rose.System_Calls.Receive_Caps (Params, 1);
      Rose.System_Calls.Invoke_Capability (Params);
      if Params.Control.Flags (Rose.Invocation.Error) then
         raise Rose.Interfaces.Objects.Invocation_Error
           with "Transactional_Writable_File.Open_Reader";
      end if;
      return Rose.Interfaces.File_Reader.Client.From_Cap (Params.Caps (0));
   end Open_Reader;

   --------------------------
   -- Open_Seekable_Reader --
   --------------------------

   overriding function Open_Seekable_Reader
     (Item : in out Transactional_Writable_File_Client)
      return
        Rose.Interfaces.Seekable_File_Reader.Seekable_File_Reader_Object'Class
   is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      if not Item.Is_Open then
         Load (Item);
      end if;
      Rose.System_Calls.Initialize_Send (Params, Item.Open_Seekable_Reader);
      Rose.System_Calls.Receive_Caps (Params, 1);
      Rose.System_Calls.Invoke_Capability (Params);
      if Params.Control.Flags (Rose.Invocation.Error) then
         raise Rose.Interfaces.Objects.Invocation_Error
           with "Transactional_Writable_File.Open_Seekable_Reader";
      end if;
      return Rose.Interfaces.Seekable_File_Reader.Client.From_Cap
        (Params.Caps (0));
   end Open_Seekable_Reader;

   -------------
   -- Release --
   -------------

   overriding procedure Release
     (Item : in out Transactional_Writable_File_Client)
   is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      if not Item.Is_Open then
         Load (Item);
      end if;
      Rose.System_Calls.Initialize_Send (Params, Item.Release);
      Rose.System_Calls.Invoke_Capability (Params);
      if Params.Control.Flags (Rose.Invocation.Error) then
         raise Rose.Interfaces.Objects.Invocation_Error
           with "Transactional_Writable_File.Release";
      end if;
   end Release;

   ------------------
   -- Resource_Cap --
   ------------------

   overriding function Resource_Cap
     (Item : in out Transactional_Writable_File_Client)
      return Rose.Capabilities.Capability
   is
      use type Rose.Capabilities.Capability;
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      if Item.Resource_Interface_Cap = Rose.Capabilities.Null_Capability
        and then Item.Interface_Cap /= Rose.Capabilities.Null_Capability
      then
         Rose.System_Calls.Initialize_Send (Params, Item.Interface_Cap);
         Rose.System_Calls.Send_Word (Params, Natural (5));
         Rose.System_Calls.Receive_Caps (Params, 1);
         Rose.System_Calls.Invoke_Capability (Params);
         if Params.Control.Flags (Rose.Invocation.Error) then
            raise Rose.Interfaces.Objects.Invocation_Error
              with "Transactional_Writable_File.Resource_Cap";
         end if;
         Item.Resource_Interface_Cap := Params.Caps (0);
      end if;
      return Item.Resource_Interface_Cap;
   end Resource_Cap;

   --------------
   -- Rollback --
   --------------

   overriding procedure Rollback
     (Item : in out Transactional_Writable_File_Client)
   is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      if not Item.Is_Open then
         Load (Item);
      end if;
      Rose.System_Calls.Initialize_Send (Params, Item.Rollback);
      Rose.System_Calls.Invoke_Capability (Params);
      if Params.Control.Flags (Rose.Invocation.Error) then
         raise Rose.Interfaces.Objects.Invocation_Error
           with "Transactional_Writable_File.Rollback";
      end if;
   end Rollback;

   ----------
   -- Size --
   ----------

   overriding function Size
     (Item : in out Transactional_Writable_File_Client)
      return System.Storage_Elements.Storage_Count
   is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      if not Item.Is_Open then
         Load (Item);
      end if;
      Rose.System_Calls.Initialize_Send (Params, Item.Size);
      Rose.System_Calls.Receive_Words (Params, 1);
      Rose.System_Calls.Invoke_Capability (Params);
      if Params.Control.Flags (Rose.Invocation.Error) then
         raise Rose.Interfaces.Objects.Invocation_Error
           with "Transactional_Writable_File.Size";
      end if;
      return System.Storage_Elements.Storage_Count
        (Rose.System_Calls.Get_Word_32 (Params, 0));
   end Size;

   -----------------------
   -- Stream_Writer_Cap --
   -----------------------

   overriding function Stream_Writer_Cap
     (Item : in out Transactional_Writable_File_Client)
      return Rose.Capabilities.Capability
   is
      use type Rose.Capabilities.Capability;
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      if Item.Stream_Writer_Interface_Cap = Rose.Capabilities.Null_Capability
        and then Item.Interface_Cap /= Rose.Capabilities.Null_Capability
      then
         Rose.System_Calls.Initialize_Send (Params, Item.Interface_Cap);
         Rose.System_Calls.Send_Word (Params, Natural (2));
         Rose.System_Calls.Receive_Caps (Params, 1);
         Rose.System_Calls.Invoke_Capability (Params);
         if Params.Control.Flags (Rose.Invocation.Error) then
            raise Rose.Interfaces.Objects.Invocation_Error
              with "Transactional_Writable_File.Stream_Writer_Cap";
         end if;
         Item.Stream_Writer_Interface_Cap := Params.Caps (0);
      end if;
      return Item.Stream_Writer_Interface_Cap;
   end Stream_Writer_Cap;

   -----------------------
   -- Transactional_Cap --
   -----------------------

   overriding function Transactional_Cap
     (Item : in out Transactional_Writable_File_Client)
      return Rose.Capabilities.Capability
   is
      use type Rose.Capabilities.Capability;
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      if Item.Transactional_Interface_Cap = Rose.Capabilities.Null_Capability
        and then Item.Interface_Cap /= Rose.Capabilities.Null_Capability
      then
         Rose.System_Calls.Initialize_Send (Params, Item.Interface_Cap);
         Rose.System_Calls.Send_Word (Params, Natural (4));
         Rose.System_Calls.Receive_Caps (Params, 1);
         Rose.System_Calls.Invoke_Capability (Params);
         if Params.Control.Flags (Rose.Invocation.Error) then
            raise Rose.Interfaces.Objects.Invocation_Error
              with "Transactional_Writable_File.Transactional_Cap";
         end if;
         Item.Transactional_Interface_Cap := Params.Caps (0);
      end if;
      return Item.Transactional_Interface_Cap;
   end Transactional_Cap;

   -------------------------------------
   -- Transactional_Writable_File_Cap --
   -------------------------------------

   overriding function Transactional_Writable_File_Cap
     (Item : in out Transactional_Writable_File_Client)
      return Rose.Capabilities.Capability
   is (Item.Interface_Cap);

   --------------
   -- Truncate --
   --------------

   overriding procedure Truncate
     (Item : in out Transactional_Writable_File_Client;
      Size : System.Storage_Elements.Storage_Count)
   is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      if not Item.Is_Open then
         Load (Item);
      end if;
      Rose.System_Calls.Initialize_Send (Params, Item.Truncate);
      Rose.System_Calls.Send_Storage_Offset (Params, Size);
      Rose.System_Calls.Invoke_Capability (Params);
      if Params.Control.Flags (Rose.Invocation.Error) then
         raise Rose.Interfaces.Objects.Invocation_Error
           with "Transactional_Writable_File.Truncate";
      end if;
   end Truncate;

   -----------------------
   -- Writable_File_Cap --
   -----------------------

   overriding function Writable_File_Cap
     (Item : in out Transactional_Writable_File_Client)
      return Rose.Capabilities.Capability
   is
      use type Rose.Capabilities.Capability;
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      if Item.Writable_File_Interface_Cap = Rose.Capabilities.Null_Capability
        and then Item.Interface_Cap /= Rose.Capabilities.Null_Capability
      then
         Rose.System_Calls.Initialize_Send (Params, Item.Interface_Cap);
         Rose.System_Calls.Send_Word (Params, Natural (3));
         Rose.System_Calls.Receive_Caps (Params, 1);
         Rose.System_Calls.Invoke_Capability (Params);
         if Params.Control.Flags (Rose.Invocation.Error) then
            raise Rose.Interfaces.Objects.Invocation_Error
              with "Transactional_Writable_File.Writable_File_Cap";
         end if;
         Item.Writable_File_Interface_Cap := Params.Caps (0);
      end if;
      return Item.Writable_File_Interface_Cap;
   end Writable_File_Cap;

   -----------
   -- Write --
   -----------

   overriding procedure Write
     (Item   : in out Transactional_Writable_File_Client;
      Buffer : Ada.Streams.Stream_Element_Array)
   is
      Params         : aliased Rose.Invocation.Invocation_Record;
      Buffer_Storage : System.Storage_Elements.Storage_Array
        (1 .. Buffer'Length)
        with Import, Address => Buffer'Address;
   begin
      if not Item.Is_Open then
         Load (Item);
      end if;
      Rose.System_Calls.Initialize_Send (Params, Item.Write);
      Rose.System_Calls.Send_Storage_Array (Params, Buffer_Storage, False);
      Rose.System_Calls.Invoke_Capability (Params);
      if Params.Control.Flags (Rose.Invocation.Error) then
         raise Rose.Interfaces.Objects.Invocation_Error
           with "Transactional_Writable_File.Write";
      end if;
   end Write;

end Rose.Interfaces.Transactional_Writable_File.Client;
