with Rose.System_Calls;

package body Rose.Interfaces.Memory.Client is

   use type Rose.Invocation.Invocation_Error;

   Last_Error : Rose.Invocation.Invocation_Error := Rose.Invocation.OK;

   ----------------
   -- Checkpoint --
   ----------------

   procedure Checkpoint
     (Item        : Memory_Client;
      Append_Page : Rose.Capabilities.Capability)
   is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      Rose.System_Calls.Initialize_Send (Params, Item.Checkpoint);
      Rose.System_Calls.Send_Cap (Params, Append_Page);
      Rose.System_Calls.Invoke_Capability (Params);
      Last_Error := Rose.Invocation.OK;
      if Params.Control.Flags (Rose.Invocation.Error) then
         Last_Error := Params.Error;
      end if;
   end Checkpoint;

   -----------
   -- Close --
   -----------

   procedure Close (Client : in out Memory_Client) is
   begin
      Client.Is_Open := False;
      Rose.System_Calls.Delete_Cap (Client.New_Process);
      Rose.System_Calls.Delete_Cap (Client.Register_Process);
      Rose.System_Calls.Delete_Cap (Client.Page_Fault);
      Rose.System_Calls.Delete_Cap (Client.Take_Physical_Memory);
      Rose.System_Calls.Delete_Cap (Client.Checkpoint);
      Rose.System_Calls.Delete_Cap (Client.Interface_Cap);
   end Close;

   ------------------------
   -- Get_Checkpoint_Cap --
   ------------------------

   function Get_Checkpoint_Cap
     (Item : Memory_Client)
      return Rose.Capabilities.Capability
   is (Item.Checkpoint);

   -----------------------
   -- Get_Interface_Cap --
   -----------------------

   function Get_Interface_Cap
     (Item : Memory_Client)
      return Rose.Capabilities.Capability
   is (Item.Interface_Cap);

   --------------------
   -- Get_Last_Error --
   --------------------

   function Get_Last_Error
      return Rose.Invocation.Invocation_Error
   is (Last_Error);

   -------------------------
   -- Get_New_Process_Cap --
   -------------------------

   function Get_New_Process_Cap
     (Item : Memory_Client)
      return Rose.Capabilities.Capability
   is (Item.New_Process);

   ------------------------
   -- Get_Page_Fault_Cap --
   ------------------------

   function Get_Page_Fault_Cap
     (Item : Memory_Client)
      return Rose.Capabilities.Capability
   is (Item.Page_Fault);

   ------------------------------
   -- Get_Register_Process_Cap --
   ------------------------------

   function Get_Register_Process_Cap
     (Item : Memory_Client)
      return Rose.Capabilities.Capability
   is (Item.Register_Process);

   ----------------------------------
   -- Get_Take_Physical_Memory_Cap --
   ----------------------------------

   function Get_Take_Physical_Memory_Cap
     (Item : Memory_Client)
      return Rose.Capabilities.Capability
   is (Item.Take_Physical_Memory);

   ---------------
   -- Has_Error --
   ---------------

   function Has_Error return Boolean is (Last_Error /= Rose.Invocation.OK);

   -----------------
   -- New_Process --
   -----------------

   function New_Process
     (Item    : Memory_Client;
      Process : Rose.Interfaces.Kernel_Process.Client.Kernel_Process_Client)
      return Rose.Interfaces.Process.Client.Process_Client
   is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      Rose.System_Calls.Initialize_Send (Params, Item.New_Process);
      Rose.System_Calls.Send_Cap
        (Params,
         Rose.Interfaces.Kernel_Process.Client.Get_Interface_Cap (Process));
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
   end New_Process;

   ----------
   -- Open --
   ----------

   procedure Open
     (Client        : out Memory_Client;
      Interface_Cap : Rose.Capabilities.Capability)
   is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      Client.Is_Open := False;
      Client.Interface_Cap := Interface_Cap;
      Rose.System_Calls.Initialize_Send (Params, Interface_Cap);
      Rose.System_Calls.Receive_Caps (Params, Subprogram_Count);
      Rose.System_Calls.Invoke_Capability (Params);
      Client.New_Process := Params.Caps (New_Process_Index);
      Client.Register_Process := Params.Caps (Register_Process_Index);
      Client.Page_Fault := Params.Caps (Page_Fault_Index);
      Client.Take_Physical_Memory := Params.Caps (Take_Physical_Memory_Index);
      Client.Checkpoint := Params.Caps (Checkpoint_Index);
      Client.Is_Open := True;
   end Open;

   ------------------
   -- Open_Cap_Set --
   ------------------

   procedure Open_Cap_Set
     (Client               : out Memory_Client;
      New_Process          : Rose.Capabilities.Capability;
      Register_Process     : Rose.Capabilities.Capability;
      Page_Fault           : Rose.Capabilities.Capability;
      Take_Physical_Memory : Rose.Capabilities.Capability;
      Checkpoint           : Rose.Capabilities.Capability)
   is
   begin
      Client.New_Process := New_Process;
      Client.Register_Process := Register_Process;
      Client.Page_Fault := Page_Fault;
      Client.Take_Physical_Memory := Take_Physical_Memory;
      Client.Checkpoint := Checkpoint;
      Client.Is_Open := True;
   end Open_Cap_Set;

   ----------------
   -- Page_Fault --
   ----------------

   procedure Page_Fault
     (Item            : Memory_Client;
      Faulting_Object : Rose.Objects.Object_Id;
      Virtual_Page    : Rose.Words.Word;
      Physical_Page   : Rose.Words.Word;
      Action          : Rose.Interfaces.Memory.Page_Access_Type)
   is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      Rose.System_Calls.Initialize_Send (Params, Item.Page_Fault);
      Rose.System_Calls.Send_Object_Id (Params, Faulting_Object);
      Rose.System_Calls.Send_Word (Params, Virtual_Page);
      Rose.System_Calls.Send_Word (Params, Physical_Page);
      Rose.System_Calls.Send_Word
        (Params,
         Natural (Rose.Interfaces.Memory.Page_Access_Type'Pos (Action)));
      Rose.System_Calls.Invoke_Capability (Params);
      Last_Error := Rose.Invocation.OK;
      if Params.Control.Flags (Rose.Invocation.Error) then
         Last_Error := Params.Error;
      end if;
   end Page_Fault;

   ----------------------
   -- Register_Process --
   ----------------------

   procedure Register_Process
     (Item        : Memory_Client;
      Process     : Rose.Interfaces.Process.Client.Process_Client;
      Exec_Base   : Rose.Words.Word;
      Exec_Bound  : Rose.Words.Word;
      Text_Base   : Rose.Words.Word;
      Text_Bound  : Rose.Words.Word;
      Data_Base   : Rose.Words.Word;
      Data_Bound  : Rose.Words.Word;
      Stack_Base  : Rose.Words.Word;
      Stack_Bound : Rose.Words.Word;
      Environment : System.Storage_Elements.Storage_Array)
   is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      Rose.System_Calls.Initialize_Send (Params, Item.Register_Process);
      Rose.System_Calls.Send_Cap
        (Params,
         Rose.Interfaces.Process.Client.Get_Interface_Cap (Process));
      Rose.System_Calls.Send_Word (Params, Exec_Base);
      Rose.System_Calls.Send_Word (Params, Exec_Bound);
      Rose.System_Calls.Send_Word (Params, Text_Base);
      Rose.System_Calls.Send_Word (Params, Text_Bound);
      Rose.System_Calls.Send_Word (Params, Data_Base);
      Rose.System_Calls.Send_Word (Params, Data_Bound);
      Rose.System_Calls.Send_Word (Params, Stack_Base);
      Rose.System_Calls.Send_Word (Params, Stack_Bound);
      Rose.System_Calls.Send_Storage_Array (Params, Environment, False);
      Rose.System_Calls.Invoke_Capability (Params);
      Last_Error := Rose.Invocation.OK;
      if Params.Control.Flags (Rose.Invocation.Error) then
         Last_Error := Params.Error;
      end if;
   end Register_Process;

   --------------------------
   -- Take_Physical_Memory --
   --------------------------

   procedure Take_Physical_Memory
     (Item   : Memory_Client;
      Size   : Rose.Words.Word;
      Start  : out Rose.Words.Word;
      Amount : out Rose.Words.Word)
   is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      Rose.System_Calls.Initialize_Send (Params, Item.Take_Physical_Memory);
      Rose.System_Calls.Send_Word (Params, Size);
      Rose.System_Calls.Receive_Words (Params, 2);
      Rose.System_Calls.Invoke_Capability (Params);
      Last_Error := Rose.Invocation.OK;
      if Params.Control.Flags (Rose.Invocation.Error) then
         Last_Error := Params.Error;
      end if;
      Start := Rose.System_Calls.Get_Word_32 (Params, 0);
      Amount := Rose.System_Calls.Get_Word_32 (Params, 1);
   end Take_Physical_Memory;

end Rose.Interfaces.Memory.Client;
