with Rose.Interfaces.Objects;
with Rose.Invocation;
with Rose.System_Calls;

package body Rose.Interfaces.Lease.Client is

   procedure Load (Item : in out Lease_Client);

   -----------
   -- Badge --
   -----------

   overriding function Badge
     (Item : in out Lease_Client)
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
         raise Rose.Interfaces.Objects.Invocation_Error with "Lease.Badge";
      end if;
      return Params.Caps (0);
   end Badge;

   -----------
   -- Close --
   -----------

   procedure Close (Client : in out Lease_Client) is
      use type Rose.Capabilities.Capability;
   begin
      if Client.Is_Open
        or else Client.Interface_Cap /= Rose.Capabilities.Null_Capability
      then
         Release (Client);
      end if;
      if Client.Is_Open then
         Rose.System_Calls.Delete_Cap (Client.Badge);
         Rose.System_Calls.Delete_Cap (Client.Increment);
         Rose.System_Calls.Delete_Cap (Client.Value);
         Rose.System_Calls.Delete_Cap (Client.Release);
         Rose.System_Calls.Delete_Cap (Client.Remaining);
      end if;
      Client.Is_Open := False;
      if Client.Named_Interface_Cap /= Rose.Capabilities.Null_Capability then
         Rose.System_Calls.Delete_Cap (Client.Named_Interface_Cap);
         Client.Named_Interface_Cap := Rose.Capabilities.Null_Capability;
      end if;
      if Client.Counter_Interface_Cap /= Rose.Capabilities.Null_Capability then
         Rose.System_Calls.Delete_Cap (Client.Counter_Interface_Cap);
         Client.Counter_Interface_Cap := Rose.Capabilities.Null_Capability;
      end if;
      if Client.Resource_Interface_Cap /= Rose.Capabilities.Null_Capability
      then
         Rose.System_Calls.Delete_Cap (Client.Resource_Interface_Cap);
         Client.Resource_Interface_Cap := Rose.Capabilities.Null_Capability;
      end if;
      Rose.System_Calls.Delete_Cap (Client.Interface_Cap);
   end Close;

   -----------------
   -- Counter_Cap --
   -----------------

   overriding function Counter_Cap
     (Item : in out Lease_Client)
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
              with "Lease.Counter_Cap";
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
      return Lease_Client
   is (Lease_Client'(Interface_Cap => Cap, others => <>));

   -------------------
   -- Get_Badge_Cap --
   -------------------

   function Get_Badge_Cap
     (Item : in out Lease_Client)
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
     (Item : in out Lease_Client)
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
     (Item : Lease_Client)
      return Rose.Capabilities.Capability
   is (Item.Interface_Cap);

   ---------------------
   -- Get_Release_Cap --
   ---------------------

   function Get_Release_Cap
     (Item : in out Lease_Client)
      return Rose.Capabilities.Capability
   is
   begin
      if not Item.Is_Open then
         Load (Item);
      end if;
      return Item.Release;
   end Get_Release_Cap;

   -----------------------
   -- Get_Remaining_Cap --
   -----------------------

   function Get_Remaining_Cap
     (Item : in out Lease_Client)
      return Rose.Capabilities.Capability
   is
   begin
      if not Item.Is_Open then
         Load (Item);
      end if;
      return Item.Remaining;
   end Get_Remaining_Cap;

   -------------------
   -- Get_Value_Cap --
   -------------------

   function Get_Value_Cap
     (Item : in out Lease_Client)
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
     (Item : in out Lease_Client;
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
         raise Rose.Interfaces.Objects.Invocation_Error with "Lease.Increment";
      end if;
   end Increment;

   ---------------
   -- Lease_Cap --
   ---------------

   overriding function Lease_Cap
     (Item : in out Lease_Client)
      return Rose.Capabilities.Capability
   is (Item.Interface_Cap);

   ----------
   -- Load --
   ----------

   procedure Load (Item : in out Lease_Client) is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      Rose.System_Calls.Initialize_Send (Params, Item.Interface_Cap);
      Rose.System_Calls.Receive_Caps (Params, Subprogram_Count);
      Rose.System_Calls.Invoke_Capability (Params);
      if Params.Control.Flags (Rose.Invocation.Error) then
         raise Rose.Interfaces.Objects.Invocation_Error with "Lease.Open";
      end if;
      Item.Badge := Params.Caps (Badge_Index);
      Item.Increment := Params.Caps (Increment_Index);
      Item.Value := Params.Caps (Value_Index);
      Item.Release := Params.Caps (Release_Index);
      Item.Remaining := Params.Caps (Remaining_Index);
      Item.Is_Open := True;
   end Load;

   ---------------
   -- Named_Cap --
   ---------------

   overriding function Named_Cap
     (Item : in out Lease_Client)
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
              with "Lease.Named_Cap";
         end if;
         Item.Named_Interface_Cap := Params.Caps (0);
      end if;
      return Item.Named_Interface_Cap;
   end Named_Cap;

   ----------
   -- Open --
   ----------

   procedure Open
     (Client        : out Lease_Client;
      Interface_Cap : Rose.Capabilities.Capability)
   is
   begin
      Client.Is_Open := False;
      Client.Interface_Cap := Interface_Cap;
      Client.Named_Interface_Cap := Rose.Capabilities.Null_Capability;
      Client.Counter_Interface_Cap := Rose.Capabilities.Null_Capability;
      Client.Resource_Interface_Cap := Rose.Capabilities.Null_Capability;
   end Open;

   ------------------
   -- Open_Cap_Set --
   ------------------

   procedure Open_Cap_Set
     (Client    : out Lease_Client;
      Badge     : Rose.Capabilities.Capability;
      Increment : Rose.Capabilities.Capability;
      Value     : Rose.Capabilities.Capability;
      Release   : Rose.Capabilities.Capability;
      Remaining : Rose.Capabilities.Capability)
   is
   begin
      Client.Badge := Badge;
      Client.Increment := Increment;
      Client.Value := Value;
      Client.Release := Release;
      Client.Remaining := Remaining;
      Client.Is_Open := True;
   end Open_Cap_Set;

   -------------
   -- Release --
   -------------

   overriding procedure Release (Item : in out Lease_Client) is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      if not Item.Is_Open then
         Load (Item);
      end if;
      Rose.System_Calls.Initialize_Send (Params, Item.Release);
      Rose.System_Calls.Invoke_Capability (Params);
      if Params.Control.Flags (Rose.Invocation.Error) then
         raise Rose.Interfaces.Objects.Invocation_Error with "Lease.Release";
      end if;
   end Release;

   ---------------
   -- Remaining --
   ---------------

   overriding function Remaining
     (Item : in out Lease_Client)
      return Rose.Words.Word
   is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      if not Item.Is_Open then
         Load (Item);
      end if;
      Rose.System_Calls.Initialize_Send (Params, Item.Remaining);
      Rose.System_Calls.Receive_Words (Params, 1);
      Rose.System_Calls.Invoke_Capability (Params);
      if Params.Control.Flags (Rose.Invocation.Error) then
         raise Rose.Interfaces.Objects.Invocation_Error with "Lease.Remaining";
      end if;
      return Rose.System_Calls.Get_Word_32 (Params, 0);
   end Remaining;

   ------------------
   -- Resource_Cap --
   ------------------

   overriding function Resource_Cap
     (Item : in out Lease_Client)
      return Rose.Capabilities.Capability
   is
      use type Rose.Capabilities.Capability;
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      if Item.Resource_Interface_Cap = Rose.Capabilities.Null_Capability
        and then Item.Interface_Cap /= Rose.Capabilities.Null_Capability
      then
         Rose.System_Calls.Initialize_Send (Params, Item.Interface_Cap);
         Rose.System_Calls.Send_Word (Params, Natural (3));
         Rose.System_Calls.Receive_Caps (Params, 1);
         Rose.System_Calls.Invoke_Capability (Params);
         if Params.Control.Flags (Rose.Invocation.Error) then
            raise Rose.Interfaces.Objects.Invocation_Error
              with "Lease.Resource_Cap";
         end if;
         Item.Resource_Interface_Cap := Params.Caps (0);
      end if;
      return Item.Resource_Interface_Cap;
   end Resource_Cap;

   -----------
   -- Value --
   -----------

   overriding function Value
     (Item : in out Lease_Client)
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
         raise Rose.Interfaces.Objects.Invocation_Error with "Lease.Value";
      end if;
      return Rose.System_Calls.Get_Word_32 (Params, 0);
   end Value;

end Rose.Interfaces.Lease.Client;
