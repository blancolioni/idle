with Rose.Interfaces.Objects;
with Rose.Invocation;
with Rose.System_Calls;

package body Rose.Interfaces.Stream_Reader.Client is

   -----------
   -- Close --
   -----------

   procedure Close (Client : in out Stream_Reader_Client) is
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
      Rose.System_Calls.Send_Cap (Params, Client.Interface_Cap);
      Rose.System_Calls.Invoke_Capability (Params);
   end Close;

   -----------------------
   -- Get_Interface_Cap --
   -----------------------

   function Get_Interface_Cap
     (Item : Stream_Reader_Client)
      return Rose.Capabilities.Capability
   is (Item.Interface_Cap);

   ------------------
   -- Get_Read_Cap --
   ------------------

   function Get_Read_Cap
     (Item : Stream_Reader_Client)
      return Rose.Capabilities.Capability
   is (Item.Read);

   ----------
   -- Open --
   ----------

   procedure Open
     (Client        : out Stream_Reader_Client;
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
      Client.Is_Open := True;
   end Open;

   ------------------
   -- Open_Cap_Set --
   ------------------

   procedure Open_Cap_Set
     (Client : out Stream_Reader_Client;
      Read   : Rose.Capabilities.Capability)
   is
   begin
      Client.Read := Read;
      Client.Is_Open := True;
   end Open_Cap_Set;

   ----------
   -- Read --
   ----------

   overriding procedure Read
     (Item   : in out Stream_Reader_Client;
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
         raise Rose.Interfaces.Objects.Invocation_Error
           with "Stream_Reader.Read";
      end if;
      Rose.System_Calls.Copy_Received_Buffer (Buffer'Length, Buffer'Address);
      Last :=
        System.Storage_Elements.Storage_Count
          (Rose.System_Calls.Get_Word_32 (Params, 0));
   end Read;

end Rose.Interfaces.Stream_Reader.Client;
