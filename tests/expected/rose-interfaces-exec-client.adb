with Rose.System_Calls;

package body Rose.Interfaces.Exec.Client is

   use type Rose.Invocation.Invocation_Error;

   Last_Error : Rose.Invocation.Invocation_Error := Rose.Invocation.OK;

   -----------
   -- Close --
   -----------

   procedure Close (Client : in out Exec_Client) is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      Client.Is_Open := False;
      Rose.System_Calls.Initialize_Send
        (Params,
         Rose.System_Calls.Delete_Cap_Capability);
      Rose.System_Calls.Send_Cap (Params, Client.Launch);
      Rose.System_Calls.Invoke_Capability (Params);
      Rose.System_Calls.Initialize_Send
        (Params,
         Rose.System_Calls.Delete_Cap_Capability);
      Rose.System_Calls.Send_Cap (Params, Client.Launch_Command);
      Rose.System_Calls.Invoke_Capability (Params);
      Rose.System_Calls.Initialize_Send
        (Params,
         Rose.System_Calls.Delete_Cap_Capability);
      Rose.System_Calls.Send_Cap (Params, Client.Metadata);
      Rose.System_Calls.Invoke_Capability (Params);
      Rose.System_Calls.Initialize_Send
        (Params,
         Rose.System_Calls.Delete_Cap_Capability);
      Rose.System_Calls.Send_Cap (Params, Client.Install);
      Rose.System_Calls.Invoke_Capability (Params);
      Rose.System_Calls.Initialize_Send
        (Params,
         Rose.System_Calls.Delete_Cap_Capability);
      Rose.System_Calls.Send_Cap (Params, Client.Set_Standard_Output);
      Rose.System_Calls.Invoke_Capability (Params);
      Rose.System_Calls.Initialize_Send
        (Params,
         Rose.System_Calls.Delete_Cap_Capability);
      Rose.System_Calls.Send_Cap (Params, Client.Interface_Cap);
      Rose.System_Calls.Invoke_Capability (Params);
   end Close;

   ---------------------
   -- Get_Install_Cap --
   ---------------------

   function Get_Install_Cap
     (Item : Exec_Client)
      return Rose.Capabilities.Capability
   is (Item.Install);

   -----------------------
   -- Get_Interface_Cap --
   -----------------------

   function Get_Interface_Cap
     (Item : Exec_Client)
      return Rose.Capabilities.Capability
   is (Item.Interface_Cap);

   --------------------
   -- Get_Last_Error --
   --------------------

   function Get_Last_Error
      return Rose.Invocation.Invocation_Error
   is (Last_Error);

   --------------------
   -- Get_Launch_Cap --
   --------------------

   function Get_Launch_Cap
     (Item : Exec_Client)
      return Rose.Capabilities.Capability
   is (Item.Launch);

   ----------------------------
   -- Get_Launch_Command_Cap --
   ----------------------------

   function Get_Launch_Command_Cap
     (Item : Exec_Client)
      return Rose.Capabilities.Capability
   is (Item.Launch_Command);

   ----------------------
   -- Get_Metadata_Cap --
   ----------------------

   function Get_Metadata_Cap
     (Item : Exec_Client)
      return Rose.Capabilities.Capability
   is (Item.Metadata);

   ---------------------------------
   -- Get_Set_Standard_Output_Cap --
   ---------------------------------

   function Get_Set_Standard_Output_Cap
     (Item : Exec_Client)
      return Rose.Capabilities.Capability
   is (Item.Set_Standard_Output);

   ---------------
   -- Has_Error --
   ---------------

   function Has_Error return Boolean is (Last_Error /= Rose.Invocation.OK);

   -------------
   -- Install --
   -------------

   function Install
     (Item         : Exec_Client;
      Executable   : Rose.Interfaces.Stream_Reader.Client.Stream_Reader_Client;
      Name         : String;
      Install_Caps : Rose.Capabilities.Capability_Array)
      return Rose.Interfaces.Launch.Client.Launch_Client
   is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      Rose.System_Calls.Initialize_Send (Params, Item.Install);
      Rose.System_Calls.Send_Cap
        (Params,
         Rose.Interfaces.Stream_Reader.Client.Get_Interface_Cap (Executable));
      Rose.System_Calls.Send_Text (Params, Name);
      for Cap of Install_Caps loop
         Rose.System_Calls.Send_Cap (Params, Cap);
      end loop;
      Rose.System_Calls.Receive_Caps (Params, 1);
      Rose.System_Calls.Invoke_Capability (Params);
      Last_Error := Rose.Invocation.OK;
      if Params.Control.Flags (Rose.Invocation.Error) then
         Last_Error := Params.Error;
      end if;
      declare
         Result : Rose.Interfaces.Launch.Client.Launch_Client;
      begin
         Rose.Interfaces.Launch.Client.Open (Result, Params.Caps (0));
         return Result;
      end;
   end Install;

   ------------
   -- Launch --
   ------------

   function Launch
     (Item        : Exec_Client;
      Caps        : Rose.Capabilities.Capability_Array;
      Environment : System.Storage_Elements.Storage_Array)
      return Rose.Interfaces.Process.Client.Process_Client
   is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      Rose.System_Calls.Initialize_Send (Params, Item.Launch);
      for Cap of Caps loop
         Rose.System_Calls.Send_Cap (Params, Cap);
      end loop;
      Rose.System_Calls.Send_Storage_Array (Params, Environment, False);
      Rose.System_Calls.Receive_Caps (Params, 1);
      Rose.System_Calls.Invoke_Capability (Params);
      Last_Error := Rose.Invocation.OK;
      if Params.Control.Flags (Rose.Invocation.Error) then
         Last_Error := Params.Error;
      end if;
      declare
         Result : Rose.Interfaces.Process.Client.Process_Client;
      begin
         Rose.Interfaces.Process.Client.Open (Result, Params.Caps (0));
         return Result;
      end;
   end Launch;

   --------------------
   -- Launch_Command --
   --------------------

   function Launch_Command
     (Item : Exec_Client;
      Caps : Rose.Capabilities.Capability_Array)
      return Rose.Capabilities.Capability
   is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      Rose.System_Calls.Initialize_Send (Params, Item.Launch_Command);
      for Cap of Caps loop
         Rose.System_Calls.Send_Cap (Params, Cap);
      end loop;
      Rose.System_Calls.Receive_Caps (Params, 1);
      Rose.System_Calls.Invoke_Capability (Params);
      Last_Error := Rose.Invocation.OK;
      if Params.Control.Flags (Rose.Invocation.Error) then
         Last_Error := Params.Error;
      end if;
      return Params.Caps (0);
   end Launch_Command;

   --------------
   -- Metadata --
   --------------

   procedure Metadata
     (Item   : Exec_Client;
      Result : out String;
      Last   : out Natural)
   is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      Rose.System_Calls.Initialize_Send (Params, Item.Metadata);
      Rose.System_Calls.Receive_Words (Params, 1);
      Rose.System_Calls.Receive_Buffer (Params);
      Rose.System_Calls.Invoke_Capability (Params);
      Last_Error := Rose.Invocation.OK;
      if Params.Control.Flags (Rose.Invocation.Error) then
         Last_Error := Params.Error;
      end if;
      Rose.System_Calls.Copy_Text
        (Params,
         Natural (Rose.System_Calls.Get_Word_32 (Params, 0)),
         Result,
         Last);
   end Metadata;

   ----------
   -- Open --
   ----------

   procedure Open
     (Client        : out Exec_Client;
      Interface_Cap : Rose.Capabilities.Capability)
   is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      Client.Is_Open := False;
      Client.Interface_Cap := Interface_Cap;
      Rose.System_Calls.Initialize_Send (Params, Interface_Cap);
      Rose.System_Calls.Receive_Caps (Params, Subprogram_Count);
      Rose.System_Calls.Invoke_Capability (Params);
      Client.Launch := Params.Caps (Launch_Index);
      Client.Launch_Command := Params.Caps (Launch_Command_Index);
      Client.Metadata := Params.Caps (Metadata_Index);
      Client.Install := Params.Caps (Install_Index);
      Client.Set_Standard_Output := Params.Caps (Set_Standard_Output_Index);
      Client.Is_Open := True;
   end Open;

   ------------------
   -- Open_Cap_Set --
   ------------------

   procedure Open_Cap_Set
     (Client              : out Exec_Client;
      Launch              : Rose.Capabilities.Capability;
      Launch_Command      : Rose.Capabilities.Capability;
      Metadata            : Rose.Capabilities.Capability;
      Install             : Rose.Capabilities.Capability;
      Set_Standard_Output : Rose.Capabilities.Capability)
   is
   begin
      Client.Launch := Launch;
      Client.Launch_Command := Launch_Command;
      Client.Metadata := Metadata;
      Client.Install := Install;
      Client.Set_Standard_Output := Set_Standard_Output;
      Client.Is_Open := True;
   end Open_Cap_Set;

   -------------------------
   -- Set_Standard_Output --
   -------------------------

   procedure Set_Standard_Output
     (Item   : Exec_Client;
      Output : Rose.Interfaces.Stream_Writer.Client.Stream_Writer_Client)
   is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      Rose.System_Calls.Initialize_Send (Params, Item.Set_Standard_Output);
      Rose.System_Calls.Send_Cap
        (Params,
         Rose.Interfaces.Stream_Writer.Client.Get_Interface_Cap (Output));
      Rose.System_Calls.Invoke_Capability (Params);
      Last_Error := Rose.Invocation.OK;
      if Params.Control.Flags (Rose.Invocation.Error) then
         Last_Error := Params.Error;
      end if;
   end Set_Standard_Output;

end Rose.Interfaces.Exec.Client;
