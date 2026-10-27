with Rose.Interfaces.Objects;
with Rose.Invocation;
with Rose.System_Calls;

package body Rose.Interfaces.Meter.Client is

   procedure Load (Item : in out Meter_Client);

   -----------
   -- Badge --
   -----------

   overriding function Badge
     (Item : in out Meter_Client)
      return Rose.Capabilities.Capability
   is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      if not Item.Is_Open then
         Load (Item);
      end if;
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
      use type Rose.Capabilities.Capability;
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      if Client.Is_Open then
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
      end if;
      Client.Is_Open := False;
      if Client.Named_Interface_Cap /= Rose.Capabilities.Null_Capability then
         Rose.System_Calls.Initialize_Send
           (Params,
            Rose.System_Calls.Delete_Cap_Capability);
         Rose.System_Calls.Send_Cap (Params, Client.Named_Interface_Cap);
         Rose.System_Calls.Invoke_Capability (Params);
         Client.Named_Interface_Cap := Rose.Capabilities.Null_Capability;
      end if;
      if Client.Counter_Interface_Cap /= Rose.Capabilities.Null_Capability then
         Rose.System_Calls.Initialize_Send
           (Params,
            Rose.System_Calls.Delete_Cap_Capability);
         Rose.System_Calls.Send_Cap (Params, Client.Counter_Interface_Cap);
         Rose.System_Calls.Invoke_Capability (Params);
         Client.Counter_Interface_Cap := Rose.Capabilities.Null_Capability;
      end if;
      Rose.System_Calls.Initialize_Send
        (Params,
         Rose.System_Calls.Delete_Cap_Capability);
      Rose.System_Calls.Send_Cap (Params, Client.Interface_Cap);
      Rose.System_Calls.Invoke_Capability (Params);
   end Close;

   -----------------
   -- Counter_Cap --
   -----------------

   overriding function Counter_Cap
     (Item : in out Meter_Client)
      return Rose.Capabilities.Capability
   is
      use type Rose.Capabilities.Capability;
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      if Item.Counter_Interface_Cap = Rose.Capabilities.Null_Capability
        and then Item.Interface_Cap /= Rose.Capabilities.Null_Capability
      then
         Rose.System_Calls.Initialize_Send (Params, Item.Interface_Cap);
         Rose.System_Calls.Send_Word (Params, Natural (2));
         Rose.System_Calls.Receive_Caps (Params, 1);
         Rose.System_Calls.Invoke_Capability (Params);
         if Params.Control.Flags (Rose.Invocation.Error) then
            raise Rose.Interfaces.Objects.Invocation_Error
              with "Meter.Counter_Cap";
         end if;
         Item.Counter_Interface_Cap := Params.Caps (0);
      end if;
      return Item.Counter_Interface_Cap;
   end Counter_Cap;

   --------------
   -- From_Cap --
   --------------

   function From_Cap
     (Cap : Rose.Capabilities.Capability)
      return Meter_Client
   is (Meter_Client'(Interface_Cap => Cap, others => <>));

   -------------------
   -- Get_Badge_Cap --
   -------------------

   function Get_Badge_Cap
     (Item : in out Meter_Client)
      return Rose.Capabilities.Capability
   is
   begin
      if not Item.Is_Open then
         Load (Item);
      end if;
      return Item.Badge;
   end Get_Badge_Cap;

   -----------------------
   -- Get_Increment_Cap --
   -----------------------

   function Get_Increment_Cap
     (Item : in out Meter_Client)
      return Rose.Capabilities.Capability
   is
   begin
      if not Item.Is_Open then
         Load (Item);
      end if;
      return Item.Increment;
   end Get_Increment_Cap;

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
     (Item : in out Meter_Client)
      return Rose.Capabilities.Capability
   is
   begin
      if not Item.Is_Open then
         Load (Item);
      end if;
      return Item.Reset;
   end Get_Reset_Cap;

   -------------------
   -- Get_Value_Cap --
   -------------------

   function Get_Value_Cap
     (Item : in out Meter_Client)
      return Rose.Capabilities.Capability
   is
   begin
      if not Item.Is_Open then
         Load (Item);
      end if;
      return Item.Value;
   end Get_Value_Cap;

   ---------------
   -- Increment --
   ---------------

   overriding procedure Increment
     (Item : in out Meter_Client;
      By   : Rose.Words.Word)
   is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      if not Item.Is_Open then
         Load (Item);
      end if;
      Rose.System_Calls.Initialize_Send (Params, Item.Increment);
      Rose.System_Calls.Send_Word (Params, By);
      Rose.System_Calls.Invoke_Capability (Params);
      if Params.Control.Flags (Rose.Invocation.Error) then
         raise Rose.Interfaces.Objects.Invocation_Error with "Meter.Increment";
      end if;
   end Increment;

   ----------
   -- Load --
   ----------

   procedure Load (Item : in out Meter_Client) is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      Rose.System_Calls.Initialize_Send (Params, Item.Interface_Cap);
      Rose.System_Calls.Receive_Caps (Params, Subprogram_Count);
      Rose.System_Calls.Invoke_Capability (Params);
      if Params.Control.Flags (Rose.Invocation.Error) then
         raise Rose.Interfaces.Objects.Invocation_Error with "Meter.Open";
      end if;
      Item.Badge := Params.Caps (Badge_Index);
      Item.Increment := Params.Caps (Increment_Index);
      Item.Value := Params.Caps (Value_Index);
      Item.Reset := Params.Caps (Reset_Index);
      Item.Is_Open := True;
   end Load;

   ---------------
   -- Meter_Cap --
   ---------------

   overriding function Meter_Cap
     (Item : in out Meter_Client)
      return Rose.Capabilities.Capability
   is (Item.Interface_Cap);

   ---------------
   -- Named_Cap --
   ---------------

   overriding function Named_Cap
     (Item : in out Meter_Client)
      return Rose.Capabilities.Capability
   is
      use type Rose.Capabilities.Capability;
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      if Item.Named_Interface_Cap = Rose.Capabilities.Null_Capability
        and then Item.Interface_Cap /= Rose.Capabilities.Null_Capability
      then
         Rose.System_Calls.Initialize_Send (Params, Item.Interface_Cap);
         Rose.System_Calls.Send_Word (Params, Natural (1));
         Rose.System_Calls.Receive_Caps (Params, 1);
         Rose.System_Calls.Invoke_Capability (Params);
         if Params.Control.Flags (Rose.Invocation.Error) then
            raise Rose.Interfaces.Objects.Invocation_Error
              with "Meter.Named_Cap";
         end if;
         Item.Named_Interface_Cap := Params.Caps (0);
      end if;
      return Item.Named_Interface_Cap;
   end Named_Cap;

   ----------
   -- Open --
   ----------

   procedure Open
     (Client        : out Meter_Client;
      Interface_Cap : Rose.Capabilities.Capability)
   is
   begin
      Client.Is_Open := False;
      Client.Interface_Cap := Interface_Cap;
      Client.Named_Interface_Cap := Rose.Capabilities.Null_Capability;
      Client.Counter_Interface_Cap := Rose.Capabilities.Null_Capability;
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
      if not Item.Is_Open then
         Load (Item);
      end if;
      Rose.System_Calls.Initialize_Send (Params, Item.Reset);
      Rose.System_Calls.Invoke_Capability (Params);
      if Params.Control.Flags (Rose.Invocation.Error) then
         raise Rose.Interfaces.Objects.Invocation_Error with "Meter.Reset";
      end if;
   end Reset;

   -----------
   -- Value --
   -----------

   overriding function Value
     (Item : in out Meter_Client)
      return Rose.Words.Word
   is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      if not Item.Is_Open then
         Load (Item);
      end if;
      Rose.System_Calls.Initialize_Send (Params, Item.Value);
      Rose.System_Calls.Receive_Words (Params, 1);
      Rose.System_Calls.Invoke_Capability (Params);
      if Params.Control.Flags (Rose.Invocation.Error) then
         raise Rose.Interfaces.Objects.Invocation_Error with "Meter.Value";
      end if;
      return Rose.System_Calls.Get_Word_32 (Params, 0);
   end Value;

end Rose.Interfaces.Meter.Client;
