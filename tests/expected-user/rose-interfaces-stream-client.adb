with Rose.Interfaces.Objects;
with Rose.Invocation;
with Rose.System_Calls;

package body Rose.Interfaces.Stream.Client is

   procedure Load (Item : in out Stream_Client);

   -----------
   -- Close --
   -----------

   procedure Close (Client : in out Stream_Client) is
      use type Rose.Capabilities.Capability;
   begin
      if Client.Is_Open then
         Rose.System_Calls.Delete_Cap (Client.Read);
         Rose.System_Calls.Delete_Cap (Client.Write);
      end if;
      Client.Is_Open := False;
      if Client.Stream_Reader_Interface_Cap /= Rose.Capabilities
        .Null_Capability
      then
         Rose.System_Calls.Delete_Cap (Client.Stream_Reader_Interface_Cap);
         Client.Stream_Reader_Interface_Cap :=
           Rose.Capabilities.Null_Capability;
      end if;
      if Client.Stream_Writer_Interface_Cap /= Rose.Capabilities
        .Null_Capability
      then
         Rose.System_Calls.Delete_Cap (Client.Stream_Writer_Interface_Cap);
         Client.Stream_Writer_Interface_Cap :=
           Rose.Capabilities.Null_Capability;
      end if;
      Rose.System_Calls.Delete_Cap (Client.Interface_Cap);
   end Close;

   --------------
   -- From_Cap --
   --------------

   function From_Cap
     (Cap : Rose.Capabilities.Capability)
      return Stream_Client
   is (Stream_Client'(Interface_Cap => Cap, others => <>));

   -----------------------
   -- Get_Interface_Cap --
   -----------------------

   function Get_Interface_Cap
     (Item : Stream_Client)
      return Rose.Capabilities.Capability
   is (Item.Interface_Cap);

   ------------------
   -- Get_Read_Cap --
   ------------------

   function Get_Read_Cap
     (Item : in out Stream_Client)
      return Rose.Capabilities.Capability
   is
   begin
      if not Item.Is_Open then
         Load (Item);
      end if;
      return Item.Read;
   end Get_Read_Cap;

   -------------------
   -- Get_Write_Cap --
   -------------------

   function Get_Write_Cap
     (Item : in out Stream_Client)
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

   procedure Load (Item : in out Stream_Client) is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      Rose.System_Calls.Initialize_Send (Params, Item.Interface_Cap);
      Rose.System_Calls.Receive_Caps (Params, Subprogram_Count);
      Rose.System_Calls.Invoke_Capability (Params);
      if Params.Control.Flags (Rose.Invocation.Error) then
         raise Rose.Interfaces.Objects.Invocation_Error with "Stream.Open";
      end if;
      Item.Read := Params.Caps (Read_Index);
      Item.Write := Params.Caps (Write_Index);
      Item.Is_Open := True;
   end Load;

   ----------
   -- Open --
   ----------

   procedure Open
     (Client        : out Stream_Client;
      Interface_Cap : Rose.Capabilities.Capability)
   is
   begin
      Client.Is_Open := False;
      Client.Interface_Cap := Interface_Cap;
      Client.Stream_Reader_Interface_Cap := Rose.Capabilities.Null_Capability;
      Client.Stream_Writer_Interface_Cap := Rose.Capabilities.Null_Capability;
   end Open;

   ------------------
   -- Open_Cap_Set --
   ------------------

   procedure Open_Cap_Set
     (Client : out Stream_Client;
      Read   : Rose.Capabilities.Capability;
      Write  : Rose.Capabilities.Capability)
   is
   begin
      Client.Read := Read;
      Client.Write := Write;
      Client.Is_Open := True;
   end Open_Cap_Set;

   ----------
   -- Read --
   ----------

   overriding procedure Read
     (Item   : in out Stream_Client;
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
         raise Rose.Interfaces.Objects.Invocation_Error with "Stream.Read";
      end if;
      Rose.System_Calls.Copy_Received_Buffer (Buffer'Length, Buffer'Address);
      Last :=
        System.Storage_Elements.Storage_Count
          (Rose.System_Calls.Get_Word_32 (Params, 0));
   end Read;

   ----------------
   -- Stream_Cap --
   ----------------

   overriding function Stream_Cap
     (Item : in out Stream_Client)
      return Rose.Capabilities.Capability
   is (Item.Interface_Cap);

   -----------------------
   -- Stream_Reader_Cap --
   -----------------------

   overriding function Stream_Reader_Cap
     (Item : in out Stream_Client)
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
              with "Stream.Stream_Reader_Cap";
         end if;
         Item.Stream_Reader_Interface_Cap := Params.Caps (0);
      end if;
      return Item.Stream_Reader_Interface_Cap;
   end Stream_Reader_Cap;

   -----------------------
   -- Stream_Writer_Cap --
   -----------------------

   overriding function Stream_Writer_Cap
     (Item : in out Stream_Client)
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
              with "Stream.Stream_Writer_Cap";
         end if;
         Item.Stream_Writer_Interface_Cap := Params.Caps (0);
      end if;
      return Item.Stream_Writer_Interface_Cap;
   end Stream_Writer_Cap;

   -----------
   -- Write --
   -----------

   overriding procedure Write
     (Item   : in out Stream_Client;
      Buffer : System.Storage_Elements.Storage_Array)
   is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      if not Item.Is_Open then
         Load (Item);
      end if;
      Rose.System_Calls.Initialize_Send (Params, Item.Write);
      Rose.System_Calls.Send_Storage_Array (Params, Buffer, False);
      Rose.System_Calls.Invoke_Capability (Params);
      if Params.Control.Flags (Rose.Invocation.Error) then
         raise Rose.Interfaces.Objects.Invocation_Error with "Stream.Write";
      end if;
   end Write;

end Rose.Interfaces.Stream.Client;
