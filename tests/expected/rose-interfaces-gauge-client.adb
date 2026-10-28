with Rose.System_Calls;

package body Rose.Interfaces.Gauge.Client is

   use type Rose.Invocation.Invocation_Error;

   Last_Error : Rose.Invocation.Invocation_Error := Rose.Invocation.OK;

   -----------
   -- Badge --
   -----------

   function Badge (Item : Gauge_Client) return Rose.Capabilities.Capability is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      Rose.System_Calls.Initialize_Send (Params, Item.Badge);
      Rose.System_Calls.Receive_Caps (Params, 1);
      Rose.System_Calls.Invoke_Capability (Params);
      Last_Error := Rose.Invocation.OK;
      if Params.Control.Flags (Rose.Invocation.Error) then
         Last_Error := Params.Error;
      end if;
      return Params.Caps (0);
   end Badge;

   -----------
   -- Close --
   -----------

   procedure Close (Client : in out Gauge_Client) is
   begin
      Client.Is_Open := False;
      Rose.System_Calls.Delete_Cap (Client.Badge);
      Rose.System_Calls.Delete_Cap (Client.Increment);
      Rose.System_Calls.Delete_Cap (Client.Value);
      Rose.System_Calls.Delete_Cap (Client.Set_Label);
      Rose.System_Calls.Delete_Cap (Client.Reset);
      Rose.System_Calls.Delete_Cap (Client.Interface_Cap);
   end Close;

   -------------------
   -- Get_Badge_Cap --
   -------------------

   function Get_Badge_Cap
     (Item : Gauge_Client)
      return Rose.Capabilities.Capability
   is (Item.Badge);

   -----------------------
   -- Get_Increment_Cap --
   -----------------------

   function Get_Increment_Cap
     (Item : Gauge_Client)
      return Rose.Capabilities.Capability
   is (Item.Increment);

   -----------------------
   -- Get_Interface_Cap --
   -----------------------

   function Get_Interface_Cap
     (Item : Gauge_Client)
      return Rose.Capabilities.Capability
   is (Item.Interface_Cap);

   --------------------
   -- Get_Last_Error --
   --------------------

   function Get_Last_Error
      return Rose.Invocation.Invocation_Error
   is (Last_Error);

   -------------------
   -- Get_Reset_Cap --
   -------------------

   function Get_Reset_Cap
     (Item : Gauge_Client)
      return Rose.Capabilities.Capability
   is (Item.Reset);

   -----------------------
   -- Get_Set_Label_Cap --
   -----------------------

   function Get_Set_Label_Cap
     (Item : Gauge_Client)
      return Rose.Capabilities.Capability
   is (Item.Set_Label);

   -------------------
   -- Get_Value_Cap --
   -------------------

   function Get_Value_Cap
     (Item : Gauge_Client)
      return Rose.Capabilities.Capability
   is (Item.Value);

   ---------------
   -- Has_Error --
   ---------------

   function Has_Error return Boolean is (Last_Error /= Rose.Invocation.OK);

   ---------------
   -- Increment --
   ---------------

   procedure Increment (Item : Gauge_Client; By : Rose.Words.Word) is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      Rose.System_Calls.Initialize_Send (Params, Item.Increment);
      Rose.System_Calls.Send_Word (Params, By);
      Rose.System_Calls.Invoke_Capability (Params);
      Last_Error := Rose.Invocation.OK;
      if Params.Control.Flags (Rose.Invocation.Error) then
         Last_Error := Params.Error;
      end if;
   end Increment;

   ----------
   -- Open --
   ----------

   procedure Open
     (Client        : out Gauge_Client;
      Interface_Cap : Rose.Capabilities.Capability)
   is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      Client.Is_Open := False;
      Client.Interface_Cap := Interface_Cap;
      Rose.System_Calls.Initialize_Send (Params, Interface_Cap);
      Rose.System_Calls.Receive_Caps (Params, Subprogram_Count);
      Rose.System_Calls.Invoke_Capability (Params);
      Client.Badge := Params.Caps (Badge_Index);
      Client.Increment := Params.Caps (Increment_Index);
      Client.Value := Params.Caps (Value_Index);
      Client.Set_Label := Params.Caps (Set_Label_Index);
      Client.Reset := Params.Caps (Reset_Index);
      Client.Is_Open := True;
   end Open;

   ------------------
   -- Open_Cap_Set --
   ------------------

   procedure Open_Cap_Set
     (Client    : out Gauge_Client;
      Badge     : Rose.Capabilities.Capability;
      Increment : Rose.Capabilities.Capability;
      Value     : Rose.Capabilities.Capability;
      Set_Label : Rose.Capabilities.Capability;
      Reset     : Rose.Capabilities.Capability)
   is
   begin
      Client.Badge := Badge;
      Client.Increment := Increment;
      Client.Value := Value;
      Client.Set_Label := Set_Label;
      Client.Reset := Reset;
      Client.Is_Open := True;
   end Open_Cap_Set;

   -----------
   -- Reset --
   -----------

   procedure Reset (Item : Gauge_Client) is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      Rose.System_Calls.Initialize_Send (Params, Item.Reset);
      Rose.System_Calls.Invoke_Capability (Params);
      Last_Error := Rose.Invocation.OK;
      if Params.Control.Flags (Rose.Invocation.Error) then
         Last_Error := Params.Error;
      end if;
   end Reset;

   ---------------
   -- Set_Label --
   ---------------

   procedure Set_Label (Item : Gauge_Client; Label : Rose.Words.Word) is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      Rose.System_Calls.Initialize_Send (Params, Item.Set_Label);
      Rose.System_Calls.Send_Word (Params, Label);
      Rose.System_Calls.Invoke_Capability (Params);
      Last_Error := Rose.Invocation.OK;
      if Params.Control.Flags (Rose.Invocation.Error) then
         Last_Error := Params.Error;
      end if;
   end Set_Label;

   -----------
   -- Value --
   -----------

   function Value (Item : Gauge_Client) return Rose.Words.Word is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      Rose.System_Calls.Initialize_Send (Params, Item.Value);
      Rose.System_Calls.Receive_Words (Params, 1);
      Rose.System_Calls.Invoke_Capability (Params);
      Last_Error := Rose.Invocation.OK;
      if Params.Control.Flags (Rose.Invocation.Error) then
         Last_Error := Params.Error;
      end if;
      return Rose.System_Calls.Get_Word_32 (Params, 0);
   end Value;

end Rose.Interfaces.Gauge.Client;
