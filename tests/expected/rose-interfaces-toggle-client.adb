with Rose.System_Calls;
with Rose.Words;

package body Rose.Interfaces.Toggle.Client is

   use type Rose.Words.Word_32;

   use type Rose.Invocation.Invocation_Error;

   Last_Error : Rose.Invocation.Invocation_Error := Rose.Invocation.OK;

   -----------
   -- Close --
   -----------

   procedure Close (Client : in out Toggle_Client) is
   begin
      Client.Is_Open := False;
      Rose.System_Calls.Delete_Cap (Client.Is_On);
      Rose.System_Calls.Delete_Cap (Client.Switch);
      Rose.System_Calls.Delete_Cap (Client.Interface_Cap);
   end Close;

   -----------------------
   -- Get_Interface_Cap --
   -----------------------

   function Get_Interface_Cap
     (Item : Toggle_Client)
      return Rose.Capabilities.Capability
   is (Item.Interface_Cap);

   -------------------
   -- Get_Is_On_Cap --
   -------------------

   function Get_Is_On_Cap
     (Item : Toggle_Client)
      return Rose.Capabilities.Capability
   is (Item.Is_On);

   --------------------
   -- Get_Last_Error --
   --------------------

   function Get_Last_Error
      return Rose.Invocation.Invocation_Error
   is (Last_Error);

   --------------------
   -- Get_Switch_Cap --
   --------------------

   function Get_Switch_Cap
     (Item : Toggle_Client)
      return Rose.Capabilities.Capability
   is (Item.Switch);

   ---------------
   -- Has_Error --
   ---------------

   function Has_Error return Boolean is (Last_Error /= Rose.Invocation.OK);

   -----------
   -- Is_On --
   -----------

   function Is_On (Item : Toggle_Client) return Boolean is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      Rose.System_Calls.Initialize_Send (Params, Item.Is_On);
      Rose.System_Calls.Receive_Words (Params, 1);
      Rose.System_Calls.Invoke_Capability (Params);
      Last_Error := Rose.Invocation.OK;
      if Params.Control.Flags (Rose.Invocation.Error) then
         Last_Error := Params.Error;
      end if;
      return Rose.System_Calls.Get_Word_32 (Params, 0) /= 0;
   end Is_On;

   ----------
   -- Open --
   ----------

   procedure Open
     (Client        : out Toggle_Client;
      Interface_Cap : Rose.Capabilities.Capability)
   is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      Client.Is_Open := False;
      Client.Interface_Cap := Interface_Cap;
      Rose.System_Calls.Initialize_Send (Params, Interface_Cap);
      Rose.System_Calls.Receive_Caps (Params, Subprogram_Count);
      Rose.System_Calls.Invoke_Capability (Params);
      Client.Is_On := Params.Caps (Is_On_Index);
      Client.Switch := Params.Caps (Switch_Index);
      Client.Is_Open := True;
   end Open;

   ------------------
   -- Open_Cap_Set --
   ------------------

   procedure Open_Cap_Set
     (Client : out Toggle_Client;
      Is_On  : Rose.Capabilities.Capability;
      Switch : Rose.Capabilities.Capability)
   is
   begin
      Client.Is_On := Is_On;
      Client.Switch := Switch;
      Client.Is_Open := True;
   end Open_Cap_Set;

   ------------
   -- Switch --
   ------------

   procedure Switch (Item : Toggle_Client; On : Boolean) is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      Rose.System_Calls.Initialize_Send (Params, Item.Switch);
      Rose.System_Calls.Send_Word (Params, Natural (Boolean'Pos (On)));
      Rose.System_Calls.Invoke_Capability (Params);
      Last_Error := Rose.Invocation.OK;
      if Params.Control.Flags (Rose.Invocation.Error) then
         Last_Error := Params.Error;
      end if;
   end Switch;

end Rose.Interfaces.Toggle.Client;
