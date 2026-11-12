with Rose.Interfaces.Objects;
with Rose.Invocation;
with Rose.System_Calls;
with Rose.Words;

package body Rose.Interfaces.Toggle.Client is

   use type Rose.Words.Word_32;

   procedure Load (Item : in out Toggle_Client);

   -----------
   -- Close --
   -----------

   procedure Close (Client : in out Toggle_Client) is
   begin
      if Client.Is_Open then
         Rose.System_Calls.Delete_Cap (Client.Is_On);
         Rose.System_Calls.Delete_Cap (Client.Switch);
      end if;
      Client.Is_Open := False;
      Rose.System_Calls.Delete_Cap (Client.Interface_Cap);
   end Close;

   --------------
   -- From_Cap --
   --------------

   function From_Cap
     (Cap : Rose.Capabilities.Capability)
      return Toggle_Client
   is (Toggle_Client'(Interface_Cap => Cap, others => <>));

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
     (Item : in out Toggle_Client)
      return Rose.Capabilities.Capability
   is
   begin
      if not Item.Is_Open then
         Load (Item);
      end if;
      return Item.Is_On;
   end Get_Is_On_Cap;

   --------------------
   -- Get_Switch_Cap --
   --------------------

   function Get_Switch_Cap
     (Item : in out Toggle_Client)
      return Rose.Capabilities.Capability
   is
   begin
      if not Item.Is_Open then
         Load (Item);
      end if;
      return Item.Switch;
   end Get_Switch_Cap;

   -----------
   -- Is_On --
   -----------

   overriding function Is_On (Item : in out Toggle_Client) return Boolean is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      if not Item.Is_Open then
         Load (Item);
      end if;
      Rose.System_Calls.Initialize_Send (Params, Item.Is_On);
      Rose.System_Calls.Receive_Words (Params, 1);
      Rose.System_Calls.Invoke_Capability (Params);
      if Params.Control.Flags (Rose.Invocation.Error) then
         raise Rose.Interfaces.Objects.Invocation_Error with "Toggle.Is_On";
      end if;
      return Rose.System_Calls.Get_Word_32 (Params, 0) /= 0;
   end Is_On;

   ----------
   -- Load --
   ----------

   procedure Load (Item : in out Toggle_Client) is
      Params : aliased Rose.Invocation.Invocation_Record;
      Caps   : Rose.Capabilities.Capability_Array (1 .. Subprogram_Count);
      Index  : Natural := 0;
      First  : Natural := Natural'Last;
   begin
      for Cap of Caps loop
         if First > Index
           or else Index - First >= Rose.Invocation.Max_Capabilities
         then
            First := Index;
            Rose.System_Calls.Initialize_Send (Params, Item.Interface_Cap);
            Rose.System_Calls.Send_Word (Params, Natural (0));
            Rose.System_Calls.Send_Word (Params, First);
            Rose.System_Calls.Send_Word
              (Params,
               Natural'Min
                 (Rose.Invocation.Max_Capabilities,
                  Subprogram_Count - First));
            Rose.System_Calls.Receive_Caps
              (Params,
               Natural'Min
                 (Rose.Invocation.Max_Capabilities,
                  Subprogram_Count - First));
            Rose.System_Calls.Invoke_Capability (Params);
            if Params.Control.Flags (Rose.Invocation.Error) then
               raise Rose.Interfaces.Objects.Invocation_Error
                 with "Toggle.Open";
            end if;
         end if;
         Cap := Params.Caps (Rose.Invocation.Capability_Index (Index - First));
         Index := Index + 1;
      end loop;
      Item.Is_On := Caps (Is_On_Index + 1);
      Item.Switch := Caps (Switch_Index + 1);
      Item.Is_Open := True;
   end Load;

   ----------
   -- Open --
   ----------

   procedure Open
     (Client        : out Toggle_Client;
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

   overriding procedure Switch (Item : in out Toggle_Client; On : Boolean) is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      if not Item.Is_Open then
         Load (Item);
      end if;
      Rose.System_Calls.Initialize_Send (Params, Item.Switch);
      Rose.System_Calls.Send_Word (Params, Natural (Boolean'Pos (On)));
      Rose.System_Calls.Invoke_Capability (Params);
      if Params.Control.Flags (Rose.Invocation.Error) then
         raise Rose.Interfaces.Objects.Invocation_Error with "Toggle.Switch";
      end if;
   end Switch;

   ----------------
   -- Toggle_Cap --
   ----------------

   overriding function Toggle_Cap
     (Item : in out Toggle_Client)
      return Rose.Capabilities.Capability
   is (Item.Interface_Cap);

end Rose.Interfaces.Toggle.Client;
