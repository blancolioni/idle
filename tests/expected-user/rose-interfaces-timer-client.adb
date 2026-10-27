with Rose.Interfaces.Cap.Client;
with Rose.Interfaces.Objects;
with Rose.Invocation;
with Rose.System_Calls;

package body Rose.Interfaces.Timer.Client is

   procedure Load (Item : in out Timer_Client);

   -----------
   -- Close --
   -----------

   procedure Close (Client : in out Timer_Client) is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      if Client.Is_Open then
         Rose.System_Calls.Initialize_Send
           (Params,
            Rose.System_Calls.Delete_Cap_Capability);
         Rose.System_Calls.Send_Cap (Params, Client.Set_Timer);
         Rose.System_Calls.Invoke_Capability (Params);
      end if;
      Client.Is_Open := False;
      Rose.System_Calls.Initialize_Send
        (Params,
         Rose.System_Calls.Delete_Cap_Capability);
      Rose.System_Calls.Send_Cap (Params, Client.Interface_Cap);
      Rose.System_Calls.Invoke_Capability (Params);
   end Close;

   --------------
   -- From_Cap --
   --------------

   function From_Cap
     (Cap : Rose.Capabilities.Capability)
      return Timer_Client
   is (Timer_Client'(Interface_Cap => Cap, others => <>));

   -----------------------
   -- Get_Interface_Cap --
   -----------------------

   function Get_Interface_Cap
     (Item : Timer_Client)
      return Rose.Capabilities.Capability
   is (Item.Interface_Cap);

   -----------------------
   -- Get_Set_Timer_Cap --
   -----------------------

   function Get_Set_Timer_Cap
     (Item : in out Timer_Client)
      return Rose.Capabilities.Capability
   is
   begin
      if not Item.Is_Open then
         Load (Item);
      end if;
      return Item.Set_Timer;
   end Get_Set_Timer_Cap;

   ----------
   -- Load --
   ----------

   procedure Load (Item : in out Timer_Client) is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      Rose.System_Calls.Initialize_Send (Params, Item.Interface_Cap);
      Rose.System_Calls.Receive_Caps (Params, Subprogram_Count);
      Rose.System_Calls.Invoke_Capability (Params);
      if Params.Control.Flags (Rose.Invocation.Error) then
         raise Rose.Interfaces.Objects.Invocation_Error with "Timer.Open";
      end if;
      Item.Set_Timer := Params.Caps (Set_Timer_Index);
      Item.Is_Open := True;
   end Load;

   ----------
   -- Open --
   ----------

   procedure Open
     (Client        : out Timer_Client;
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
     (Client    : out Timer_Client;
      Set_Timer : Rose.Capabilities.Capability)
   is
   begin
      Client.Set_Timer := Set_Timer;
      Client.Is_Open := True;
   end Open_Cap_Set;

   ---------------
   -- Set_Timer --
   ---------------

   overriding function Set_Timer
     (Item         : in out Timer_Client;
      Milliseconds : Rose.Words.Word;
      Cap          : Rose.Capabilities.Capability)
      return Rose.Interfaces.Cap.Cap_Object'Class
   is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      if not Item.Is_Open then
         Load (Item);
      end if;
      Rose.System_Calls.Initialize_Send (Params, Item.Set_Timer);
      Rose.System_Calls.Send_Word (Params, Milliseconds);
      Rose.System_Calls.Send_Cap (Params, Cap);
      Rose.System_Calls.Receive_Caps (Params, 1);
      Rose.System_Calls.Invoke_Capability (Params);
      if Params.Control.Flags (Rose.Invocation.Error) then
         raise Rose.Interfaces.Objects.Invocation_Error with "Timer.Set_Timer";
      end if;
      return Rose.Interfaces.Cap.Client.From_Cap (Params.Caps (0));
   end Set_Timer;

   ---------------
   -- Timer_Cap --
   ---------------

   overriding function Timer_Cap
     (Item : in out Timer_Client)
      return Rose.Capabilities.Capability
   is (Item.Interface_Cap);

end Rose.Interfaces.Timer.Client;
