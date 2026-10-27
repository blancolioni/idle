with Rose.Interfaces.Objects;
with Rose.Invocation;
with Rose.System_Calls;

package body Rose.Interfaces.Gauge.Client is

   procedure Load (Item : in out Gauge_Client);

   -----------
   -- Badge --
   -----------

   overriding function Badge
     (Item : in out Gauge_Client)
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
         raise Rose.Interfaces.Objects.Invocation_Error with "Gauge.Badge";
      end if;
      return Params.Caps (0);
   end Badge;

   -----------
   -- Close --
   -----------

   procedure Close (Client : in out Gauge_Client) is
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
         Rose.System_Calls.Send_Cap (Params, Client.Set_Label);
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
      if Client.Labelled_Interface_Cap /= Rose.Capabilities.Null_Capability
      then
         Rose.System_Calls.Initialize_Send
           (Params,
            Rose.System_Calls.Delete_Cap_Capability);
         Rose.System_Calls.Send_Cap (Params, Client.Labelled_Interface_Cap);
         Rose.System_Calls.Invoke_Capability (Params);
         Client.Labelled_Interface_Cap := Rose.Capabilities.Null_Capability;
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
     (Item : in out Gauge_Client)
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
              with "Gauge.Counter_Cap";
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
      return Gauge_Client
   is (Gauge_Client'(Interface_Cap => Cap, others => <>));

   ---------------
   -- Gauge_Cap --
   ---------------

   overriding function Gauge_Cap
     (Item : in out Gauge_Client)
      return Rose.Capabilities.Capability
   is (Item.Interface_Cap);

   -------------------
   -- Get_Badge_Cap --
   -------------------

   function Get_Badge_Cap
     (Item : in out Gauge_Client)
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
     (Item : in out Gauge_Client)
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
     (Item : Gauge_Client)
      return Rose.Capabilities.Capability
   is (Item.Interface_Cap);

   -------------------
   -- Get_Reset_Cap --
   -------------------

   function Get_Reset_Cap
     (Item : in out Gauge_Client)
      return Rose.Capabilities.Capability
   is
   begin
      if not Item.Is_Open then
         Load (Item);
      end if;
      return Item.Reset;
   end Get_Reset_Cap;

   -----------------------
   -- Get_Set_Label_Cap --
   -----------------------

   function Get_Set_Label_Cap
     (Item : in out Gauge_Client)
      return Rose.Capabilities.Capability
   is
   begin
      if not Item.Is_Open then
         Load (Item);
      end if;
      return Item.Set_Label;
   end Get_Set_Label_Cap;

   -------------------
   -- Get_Value_Cap --
   -------------------

   function Get_Value_Cap
     (Item : in out Gauge_Client)
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
     (Item : in out Gauge_Client;
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
         raise Rose.Interfaces.Objects.Invocation_Error with "Gauge.Increment";
      end if;
   end Increment;

   ------------------
   -- Labelled_Cap --
   ------------------

   overriding function Labelled_Cap
     (Item : in out Gauge_Client)
      return Rose.Capabilities.Capability
   is
      use type Rose.Capabilities.Capability;
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      if Item.Labelled_Interface_Cap = Rose.Capabilities.Null_Capability
        and then Item.Interface_Cap /= Rose.Capabilities.Null_Capability
      then
         Rose.System_Calls.Initialize_Send (Params, Item.Interface_Cap);
         Rose.System_Calls.Send_Word (Params, Natural (3));
         Rose.System_Calls.Receive_Caps (Params, 1);
         Rose.System_Calls.Invoke_Capability (Params);
         if Params.Control.Flags (Rose.Invocation.Error) then
            raise Rose.Interfaces.Objects.Invocation_Error
              with "Gauge.Labelled_Cap";
         end if;
         Item.Labelled_Interface_Cap := Params.Caps (0);
      end if;
      return Item.Labelled_Interface_Cap;
   end Labelled_Cap;

   ----------
   -- Load --
   ----------

   procedure Load (Item : in out Gauge_Client) is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      Rose.System_Calls.Initialize_Send (Params, Item.Interface_Cap);
      Rose.System_Calls.Receive_Caps (Params, Subprogram_Count);
      Rose.System_Calls.Invoke_Capability (Params);
      if Params.Control.Flags (Rose.Invocation.Error) then
         raise Rose.Interfaces.Objects.Invocation_Error with "Gauge.Open";
      end if;
      Item.Badge := Params.Caps (Badge_Index);
      Item.Increment := Params.Caps (Increment_Index);
      Item.Value := Params.Caps (Value_Index);
      Item.Set_Label := Params.Caps (Set_Label_Index);
      Item.Reset := Params.Caps (Reset_Index);
      Item.Is_Open := True;
   end Load;

   ---------------
   -- Named_Cap --
   ---------------

   overriding function Named_Cap
     (Item : in out Gauge_Client)
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
              with "Gauge.Named_Cap";
         end if;
         Item.Named_Interface_Cap := Params.Caps (0);
      end if;
      return Item.Named_Interface_Cap;
   end Named_Cap;

   ----------
   -- Open --
   ----------

   procedure Open
     (Client        : out Gauge_Client;
      Interface_Cap : Rose.Capabilities.Capability)
   is
   begin
      Client.Is_Open := False;
      Client.Interface_Cap := Interface_Cap;
      Client.Named_Interface_Cap := Rose.Capabilities.Null_Capability;
      Client.Counter_Interface_Cap := Rose.Capabilities.Null_Capability;
      Client.Labelled_Interface_Cap := Rose.Capabilities.Null_Capability;
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

   overriding procedure Reset (Item : in out Gauge_Client) is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      if not Item.Is_Open then
         Load (Item);
      end if;
      Rose.System_Calls.Initialize_Send (Params, Item.Reset);
      Rose.System_Calls.Invoke_Capability (Params);
      if Params.Control.Flags (Rose.Invocation.Error) then
         raise Rose.Interfaces.Objects.Invocation_Error with "Gauge.Reset";
      end if;
   end Reset;

   ---------------
   -- Set_Label --
   ---------------

   overriding procedure Set_Label
     (Item  : in out Gauge_Client;
      Label : Rose.Words.Word)
   is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      if not Item.Is_Open then
         Load (Item);
      end if;
      Rose.System_Calls.Initialize_Send (Params, Item.Set_Label);
      Rose.System_Calls.Send_Word (Params, Label);
      Rose.System_Calls.Invoke_Capability (Params);
      if Params.Control.Flags (Rose.Invocation.Error) then
         raise Rose.Interfaces.Objects.Invocation_Error with "Gauge.Set_Label";
      end if;
   end Set_Label;

   -----------
   -- Value --
   -----------

   overriding function Value
     (Item : in out Gauge_Client)
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
         raise Rose.Interfaces.Objects.Invocation_Error with "Gauge.Value";
      end if;
      return Rose.System_Calls.Get_Word_32 (Params, 0);
   end Value;

end Rose.Interfaces.Gauge.Client;
