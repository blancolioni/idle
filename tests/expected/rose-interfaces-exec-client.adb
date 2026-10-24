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
      Rose.System_Calls.Send_Cap (Params, Client.Install);
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
      Client.Install := Params.Caps (Install_Index);
      Client.Is_Open := True;
   end Open;

   ------------------
   -- Open_Cap_Set --
   ------------------

   procedure Open_Cap_Set
     (Client  : out Exec_Client;
      Launch  : Rose.Capabilities.Capability;
      Install : Rose.Capabilities.Capability)
   is
   begin
      Client.Launch := Launch;
      Client.Install := Install;
      Client.Is_Open := True;
   end Open_Cap_Set;

end Rose.Interfaces.Exec.Client;
