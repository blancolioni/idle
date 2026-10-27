with Rose.Interfaces.Objects;
with Rose.Invocation;
with Rose.System_Calls;

package body Rose.Interfaces.File.Client is

   -----------
   -- Close --
   -----------

   procedure Close (Client : in out File_Client) is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      Client.Is_Open := False;
      Rose.System_Calls.Initialize_Send
        (Params,
         Rose.System_Calls.Delete_Cap_Capability);
      Rose.System_Calls.Send_Cap (Params, Client.Read);
      Rose.System_Calls.Invoke_Capability (Params);
      Rose.System_Calls.Initialize_Send
        (Params,
         Rose.System_Calls.Delete_Cap_Capability);
      Rose.System_Calls.Send_Cap (Params, Client.Write);
      Rose.System_Calls.Invoke_Capability (Params);
      Rose.System_Calls.Initialize_Send
        (Params,
         Rose.System_Calls.Delete_Cap_Capability);
      Rose.System_Calls.Send_Cap (Params, Client.Seek);
      Rose.System_Calls.Invoke_Capability (Params);
      Rose.System_Calls.Initialize_Send
        (Params,
         Rose.System_Calls.Delete_Cap_Capability);
      Rose.System_Calls.Send_Cap (Params, Client.Interface_Cap);
      Rose.System_Calls.Invoke_Capability (Params);
   end Close;

   -----------------------
   -- Get_Interface_Cap --
   -----------------------

   function Get_Interface_Cap
     (Item : File_Client)
      return Rose.Capabilities.Capability
   is (Item.Interface_Cap);

   ------------------
   -- Get_Read_Cap --
   ------------------

   function Get_Read_Cap
     (Item : File_Client)
      return Rose.Capabilities.Capability
   is (Item.Read);

   ------------------
   -- Get_Seek_Cap --
   ------------------

   function Get_Seek_Cap
     (Item : File_Client)
      return Rose.Capabilities.Capability
   is (Item.Seek);

   -------------------
   -- Get_Write_Cap --
   -------------------

   function Get_Write_Cap
     (Item : File_Client)
      return Rose.Capabilities.Capability
   is (Item.Write);

   ----------
   -- Open --
   ----------

   procedure Open
     (Client        : out File_Client;
      Interface_Cap : Rose.Capabilities.Capability)
   is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      Client.Is_Open := False;
      Client.Interface_Cap := Interface_Cap;
      Rose.System_Calls.Initialize_Send (Params, Interface_Cap);
      Rose.System_Calls.Receive_Caps (Params, Subprogram_Count);
      Rose.System_Calls.Invoke_Capability (Params);
      Client.Read := Params.Caps (Read_Index);
      Client.Write := Params.Caps (Write_Index);
      Client.Seek := Params.Caps (Seek_Index);
      Client.Is_Open := True;
   end Open;

   ------------------
   -- Open_Cap_Set --
   ------------------

   procedure Open_Cap_Set
     (Client : out File_Client;
      Read   : Rose.Capabilities.Capability;
      Write  : Rose.Capabilities.Capability;
      Seek   : Rose.Capabilities.Capability)
   is
   begin
      Client.Read := Read;
      Client.Write := Write;
      Client.Seek := Seek;
      Client.Is_Open := True;
   end Open_Cap_Set;

   ----------
   -- Read --
   ----------

   overriding procedure Read
     (Item   : in out File_Client;
      Buffer : out System.Storage_Elements.Storage_Array;
      Last   : out System.Storage_Elements.Storage_Count)
   is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      Rose.System_Calls.Initialize_Send (Params, Item.Read);
      Rose.System_Calls.Receive_Buffer (Params, Buffer'Length);
      Rose.System_Calls.Receive_Words (Params, 1);
      Rose.System_Calls.Invoke_Capability (Params);
      if Params.Control.Flags (Rose.Invocation.Error) then
         raise Rose.Interfaces.Objects.Invocation_Error with "File.Read";
      end if;
      Rose.System_Calls.Copy_Received_Buffer (Buffer'Length, Buffer'Address);
      Last :=
        System.Storage_Elements.Storage_Count
          (Rose.System_Calls.Get_Word_32 (Params, 0));
   end Read;

   ----------
   -- Seek --
   ----------

   overriding procedure Seek
     (Item              : in out File_Client;
      Offset_From_Start : Rose.Words.Word_64)
   is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      Rose.System_Calls.Initialize_Send (Params, Item.Seek);
      Rose.System_Calls.Send_Word (Params, Offset_From_Start);
      Rose.System_Calls.Invoke_Capability (Params);
      if Params.Control.Flags (Rose.Invocation.Error) then
         raise Rose.Interfaces.Objects.Invocation_Error with "File.Seek";
      end if;
   end Seek;

   -----------
   -- Write --
   -----------

   overriding procedure Write
     (Item   : in out File_Client;
      Buffer : System.Storage_Elements.Storage_Array)
   is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      Rose.System_Calls.Initialize_Send (Params, Item.Write);
      Rose.System_Calls.Send_Storage_Array (Params, Buffer, False);
      Rose.System_Calls.Invoke_Capability (Params);
      if Params.Control.Flags (Rose.Invocation.Error) then
         raise Rose.Interfaces.Objects.Invocation_Error with "File.Write";
      end if;
   end Write;

end Rose.Interfaces.File.Client;
