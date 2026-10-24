with Rose.System_Calls;

package body Rose.Interfaces.Cap_Set.Client is

   use type Rose.Invocation.Invocation_Error;

   Last_Error : Rose.Invocation.Invocation_Error := Rose.Invocation.OK;

   ------------
   -- Append --
   ------------

   procedure Append
     (Item : Cap_Set_Client;
      Caps : Rose.Capabilities.Capability_Array)
   is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      Rose.System_Calls.Initialize_Send (Params, Item.Append);
      for Cap of Caps loop
         Rose.System_Calls.Send_Cap (Params, Cap);
      end loop;
      Rose.System_Calls.Invoke_Capability (Params);
      Last_Error := Rose.Invocation.OK;
      if Params.Control.Flags (Rose.Invocation.Error) then
         Last_Error := Params.Error;
      end if;
   end Append;

   -----------
   -- Close --
   -----------

   procedure Close (Client : in out Cap_Set_Client) is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      Client.Is_Open := False;
      Rose.System_Calls.Initialize_Send
        (Params,
         Rose.System_Calls.Delete_Cap_Capability);
      Rose.System_Calls.Send_Cap (Params, Client.Append);
      Rose.System_Calls.Invoke_Capability (Params);
      Rose.System_Calls.Initialize_Send
        (Params,
         Rose.System_Calls.Delete_Cap_Capability);
      Rose.System_Calls.Send_Cap (Params, Client.Get_Cap);
      Rose.System_Calls.Invoke_Capability (Params);
      Rose.System_Calls.Initialize_Send
        (Params,
         Rose.System_Calls.Delete_Cap_Capability);
      Rose.System_Calls.Send_Cap (Params, Client.Length);
      Rose.System_Calls.Invoke_Capability (Params);
      Rose.System_Calls.Initialize_Send
        (Params,
         Rose.System_Calls.Delete_Cap_Capability);
      Rose.System_Calls.Send_Cap (Params, Client.Interface_Cap);
      Rose.System_Calls.Invoke_Capability (Params);
   end Close;

   --------------------
   -- Get_Append_Cap --
   --------------------

   function Get_Append_Cap
     (Item : Cap_Set_Client)
      return Rose.Capabilities.Capability
   is (Item.Append);

   -------------
   -- Get_Cap --
   -------------

   function Get_Cap
     (Item  : Cap_Set_Client;
      Index : Positive)
      return Rose.Capabilities.Capability
   is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      Rose.System_Calls.Initialize_Send (Params, Item.Get_Cap);
      Rose.System_Calls.Send_Word (Params, Index);
      Rose.System_Calls.Receive_Caps (Params, 1);
      Rose.System_Calls.Invoke_Capability (Params);
      Last_Error := Rose.Invocation.OK;
      if Params.Control.Flags (Rose.Invocation.Error) then
         Last_Error := Params.Error;
      end if;
      return Params.Caps (0);
   end Get_Cap;

   ---------------------
   -- Get_Get_Cap_Cap --
   ---------------------

   function Get_Get_Cap_Cap
     (Item : Cap_Set_Client)
      return Rose.Capabilities.Capability
   is (Item.Get_Cap);

   -----------------------
   -- Get_Interface_Cap --
   -----------------------

   function Get_Interface_Cap
     (Item : Cap_Set_Client)
      return Rose.Capabilities.Capability
   is (Item.Interface_Cap);

   --------------------
   -- Get_Last_Error --
   --------------------

   function Get_Last_Error
      return Rose.Invocation.Invocation_Error
   is (Last_Error);

   --------------------
   -- Get_Length_Cap --
   --------------------

   function Get_Length_Cap
     (Item : Cap_Set_Client)
      return Rose.Capabilities.Capability
   is (Item.Length);

   ---------------
   -- Has_Error --
   ---------------

   function Has_Error return Boolean is (Last_Error /= Rose.Invocation.OK);

   ------------
   -- Length --
   ------------

   function Length (Item : Cap_Set_Client) return Natural is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      Rose.System_Calls.Initialize_Send (Params, Item.Length);
      Rose.System_Calls.Receive_Words (Params, 1);
      Rose.System_Calls.Invoke_Capability (Params);
      Last_Error := Rose.Invocation.OK;
      if Params.Control.Flags (Rose.Invocation.Error) then
         Last_Error := Params.Error;
      end if;
      return Natural (Rose.System_Calls.Get_Word_32 (Params, 0));
   end Length;

   ----------
   -- Open --
   ----------

   procedure Open
     (Client        : out Cap_Set_Client;
      Interface_Cap : Rose.Capabilities.Capability)
   is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      Client.Is_Open := False;
      Client.Interface_Cap := Interface_Cap;
      Rose.System_Calls.Initialize_Send (Params, Interface_Cap);
      Rose.System_Calls.Receive_Caps (Params, Subprogram_Count);
      Rose.System_Calls.Invoke_Capability (Params);
      Client.Append := Params.Caps (Append_Index);
      Client.Get_Cap := Params.Caps (Get_Cap_Index);
      Client.Length := Params.Caps (Length_Index);
      Client.Is_Open := True;
   end Open;

   ------------------
   -- Open_Cap_Set --
   ------------------

   procedure Open_Cap_Set
     (Client  : out Cap_Set_Client;
      Append  : Rose.Capabilities.Capability;
      Get_Cap : Rose.Capabilities.Capability;
      Length  : Rose.Capabilities.Capability)
   is
   begin
      Client.Append := Append;
      Client.Get_Cap := Get_Cap;
      Client.Length := Length;
      Client.Is_Open := True;
   end Open_Cap_Set;

end Rose.Interfaces.Cap_Set.Client;
