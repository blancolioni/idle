with Rose.Interfaces.Objects;
with Rose.Invocation;
with Rose.System_Calls;
with Rose.Words;

package body Rose.Interfaces.Block_Device.Client is

   procedure Load (Item : in out Block_Device_Client);

   ----------------------
   -- Block_Device_Cap --
   ----------------------

   overriding function Block_Device_Cap
     (Item : in out Block_Device_Client)
      return Rose.Capabilities.Capability
   is (Item.Interface_Cap);

   -----------
   -- Close --
   -----------

   procedure Close (Client : in out Block_Device_Client) is
   begin
      if Client.Is_Open then
         Rose.System_Calls.Delete_Cap (Client.Get_Parameters);
         Rose.System_Calls.Delete_Cap (Client.Read_Blocks);
         Rose.System_Calls.Delete_Cap (Client.Write_Blocks);
      end if;
      Client.Is_Open := False;
      Rose.System_Calls.Delete_Cap (Client.Interface_Cap);
   end Close;

   --------------
   -- From_Cap --
   --------------

   function From_Cap
     (Cap : Rose.Capabilities.Capability)
      return Block_Device_Client
   is (Block_Device_Client'(Interface_Cap => Cap, others => <>));

   ----------------------------
   -- Get_Get_Parameters_Cap --
   ----------------------------

   function Get_Get_Parameters_Cap
     (Item : in out Block_Device_Client)
      return Rose.Capabilities.Capability
   is
   begin
      if not Item.Is_Open then
         Load (Item);
      end if;
      return Item.Get_Parameters;
   end Get_Get_Parameters_Cap;

   -----------------------
   -- Get_Interface_Cap --
   -----------------------

   function Get_Interface_Cap
     (Item : Block_Device_Client)
      return Rose.Capabilities.Capability
   is (Item.Interface_Cap);

   --------------------
   -- Get_Parameters --
   --------------------

   overriding procedure Get_Parameters
     (Item        : in out Block_Device_Client;
      Block_Count : out Rose.Interfaces.Block_Device.Block_Address_Type;
      Block_Size  : out Rose.Interfaces.Block_Device.Block_Size_Type)
   is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      if not Item.Is_Open then
         Load (Item);
      end if;
      Rose.System_Calls.Initialize_Send (Params, Item.Get_Parameters);
      Rose.System_Calls.Receive_Words (Params, 3);
      Rose.System_Calls.Invoke_Capability (Params);
      if Params.Control.Flags (Rose.Invocation.Error) then
         raise Rose.Interfaces.Objects.Invocation_Error
           with "Block_Device.Get_Parameters";
      end if;
      Block_Count :=
        Rose.Interfaces.Block_Device.Block_Address_Type
          (Rose.System_Calls.Get_Word_64 (Params, 0));
      Block_Size :=
        Rose.Interfaces.Block_Device.Block_Size_Type
          (Rose.System_Calls.Get_Word_32 (Params, 2));
   end Get_Parameters;

   -------------------------
   -- Get_Read_Blocks_Cap --
   -------------------------

   function Get_Read_Blocks_Cap
     (Item : in out Block_Device_Client)
      return Rose.Capabilities.Capability
   is
   begin
      if not Item.Is_Open then
         Load (Item);
      end if;
      return Item.Read_Blocks;
   end Get_Read_Blocks_Cap;

   --------------------------
   -- Get_Write_Blocks_Cap --
   --------------------------

   function Get_Write_Blocks_Cap
     (Item : in out Block_Device_Client)
      return Rose.Capabilities.Capability
   is
   begin
      if not Item.Is_Open then
         Load (Item);
      end if;
      return Item.Write_Blocks;
   end Get_Write_Blocks_Cap;

   ----------
   -- Load --
   ----------

   procedure Load (Item : in out Block_Device_Client) is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      Rose.System_Calls.Initialize_Send (Params, Item.Interface_Cap);
      Rose.System_Calls.Receive_Caps (Params, Subprogram_Count);
      Rose.System_Calls.Invoke_Capability (Params);
      if Params.Control.Flags (Rose.Invocation.Error) then
         raise Rose.Interfaces.Objects.Invocation_Error
           with "Block_Device.Open";
      end if;
      Item.Get_Parameters := Params.Caps (Get_Parameters_Index);
      Item.Read_Blocks := Params.Caps (Read_Blocks_Index);
      Item.Write_Blocks := Params.Caps (Write_Blocks_Index);
      Item.Is_Open := True;
   end Load;

   ----------
   -- Open --
   ----------

   procedure Open
     (Client        : out Block_Device_Client;
      Interface_Cap : Rose.Capabilities.Capability)
   is
   begin
      Client.Is_Open := False;
      Client.Interface_Cap := Interface_Cap;
   end Open;

   ------------------
   -- Open_Cap_Set --
   ------------------

   procedure Open_Cap_Set
     (Client         : out Block_Device_Client;
      Get_Parameters : Rose.Capabilities.Capability;
      Read_Blocks    : Rose.Capabilities.Capability;
      Write_Blocks   : Rose.Capabilities.Capability)
   is
   begin
      Client.Get_Parameters := Get_Parameters;
      Client.Read_Blocks := Read_Blocks;
      Client.Write_Blocks := Write_Blocks;
      Client.Is_Open := True;
   end Open_Cap_Set;

   -----------------
   -- Read_Blocks --
   -----------------

   overriding procedure Read_Blocks
     (Item   : in out Block_Device_Client;
      Start  : Rose.Interfaces.Block_Device.Block_Address_Type;
      Count  : Natural;
      Blocks : out System.Storage_Elements.Storage_Array)
   is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      if not Item.Is_Open then
         Load (Item);
      end if;
      Rose.System_Calls.Initialize_Send (Params, Item.Read_Blocks);
      Rose.System_Calls.Send_Word (Params, Rose.Words.Word_64 (Start));
      Rose.System_Calls.Send_Word (Params, Count);
      Rose.System_Calls.Receive_Buffer (Params, Blocks'Length);
      Rose.System_Calls.Invoke_Capability (Params);
      if Params.Control.Flags (Rose.Invocation.Error) then
         raise Rose.Interfaces.Objects.Invocation_Error
           with "Block_Device.Read_Blocks";
      end if;
      Rose.System_Calls.Copy_Received_Buffer (Blocks'Length, Blocks'Address);
   end Read_Blocks;

   ------------------
   -- Write_Blocks --
   ------------------

   overriding procedure Write_Blocks
     (Item   : in out Block_Device_Client;
      Start  : Rose.Interfaces.Block_Device.Block_Address_Type;
      Count  : Natural;
      Blocks : System.Storage_Elements.Storage_Array)
   is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      if not Item.Is_Open then
         Load (Item);
      end if;
      Rose.System_Calls.Initialize_Send (Params, Item.Write_Blocks);
      Rose.System_Calls.Send_Word (Params, Rose.Words.Word_64 (Start));
      Rose.System_Calls.Send_Word (Params, Count);
      Rose.System_Calls.Send_Storage_Array (Params, Blocks, False);
      Rose.System_Calls.Invoke_Capability (Params);
      if Params.Control.Flags (Rose.Invocation.Error) then
         raise Rose.Interfaces.Objects.Invocation_Error
           with "Block_Device.Write_Blocks";
      end if;
   end Write_Blocks;

end Rose.Interfaces.Block_Device.Client;
