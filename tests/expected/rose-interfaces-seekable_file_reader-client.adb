with Rose.System_Calls;

package body Rose.Interfaces.Seekable_File_Reader.Client is

   use type Rose.Invocation.Invocation_Error;

   Last_Error : Rose.Invocation.Invocation_Error := Rose.Invocation.OK;

   -----------
   -- Close --
   -----------

   procedure Close (Client : in out Seekable_File_Reader_Client) is
   begin
      if Client.Is_Open then
         Release (Client);
      end if;
      Client.Is_Open := False;
      Rose.System_Calls.Delete_Cap (Client.Read);
      Rose.System_Calls.Delete_Cap (Client.Release);
      Rose.System_Calls.Delete_Cap (Client.Seek);
      Rose.System_Calls.Delete_Cap (Client.Interface_Cap);
   end Close;

   -----------------------
   -- Get_Interface_Cap --
   -----------------------

   function Get_Interface_Cap
     (Item : Seekable_File_Reader_Client)
      return Rose.Capabilities.Capability
   is (Item.Interface_Cap);

   --------------------
   -- Get_Last_Error --
   --------------------

   function Get_Last_Error
      return Rose.Invocation.Invocation_Error
   is (Last_Error);

   ------------------
   -- Get_Read_Cap --
   ------------------

   function Get_Read_Cap
     (Item : Seekable_File_Reader_Client)
      return Rose.Capabilities.Capability
   is (Item.Read);

   ---------------------
   -- Get_Release_Cap --
   ---------------------

   function Get_Release_Cap
     (Item : Seekable_File_Reader_Client)
      return Rose.Capabilities.Capability
   is (Item.Release);

   ------------------
   -- Get_Seek_Cap --
   ------------------

   function Get_Seek_Cap
     (Item : Seekable_File_Reader_Client)
      return Rose.Capabilities.Capability
   is (Item.Seek);

   ---------------
   -- Has_Error --
   ---------------

   function Has_Error return Boolean is (Last_Error /= Rose.Invocation.OK);

   ----------
   -- Open --
   ----------

   procedure Open
     (Client        : out Seekable_File_Reader_Client;
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
      Client.Release := Params.Caps (Release_Index);
      Client.Seek := Params.Caps (Seek_Index);
      Client.Is_Open := True;
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

   procedure Read
     (Item   : Seekable_File_Reader_Client;
      Buffer : out System.Storage_Elements.Storage_Array;
      Last   : out System.Storage_Elements.Storage_Count)
   is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      Rose.System_Calls.Initialize_Send (Params, Item.Read);
      Rose.System_Calls.Receive_Buffer (Params, Buffer'Length);
      Rose.System_Calls.Receive_Words (Params, 1);
      Rose.System_Calls.Invoke_Capability (Params);
      Last_Error := Rose.Invocation.OK;
      if Params.Control.Flags (Rose.Invocation.Error) then
         Last_Error := Params.Error;
      end if;
      Rose.System_Calls.Copy_Received_Buffer (Buffer'Length, Buffer'Address);
      Last :=
        System.Storage_Elements.Storage_Count
          (Rose.System_Calls.Get_Word_32 (Params, 0));
   end Read;

   -------------
   -- Release --
   -------------

   procedure Release (Item : Seekable_File_Reader_Client) is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      Rose.System_Calls.Initialize_Send (Params, Item.Release);
      Rose.System_Calls.Invoke_Capability (Params);
      Last_Error := Rose.Invocation.OK;
      if Params.Control.Flags (Rose.Invocation.Error) then
         Last_Error := Params.Error;
      end if;
   end Release;

   ----------
   -- Seek --
   ----------

   procedure Seek
     (Item              : Seekable_File_Reader_Client;
      Offset_From_Start : Rose.Words.Word_64)
   is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      Rose.System_Calls.Initialize_Send (Params, Item.Seek);
      Rose.System_Calls.Send_Word (Params, Offset_From_Start);
      Rose.System_Calls.Invoke_Capability (Params);
      Last_Error := Rose.Invocation.OK;
      if Params.Control.Flags (Rose.Invocation.Error) then
         Last_Error := Params.Error;
      end if;
   end Seek;

end Rose.Interfaces.Seekable_File_Reader.Client;
