with Rose.Interfaces.Objects;
with Rose.Invocation;
with Rose.System_Calls;

package body Rose.Interfaces.Seekable_File_Reader.Client is

   procedure Load (Item : in out Seekable_File_Reader_Client);

   -----------
   -- Close --
   -----------

   procedure Close (Client : in out Seekable_File_Reader_Client) is
      use type Rose.Capabilities.Capability;
   begin
      if Client.Is_Open
        or else Client.Interface_Cap /= Rose.Capabilities.Null_Capability
      then
         Release (Client);
      end if;
      if Client.Is_Open then
         Rose.System_Calls.Delete_Cap (Client.Read);
         Rose.System_Calls.Delete_Cap (Client.Release);
         Rose.System_Calls.Delete_Cap (Client.Seek);
      end if;
      Client.Is_Open := False;
      if Client.Stream_Reader_Interface_Cap /= Rose.Capabilities
        .Null_Capability
      then
         Rose.System_Calls.Delete_Cap (Client.Stream_Reader_Interface_Cap);
         Client.Stream_Reader_Interface_Cap :=
           Rose.Capabilities.Null_Capability;
      end if;
      if Client.Resource_Interface_Cap /= Rose.Capabilities.Null_Capability
      then
         Rose.System_Calls.Delete_Cap (Client.Resource_Interface_Cap);
         Client.Resource_Interface_Cap := Rose.Capabilities.Null_Capability;
      end if;
      if Client.File_Reader_Interface_Cap /= Rose.Capabilities.Null_Capability
      then
         Rose.System_Calls.Delete_Cap (Client.File_Reader_Interface_Cap);
         Client.File_Reader_Interface_Cap := Rose.Capabilities.Null_Capability;
      end if;
      if Client.Seekable_Interface_Cap /= Rose.Capabilities.Null_Capability
      then
         Rose.System_Calls.Delete_Cap (Client.Seekable_Interface_Cap);
         Client.Seekable_Interface_Cap := Rose.Capabilities.Null_Capability;
      end if;
      Rose.System_Calls.Delete_Cap (Client.Interface_Cap);
   end Close;

   ---------------------
   -- File_Reader_Cap --
   ---------------------

   overriding function File_Reader_Cap
     (Item : in out Seekable_File_Reader_Client)
      return Rose.Capabilities.Capability
   is
      use type Rose.Capabilities.Capability;
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      if Item.File_Reader_Interface_Cap = Rose.Capabilities.Null_Capability
        and then Item.Interface_Cap /= Rose.Capabilities.Null_Capability
      then
         Rose.System_Calls.Initialize_Send (Params, Item.Interface_Cap);
         Rose.System_Calls.Send_Word (Params, Natural (3));
         Rose.System_Calls.Receive_Caps (Params, 1);
         Rose.System_Calls.Invoke_Capability (Params);
         if Params.Control.Flags (Rose.Invocation.Error) then
            raise Rose.Interfaces.Objects.Invocation_Error
              with "Seekable_File_Reader.File_Reader_Cap";
         end if;
         Item.File_Reader_Interface_Cap := Params.Caps (0);
      end if;
      return Item.File_Reader_Interface_Cap;
   end File_Reader_Cap;

   --------------
   -- From_Cap --
   --------------

   function From_Cap
     (Cap : Rose.Capabilities.Capability)
      return Seekable_File_Reader_Client
   is (Seekable_File_Reader_Client'(Interface_Cap => Cap, others => <>));

   -----------------------
   -- Get_Interface_Cap --
   -----------------------

   function Get_Interface_Cap
     (Item : Seekable_File_Reader_Client)
      return Rose.Capabilities.Capability
   is (Item.Interface_Cap);

   ------------------
   -- Get_Read_Cap --
   ------------------

   function Get_Read_Cap
     (Item : in out Seekable_File_Reader_Client)
      return Rose.Capabilities.Capability
   is
   begin
      if not Item.Is_Open then
         Load (Item);
      end if;
      return Item.Read;
   end Get_Read_Cap;

   ---------------------
   -- Get_Release_Cap --
   ---------------------

   function Get_Release_Cap
     (Item : in out Seekable_File_Reader_Client)
      return Rose.Capabilities.Capability
   is
   begin
      if not Item.Is_Open then
         Load (Item);
      end if;
      return Item.Release;
   end Get_Release_Cap;

   ------------------
   -- Get_Seek_Cap --
   ------------------

   function Get_Seek_Cap
     (Item : in out Seekable_File_Reader_Client)
      return Rose.Capabilities.Capability
   is
   begin
      if not Item.Is_Open then
         Load (Item);
      end if;
      return Item.Seek;
   end Get_Seek_Cap;

   ----------
   -- Load --
   ----------

   procedure Load (Item : in out Seekable_File_Reader_Client) is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      Rose.System_Calls.Initialize_Send (Params, Item.Interface_Cap);
      Rose.System_Calls.Receive_Caps (Params, Subprogram_Count);
      Rose.System_Calls.Invoke_Capability (Params);
      if Params.Control.Flags (Rose.Invocation.Error) then
         raise Rose.Interfaces.Objects.Invocation_Error
           with "Seekable_File_Reader.Open";
      end if;
      Item.Read := Params.Caps (Read_Index);
      Item.Release := Params.Caps (Release_Index);
      Item.Seek := Params.Caps (Seek_Index);
      Item.Is_Open := True;
   end Load;

   ----------
   -- Open --
   ----------

   procedure Open
     (Client        : out Seekable_File_Reader_Client;
      Interface_Cap : Rose.Capabilities.Capability)
   is
   begin
      Client.Is_Open := False;
      Client.Interface_Cap := Interface_Cap;
      Client.Stream_Reader_Interface_Cap := Rose.Capabilities.Null_Capability;
      Client.Resource_Interface_Cap := Rose.Capabilities.Null_Capability;
      Client.File_Reader_Interface_Cap := Rose.Capabilities.Null_Capability;
      Client.Seekable_Interface_Cap := Rose.Capabilities.Null_Capability;
   end Open;

   ------------------
   -- Open_Cap_Set --
   ------------------

   procedure Open_Cap_Set
     (Client  : out Seekable_File_Reader_Client;
      Read    : Rose.Capabilities.Capability;
      Release : Rose.Capabilities.Capability;
      Seek    : Rose.Capabilities.Capability)
   is
   begin
      Client.Read := Read;
      Client.Release := Release;
      Client.Seek := Seek;
      Client.Is_Open := True;
   end Open_Cap_Set;

   ----------
   -- Read --
   ----------

   overriding procedure Read
     (Item   : in out Seekable_File_Reader_Client;
      Buffer : out System.Storage_Elements.Storage_Array;
      Last   : out System.Storage_Elements.Storage_Count)
   is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      if not Item.Is_Open then
         Load (Item);
      end if;
      Rose.System_Calls.Initialize_Send (Params, Item.Read);
      Rose.System_Calls.Receive_Buffer (Params, Buffer'Length);
      Rose.System_Calls.Receive_Words (Params, 1);
      Rose.System_Calls.Invoke_Capability (Params);
      if Params.Control.Flags (Rose.Invocation.Error) then
         raise Rose.Interfaces.Objects.Invocation_Error
           with "Seekable_File_Reader.Read";
      end if;
      Rose.System_Calls.Copy_Received_Buffer (Buffer'Length, Buffer'Address);
      Last :=
        System.Storage_Elements.Storage_Count
          (Rose.System_Calls.Get_Word_32 (Params, 0));
   end Read;

   -------------
   -- Release --
   -------------

   overriding procedure Release (Item : in out Seekable_File_Reader_Client) is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      if not Item.Is_Open then
         Load (Item);
      end if;
      Rose.System_Calls.Initialize_Send (Params, Item.Release);
      Rose.System_Calls.Invoke_Capability (Params);
      if Params.Control.Flags (Rose.Invocation.Error) then
         raise Rose.Interfaces.Objects.Invocation_Error
           with "Seekable_File_Reader.Release";
      end if;
   end Release;

   ------------------
   -- Resource_Cap --
   ------------------

   overriding function Resource_Cap
     (Item : in out Seekable_File_Reader_Client)
      return Rose.Capabilities.Capability
   is
      use type Rose.Capabilities.Capability;
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      if Item.Resource_Interface_Cap = Rose.Capabilities.Null_Capability
        and then Item.Interface_Cap /= Rose.Capabilities.Null_Capability
      then
         Rose.System_Calls.Initialize_Send (Params, Item.Interface_Cap);
         Rose.System_Calls.Send_Word (Params, Natural (2));
         Rose.System_Calls.Receive_Caps (Params, 1);
         Rose.System_Calls.Invoke_Capability (Params);
         if Params.Control.Flags (Rose.Invocation.Error) then
            raise Rose.Interfaces.Objects.Invocation_Error
              with "Seekable_File_Reader.Resource_Cap";
         end if;
         Item.Resource_Interface_Cap := Params.Caps (0);
      end if;
      return Item.Resource_Interface_Cap;
   end Resource_Cap;

   ----------
   -- Seek --
   ----------

   overriding procedure Seek
     (Item              : in out Seekable_File_Reader_Client;
      Offset_From_Start : Rose.Words.Word_64)
   is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      if not Item.Is_Open then
         Load (Item);
      end if;
      Rose.System_Calls.Initialize_Send (Params, Item.Seek);
      Rose.System_Calls.Send_Word (Params, Offset_From_Start);
      Rose.System_Calls.Invoke_Capability (Params);
      if Params.Control.Flags (Rose.Invocation.Error) then
         raise Rose.Interfaces.Objects.Invocation_Error
           with "Seekable_File_Reader.Seek";
      end if;
   end Seek;

   ------------------
   -- Seekable_Cap --
   ------------------

   overriding function Seekable_Cap
     (Item : in out Seekable_File_Reader_Client)
      return Rose.Capabilities.Capability
   is
      use type Rose.Capabilities.Capability;
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      if Item.Seekable_Interface_Cap = Rose.Capabilities.Null_Capability
        and then Item.Interface_Cap /= Rose.Capabilities.Null_Capability
      then
         Rose.System_Calls.Initialize_Send (Params, Item.Interface_Cap);
         Rose.System_Calls.Send_Word (Params, Natural (4));
         Rose.System_Calls.Receive_Caps (Params, 1);
         Rose.System_Calls.Invoke_Capability (Params);
         if Params.Control.Flags (Rose.Invocation.Error) then
            raise Rose.Interfaces.Objects.Invocation_Error
              with "Seekable_File_Reader.Seekable_Cap";
         end if;
         Item.Seekable_Interface_Cap := Params.Caps (0);
      end if;
      return Item.Seekable_Interface_Cap;
   end Seekable_Cap;

   ------------------------------
   -- Seekable_File_Reader_Cap --
   ------------------------------

   overriding function Seekable_File_Reader_Cap
     (Item : in out Seekable_File_Reader_Client)
      return Rose.Capabilities.Capability
   is (Item.Interface_Cap);

   -----------------------
   -- Stream_Reader_Cap --
   -----------------------

   overriding function Stream_Reader_Cap
     (Item : in out Seekable_File_Reader_Client)
      return Rose.Capabilities.Capability
   is
      use type Rose.Capabilities.Capability;
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      if Item.Stream_Reader_Interface_Cap = Rose.Capabilities.Null_Capability
        and then Item.Interface_Cap /= Rose.Capabilities.Null_Capability
      then
         Rose.System_Calls.Initialize_Send (Params, Item.Interface_Cap);
         Rose.System_Calls.Send_Word (Params, Natural (1));
         Rose.System_Calls.Receive_Caps (Params, 1);
         Rose.System_Calls.Invoke_Capability (Params);
         if Params.Control.Flags (Rose.Invocation.Error) then
            raise Rose.Interfaces.Objects.Invocation_Error
              with "Seekable_File_Reader.Stream_Reader_Cap";
         end if;
         Item.Stream_Reader_Interface_Cap := Params.Caps (0);
      end if;
      return Item.Stream_Reader_Interface_Cap;
   end Stream_Reader_Cap;

end Rose.Interfaces.Seekable_File_Reader.Client;
