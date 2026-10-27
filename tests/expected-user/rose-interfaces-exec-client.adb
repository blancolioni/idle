with Rose.Interfaces.Launch.Client;
with Rose.Interfaces.Objects;
with Rose.Interfaces.Process.Client;
with Rose.Invocation;
with Rose.System_Calls;

package body Rose.Interfaces.Exec.Client is

   procedure Load (Item : in out Exec_Client);

   -----------
   -- Close --
   -----------

   procedure Close (Client : in out Exec_Client) is
      use type Rose.Capabilities.Capability;
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      if Client.Is_Open then
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
      end if;
      Client.Is_Open := False;
      if Client.Launch_Interface_Cap /= Rose.Capabilities.Null_Capability then
         Rose.System_Calls.Initialize_Send
           (Params,
            Rose.System_Calls.Delete_Cap_Capability);
         Rose.System_Calls.Send_Cap (Params, Client.Launch_Interface_Cap);
         Rose.System_Calls.Invoke_Capability (Params);
         Client.Launch_Interface_Cap := Rose.Capabilities.Null_Capability;
      end if;
      Rose.System_Calls.Initialize_Send
        (Params,
         Rose.System_Calls.Delete_Cap_Capability);
      Rose.System_Calls.Send_Cap (Params, Client.Interface_Cap);
      Rose.System_Calls.Invoke_Capability (Params);
   end Close;

   --------------
   -- Exec_Cap --
   --------------

   overriding function Exec_Cap
     (Item : in out Exec_Client)
      return Rose.Capabilities.Capability
   is (Item.Interface_Cap);

   --------------
   -- From_Cap --
   --------------

   function From_Cap
     (Cap : Rose.Capabilities.Capability)
      return Exec_Client
   is (Exec_Client'(Interface_Cap => Cap, others => <>));

   ---------------------
   -- Get_Install_Cap --
   ---------------------

   function Get_Install_Cap
     (Item : in out Exec_Client)
      return Rose.Capabilities.Capability
   is
   begin
      if not Item.Is_Open then
         Load (Item);
      end if;
      return Item.Install;
   end Get_Install_Cap;

   -----------------------
   -- Get_Interface_Cap --
   -----------------------

   function Get_Interface_Cap
     (Item : Exec_Client)
      return Rose.Capabilities.Capability
   is (Item.Interface_Cap);

   --------------------
   -- Get_Launch_Cap --
   --------------------

   function Get_Launch_Cap
     (Item : in out Exec_Client)
      return Rose.Capabilities.Capability
   is
   begin
      if not Item.Is_Open then
         Load (Item);
      end if;
      return Item.Launch;
   end Get_Launch_Cap;

   -------------
   -- Install --
   -------------

   overriding function Install
     (Item         : in out Exec_Client;
      Executable   : in out
        Rose.Interfaces.Stream_Reader.Stream_Reader_Object'Class;
      Name         : String;
      Install_Caps : Rose.Capabilities.Capability_Array)
      return Rose.Interfaces.Launch.Launch_Object'Class
   is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      if not Item.Is_Open then
         Load (Item);
      end if;
      Rose.System_Calls.Initialize_Send (Params, Item.Install);
      Rose.System_Calls.Send_Cap (Params, Executable.Stream_Reader_Cap);
      Rose.System_Calls.Send_Text (Params, Name);
      for Cap of Install_Caps loop
         Rose.System_Calls.Send_Cap (Params, Cap);
      end loop;
      Rose.System_Calls.Receive_Caps (Params, 1);
      Rose.System_Calls.Invoke_Capability (Params);
      if Params.Control.Flags (Rose.Invocation.Error) then
         raise Rose.Interfaces.Objects.Invocation_Error with "Exec.Install";
      end if;
      return Rose.Interfaces.Launch.Client.From_Cap (Params.Caps (0));
   end Install;

   ------------
   -- Launch --
   ------------

   overriding function Launch
     (Item        : in out Exec_Client;
      Caps        : Rose.Capabilities.Capability_Array;
      Environment : System.Storage_Elements.Storage_Array)
      return Rose.Interfaces.Process.Process_Object'Class
   is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      if not Item.Is_Open then
         Load (Item);
      end if;
      Rose.System_Calls.Initialize_Send (Params, Item.Launch);
      for Cap of Caps loop
         Rose.System_Calls.Send_Cap (Params, Cap);
      end loop;
      Rose.System_Calls.Send_Storage_Array (Params, Environment, False);
      Rose.System_Calls.Receive_Caps (Params, 1);
      Rose.System_Calls.Invoke_Capability (Params);
      if Params.Control.Flags (Rose.Invocation.Error) then
         raise Rose.Interfaces.Objects.Invocation_Error with "Exec.Launch";
      end if;
      return Rose.Interfaces.Process.Client.From_Cap (Params.Caps (0));
   end Launch;

   ----------------
   -- Launch_Cap --
   ----------------

   overriding function Launch_Cap
     (Item : in out Exec_Client)
      return Rose.Capabilities.Capability
   is
      use type Rose.Capabilities.Capability;
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      if Item.Launch_Interface_Cap = Rose.Capabilities.Null_Capability
        and then Item.Interface_Cap /= Rose.Capabilities.Null_Capability
      then
         Rose.System_Calls.Initialize_Send (Params, Item.Interface_Cap);
         Rose.System_Calls.Send_Word (Params, Natural (1));
         Rose.System_Calls.Receive_Caps (Params, 1);
         Rose.System_Calls.Invoke_Capability (Params);
         if Params.Control.Flags (Rose.Invocation.Error) then
            raise Rose.Interfaces.Objects.Invocation_Error
              with "Exec.Launch_Cap";
         end if;
         Item.Launch_Interface_Cap := Params.Caps (0);
      end if;
      return Item.Launch_Interface_Cap;
   end Launch_Cap;

   ----------
   -- Load --
   ----------

   procedure Load (Item : in out Exec_Client) is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      Rose.System_Calls.Initialize_Send (Params, Item.Interface_Cap);
      Rose.System_Calls.Receive_Caps (Params, Subprogram_Count);
      Rose.System_Calls.Invoke_Capability (Params);
      if Params.Control.Flags (Rose.Invocation.Error) then
         raise Rose.Interfaces.Objects.Invocation_Error with "Exec.Open";
      end if;
      Item.Launch := Params.Caps (Launch_Index);
      Item.Install := Params.Caps (Install_Index);
      Item.Is_Open := True;
   end Load;

   ----------
   -- Open --
   ----------

   procedure Open
     (Client        : out Exec_Client;
      Interface_Cap : Rose.Capabilities.Capability)
   is
   begin
      Client.Is_Open := False;
      Client.Interface_Cap := Interface_Cap;
      Client.Launch_Interface_Cap := Rose.Capabilities.Null_Capability;
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
