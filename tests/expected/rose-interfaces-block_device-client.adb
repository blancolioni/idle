with Rose.System_Calls;
with Rose.Words;

package body Rose.Interfaces.Block_Device.Client is

   use type Rose.Invocation.Invocation_Error;

   Last_Error : Rose.Invocation.Invocation_Error := Rose.Invocation.OK;

   -----------
   -- Close --
   -----------

   procedure Close (Client : in out Block_Device_Client) is
   begin
      Client.Is_Open := False;
      Rose.System_Calls.Delete_Cap (Client.Get_Parameters);
      Rose.System_Calls.Delete_Cap (Client.Read_Blocks);
      Rose.System_Calls.Delete_Cap (Client.Write_Blocks);
      Rose.System_Calls.Delete_Cap (Client.Interface_Cap);
   end Close;

   ----------------------------
   -- Get_Get_Parameters_Cap --
   ----------------------------

   function Get_Get_Parameters_Cap
     (Item : Block_Device_Client)
      return Rose.Capabilities.Capability
   is (Item.Get_Parameters);

   -----------------------
   -- Get_Interface_Cap --
   -----------------------

   function Get_Interface_Cap
     (Item : Block_Device_Client)
      return Rose.Capabilities.Capability
   is (Item.Interface_Cap);

   --------------------
   -- Get_Last_Error --
   --------------------

   function Get_Last_Error
      return Rose.Invocation.Invocation_Error
   is (Last_Error);

   --------------------
   -- Get_Parameters --
   --------------------

   procedure Get_Parameters
     (Item        : Block_Device_Client;
      Block_Count : out Rose.Interfaces.Block_Device.Block_Address_Type;
      Block_Size  : out Rose.Interfaces.Block_Device.Block_Size_Type)
   is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      Rose.System_Calls.Initialize_Send (Params, Item.Get_Parameters);
      Rose.System_Calls.Receive_Words (Params, 3);
      Rose.System_Calls.Invoke_Capability (Params);
      Last_Error := Rose.Invocation.OK;
      if Params.Control.Flags (Rose.Invocation.Error) then
         Last_Error := Params.Error;
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
     (Item : Block_Device_Client)
      return Rose.Capabilities.Capability
   is (Item.Read_Blocks);

   --------------------------
   -- Get_Write_Blocks_Cap --
   --------------------------

   function Get_Write_Blocks_Cap
     (Item : Block_Device_Client)
      return Rose.Capabilities.Capability
   is (Item.Write_Blocks);

   ---------------
   -- Has_Error --
   ---------------

   function Has_Error return Boolean is (Last_Error /= Rose.Invocation.OK);

   ----------
   -- Open --
   ----------

   procedure Open
     (Client        : out Block_Device_Client;
      Interface_Cap : Rose.Capabilities.Capability)
   is
      Params : aliased Rose.Invocation.Invocation_Record;
      Caps   : Rose.Capabilities.Capability_Array (1 .. Subprogram_Count);
      Index  : Natural := 0;
      First  : Natural := Natural'Last;
   begin
      Client.Is_Open := False;
      Client.Interface_Cap := Interface_Cap;
      for Cap of Caps loop
         if First > Index
           or else Index - First >= Rose.Invocation.Max_Capabilities
         then
            First := Index;
            Rose.System_Calls.Initialize_Send (Params, Interface_Cap);
            Rose.System_Calls.Send_Word (Params, Natural (0));
            Rose.System_Calls.Send_Word (Params, First);
            Rose.System_Calls.Send_Word
              (Params,
               Natural'Min
                 (Rose.Invocation.Max_Capabilities,
                  Subprogram_Count - First));
            Rose.System_Calls.Receive_Caps
              (Params,
               Natural'Min
                 (Rose.Invocation.Max_Capabilities,
                  Subprogram_Count - First));
            Rose.System_Calls.Invoke_Capability (Params);
         end if;
         Cap := Params.Caps (Rose.Invocation.Capability_Index (Index - First));
         Index := Index + 1;
      end loop;
      Client.Get_Parameters := Caps (Get_Parameters_Index + 1);
      Client.Read_Blocks := Caps (Read_Blocks_Index + 1);
      Client.Write_Blocks := Caps (Write_Blocks_Index + 1);
      Client.Is_Open := True;
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

   procedure Read_Blocks
     (Item   : Block_Device_Client;
      Start  : Rose.Interfaces.Block_Device.Block_Address_Type;
      Count  : Natural;
      Blocks : out System.Storage_Elements.Storage_Array)
   is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      Rose.System_Calls.Initialize_Send (Params, Item.Read_Blocks);
      Rose.System_Calls.Send_Word (Params, Rose.Words.Word_64 (Start));
      Rose.System_Calls.Send_Word (Params, Count);
      Rose.System_Calls.Receive_Buffer (Params, Blocks'Length);
      Rose.System_Calls.Invoke_Capability (Params);
      Last_Error := Rose.Invocation.OK;
      if Params.Control.Flags (Rose.Invocation.Error) then
         Last_Error := Params.Error;
      end if;
      Rose.System_Calls.Copy_Received_Buffer (Blocks'Length, Blocks'Address);
   end Read_Blocks;

   ------------------
   -- Write_Blocks --
   ------------------

   procedure Write_Blocks
     (Item   : Block_Device_Client;
      Start  : Rose.Interfaces.Block_Device.Block_Address_Type;
      Count  : Natural;
      Blocks : System.Storage_Elements.Storage_Array)
   is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      Rose.System_Calls.Initialize_Send (Params, Item.Write_Blocks);
      Rose.System_Calls.Send_Word (Params, Rose.Words.Word_64 (Start));
      Rose.System_Calls.Send_Word (Params, Count);
      Rose.System_Calls.Send_Storage_Array (Params, Blocks, False);
      Rose.System_Calls.Invoke_Capability (Params);
      Last_Error := Rose.Invocation.OK;
      if Params.Control.Flags (Rose.Invocation.Error) then
         Last_Error := Params.Error;
      end if;
   end Write_Blocks;

end Rose.Interfaces.Block_Device.Client;
