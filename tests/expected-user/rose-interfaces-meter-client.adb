with Rose.Interfaces.Objects;
with Rose.Invocation;
with Rose.System_Calls;

package body Rose.Interfaces.Meter.Client is

   -----------
   -- Badge --
   -----------

   overriding function Badge
     (Item : Meter_Client)
      return Rose.Capabilities.Capability
   is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      Rose.System_Calls.Initialize_Send (Params, Item.Badge);
      Rose.System_Calls.Receive_Caps (Params, 1);
      Rose.System_Calls.Invoke_Capability (Params);
      if Params.Control.Flags (Rose.Invocation.Error) then
         raise Rose.Interfaces.Objects.Invocation_Error with "Meter.Badge";
      end if;
      return Params.Caps (0);
   end Badge;

   -----------
   -- Close --
   -----------

   procedure Close (Client : in out Meter_Client) is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      Client.Is_Open := False;
      Rose.System_Calls.Initialize_Send
        (Params,
         Rose.System_Calls.Delete_Cap_Capability);
      Rose.System_Calls.Send_Cap (Params, Client.Badge);
      Rose.System_Calls.Invoke_Capability (Params);
      Rose.System_Calls.Initialize_Send
        (Params,
         Rose.System_Calls.Delete_Cap_Capability);
      Rose.System_Calls.Send_Cap (Params, Client.Increment);
      Rose.System_Calls.Invoke_Capability (Params);
      Rose.System_Calls.Initialize_Send
        (Params,
         Rose.System_Calls.Delete_Cap_Capability);
      Rose.System_Calls.Send_Cap (Params, Client.Value);
      Rose.System_Calls.Invoke_Capability (Params);
      Rose.System_Calls.Initialize_Send
        (Params,
         Rose.System_Calls.Delete_Cap_Capability);
      Rose.System_Calls.Send_Cap (Params, Client.Reset);
      Rose.System_Calls.Invoke_Capability (Params);
      Rose.System_Calls.Initialize_Send
        (Params,
         Rose.System_Calls.Delete_Cap_Capability);
      Rose.System_Calls.Send_Cap (Params, Client.Interface_Cap);
      Rose.System_Calls.Invoke_Capability (Params);
   end Close;

   -------------------
   -- Get_Badge_Cap --
   -------------------

   function Get_Badge_Cap
     (Item : Meter_Client)
      return Rose.Capabilities.Capability
   is (Item.Badge);

   -----------------------
   -- Get_Increment_Cap --
   -----------------------

   function Get_Increment_Cap
     (Item : Meter_Client)
      return Rose.Capabilities.Capability
   is (Item.Increment);

   -----------------------
   -- Get_Interface_Cap --
   -----------------------

   function Get_Interface_Cap
     (Item : Meter_Client)
      return Rose.Capabilities.Capability
   is (Item.Interface_Cap);

   -------------------
   -- Get_Reset_Cap --
   -------------------

   function Get_Reset_Cap
     (Item : Meter_Client)
      return Rose.Capabilities.Capability
   is (Item.Reset);

   -------------------
   -- Get_Value_Cap --
   -------------------

   function Get_Value_Cap
     (Item : Meter_Client)
      return Rose.Capabilities.Capability
   is (Item.Value);

   ---------------
   -- Increment --
   ---------------

   overriding procedure Increment
     (Item : in out Meter_Client;
      By   : Rose.Words.Word)
   is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      Rose.System_Calls.Initialize_Send (Params, Item.Increment);
      Rose.System_Calls.Send_Word (Params, By);
      Rose.System_Calls.Invoke_Capability (Params);
      if Params.Control.Flags (Rose.Invocation.Error) then
         raise Rose.Interfaces.Objects.Invocation_Error with "Meter.Increment";
      end if;
   end Increment;

   ----------
   -- Open --
   ----------

   procedure Open
     (Client        : out Meter_Client;
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
      Client.Reset := Params.Caps (Reset_Index);
      Client.Is_Open := True;
   end Open;

   ------------------
   -- Open_Cap_Set --
   ------------------

   procedure Open_Cap_Set
     (Client    : out Meter_Client;
      Badge     : Rose.Capabilities.Capability;
      Increment : Rose.Capabilities.Capability;
      Value     : Rose.Capabilities.Capability;
      Reset     : Rose.Capabilities.Capability)
   is
   begin
      Client.Badge := Badge;
      Client.Increment := Increment;
      Client.Value := Value;
      Client.Reset := Reset;
      Client.Is_Open := True;
   end Open_Cap_Set;

   -----------
   -- Reset --
   -----------

   overriding procedure Reset (Item : in out Meter_Client) is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      Rose.System_Calls.Initialize_Send (Params, Item.Reset);
      Rose.System_Calls.Invoke_Capability (Params);
      if Params.Control.Flags (Rose.Invocation.Error) then
         raise Rose.Interfaces.Objects.Invocation_Error with "Meter.Reset";
      end if;
   end Reset;

   -----------
   -- Value --
   -----------

   overriding function Value (Item : Meter_Client) return Rose.Words.Word is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      Rose.System_Calls.Initialize_Send (Params, Item.Value);
      Rose.System_Calls.Receive_Words (Params, 1);
      Rose.System_Calls.Invoke_Capability (Params);
      if Params.Control.Flags (Rose.Invocation.Error) then
         raise Rose.Interfaces.Objects.Invocation_Error with "Meter.Value";
      end if;
      return Rose.System_Calls.Get_Word_32 (Params, 0);
   end Value;

end Rose.Interfaces.Meter.Client;
