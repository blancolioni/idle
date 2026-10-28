with Rose.Interfaces.Objects;
with Rose.Invocation;
with Rose.System_Calls;

package body Rose.Interfaces.Cap_Set.Client is

   procedure Load (Item : in out Cap_Set_Client);

   ------------
   -- Append --
   ------------

   overriding procedure Append
     (Item : in out Cap_Set_Client;
      Caps : Rose.Capabilities.Capability_Array)
   is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      if not Item.Is_Open then
         Load (Item);
      end if;
      Rose.System_Calls.Initialize_Send (Params, Item.Append);
      for Cap of Caps loop
         Rose.System_Calls.Send_Cap (Params, Cap);
      end loop;
      Rose.System_Calls.Invoke_Capability (Params);
      if Params.Control.Flags (Rose.Invocation.Error) then
         raise Rose.Interfaces.Objects.Invocation_Error with "Cap_Set.Append";
      end if;
   end Append;

   -----------------
   -- Cap_Set_Cap --
   -----------------

   overriding function Cap_Set_Cap
     (Item : in out Cap_Set_Client)
      return Rose.Capabilities.Capability
   is (Item.Interface_Cap);

   -----------
   -- Close --
   -----------

   procedure Close (Client : in out Cap_Set_Client) is
   begin
      if Client.Is_Open then
         Rose.System_Calls.Delete_Cap (Client.Append);
         Rose.System_Calls.Delete_Cap (Client.Get_Cap);
         Rose.System_Calls.Delete_Cap (Client.Length);
      end if;
      Client.Is_Open := False;
      Rose.System_Calls.Delete_Cap (Client.Interface_Cap);
   end Close;

   --------------
   -- From_Cap --
   --------------

   function From_Cap
     (Cap : Rose.Capabilities.Capability)
      return Cap_Set_Client
   is (Cap_Set_Client'(Interface_Cap => Cap, others => <>));

   --------------------
   -- Get_Append_Cap --
   --------------------

   function Get_Append_Cap
     (Item : in out Cap_Set_Client)
      return Rose.Capabilities.Capability
   is
   begin
      if not Item.Is_Open then
         Load (Item);
      end if;
      return Item.Append;
   end Get_Append_Cap;

   -------------
   -- Get_Cap --
   -------------

   overriding function Get_Cap
     (Item  : in out Cap_Set_Client;
      Index : Positive)
      return Rose.Capabilities.Capability
   is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      if not Item.Is_Open then
         Load (Item);
      end if;
      Rose.System_Calls.Initialize_Send (Params, Item.Get_Cap);
      Rose.System_Calls.Send_Word (Params, Index);
      Rose.System_Calls.Receive_Caps (Params, 1);
      Rose.System_Calls.Invoke_Capability (Params);
      if Params.Control.Flags (Rose.Invocation.Error) then
         raise Rose.Interfaces.Objects.Invocation_Error with "Cap_Set.Get_Cap";
      end if;
      return Params.Caps (0);
   end Get_Cap;

   ---------------------
   -- Get_Get_Cap_Cap --
   ---------------------

   function Get_Get_Cap_Cap
     (Item : in out Cap_Set_Client)
      return Rose.Capabilities.Capability
   is
   begin
      if not Item.Is_Open then
         Load (Item);
      end if;
      return Item.Get_Cap;
   end Get_Get_Cap_Cap;

   -----------------------
   -- Get_Interface_Cap --
   -----------------------

   function Get_Interface_Cap
     (Item : Cap_Set_Client)
      return Rose.Capabilities.Capability
   is (Item.Interface_Cap);

   --------------------
   -- Get_Length_Cap --
   --------------------

   function Get_Length_Cap
     (Item : in out Cap_Set_Client)
      return Rose.Capabilities.Capability
   is
   begin
      if not Item.Is_Open then
         Load (Item);
      end if;
      return Item.Length;
   end Get_Length_Cap;

   ------------
   -- Length --
   ------------

   overriding function Length (Item : in out Cap_Set_Client) return Natural is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      if not Item.Is_Open then
         Load (Item);
      end if;
      Rose.System_Calls.Initialize_Send (Params, Item.Length);
      Rose.System_Calls.Receive_Words (Params, 1);
      Rose.System_Calls.Invoke_Capability (Params);
      if Params.Control.Flags (Rose.Invocation.Error) then
         raise Rose.Interfaces.Objects.Invocation_Error with "Cap_Set.Length";
      end if;
      return Natural (Rose.System_Calls.Get_Word_32 (Params, 0));
   end Length;

   ----------
   -- Load --
   ----------

   procedure Load (Item : in out Cap_Set_Client) is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      Rose.System_Calls.Initialize_Send (Params, Item.Interface_Cap);
      Rose.System_Calls.Receive_Caps (Params, Subprogram_Count);
      Rose.System_Calls.Invoke_Capability (Params);
      if Params.Control.Flags (Rose.Invocation.Error) then
         raise Rose.Interfaces.Objects.Invocation_Error with "Cap_Set.Open";
      end if;
      Item.Append := Params.Caps (Append_Index);
      Item.Get_Cap := Params.Caps (Get_Cap_Index);
      Item.Length := Params.Caps (Length_Index);
      Item.Is_Open := True;
   end Load;

   ----------
   -- Open --
   ----------

   procedure Open
     (Client        : out Cap_Set_Client;
      Interface_Cap : Rose.Capabilities.Capability)
   is
   begin
      Client.Is_Open := False;
      Client.Interface_Cap := Interface_Cap;
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
