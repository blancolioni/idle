with Rose.Interfaces.Objects;
with Rose.Invocation;
with Rose.System_Calls;
with Rose.Words;

package body Rose.Interfaces.Boolean_Result.Client is

   use type Rose.Words.Word_32;

   procedure Load (Item : in out Boolean_Result_Client);

   ------------------------
   -- Boolean_Result_Cap --
   ------------------------

   overriding function Boolean_Result_Cap
     (Item : in out Boolean_Result_Client)
      return Rose.Capabilities.Capability
   is (Item.Interface_Cap);

   -----------
   -- Close --
   -----------

   procedure Close (Client : in out Boolean_Result_Client) is
   begin
      if Client.Is_Open then
         Rose.System_Calls.Delete_Cap (Client.Is_Ready);
      end if;
      Client.Is_Open := False;
      Rose.System_Calls.Delete_Cap (Client.Interface_Cap);
   end Close;

   --------------
   -- From_Cap --
   --------------

   function From_Cap
     (Cap : Rose.Capabilities.Capability)
      return Boolean_Result_Client
   is (Boolean_Result_Client'(Interface_Cap => Cap, others => <>));

   -----------------------
   -- Get_Interface_Cap --
   -----------------------

   function Get_Interface_Cap
     (Item : Boolean_Result_Client)
      return Rose.Capabilities.Capability
   is (Item.Interface_Cap);

   ----------------------
   -- Get_Is_Ready_Cap --
   ----------------------

   function Get_Is_Ready_Cap
     (Item : in out Boolean_Result_Client)
      return Rose.Capabilities.Capability
   is
   begin
      if not Item.Is_Open then
         Load (Item);
      end if;
      return Item.Is_Ready;
   end Get_Is_Ready_Cap;

   --------------
   -- Is_Ready --
   --------------

   overriding function Is_Ready
     (Item : in out Boolean_Result_Client)
      return Boolean
   is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      if not Item.Is_Open then
         Load (Item);
      end if;
      Rose.System_Calls.Initialize_Send (Params, Item.Is_Ready);
      Rose.System_Calls.Receive_Words (Params, 1);
      Rose.System_Calls.Invoke_Capability (Params);
      if Params.Control.Flags (Rose.Invocation.Error) then
         raise Rose.Interfaces.Objects.Invocation_Error
           with "Boolean_Result.Is_Ready";
      end if;
      return Rose.System_Calls.Get_Word_32 (Params, 0) /= 0;
   end Is_Ready;

   ----------
   -- Load --
   ----------

   procedure Load (Item : in out Boolean_Result_Client) is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      Rose.System_Calls.Initialize_Send (Params, Item.Interface_Cap);
      Rose.System_Calls.Receive_Caps (Params, Subprogram_Count);
      Rose.System_Calls.Invoke_Capability (Params);
      if Params.Control.Flags (Rose.Invocation.Error) then
         raise Rose.Interfaces.Objects.Invocation_Error
           with "Boolean_Result.Open";
      end if;
      Item.Is_Ready := Params.Caps (Is_Ready_Index);
      Item.Is_Open := True;
   end Load;

   ----------
   -- Open --
   ----------

   procedure Open
     (Client        : out Boolean_Result_Client;
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
     (Client   : out Boolean_Result_Client;
      Is_Ready : Rose.Capabilities.Capability)
   is
   begin
      Client.Is_Ready := Is_Ready;
      Client.Is_Open := True;
   end Open_Cap_Set;

end Rose.Interfaces.Boolean_Result.Client;
