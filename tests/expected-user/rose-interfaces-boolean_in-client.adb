with Rose.Interfaces.Objects;
with Rose.Invocation;
with Rose.System_Calls;

package body Rose.Interfaces.Boolean_In.Client is

   procedure Load (Item : in out Boolean_In_Client);

   --------------------
   -- Boolean_In_Cap --
   --------------------

   overriding function Boolean_In_Cap
     (Item : in out Boolean_In_Client)
      return Rose.Capabilities.Capability
   is (Item.Interface_Cap);

   -----------
   -- Close --
   -----------

   procedure Close (Client : in out Boolean_In_Client) is
   begin
      if Client.Is_Open then
         Rose.System_Calls.Delete_Cap (Client.Set);
      end if;
      Client.Is_Open := False;
      Rose.System_Calls.Delete_Cap (Client.Interface_Cap);
   end Close;

   --------------
   -- From_Cap --
   --------------

   function From_Cap
     (Cap : Rose.Capabilities.Capability)
      return Boolean_In_Client
   is (Boolean_In_Client'(Interface_Cap => Cap, others => <>));

   -----------------------
   -- Get_Interface_Cap --
   -----------------------

   function Get_Interface_Cap
     (Item : Boolean_In_Client)
      return Rose.Capabilities.Capability
   is (Item.Interface_Cap);

   -----------------
   -- Get_Set_Cap --
   -----------------

   function Get_Set_Cap
     (Item : in out Boolean_In_Client)
      return Rose.Capabilities.Capability
   is
   begin
      if not Item.Is_Open then
         Load (Item);
      end if;
      return Item.Set;
   end Get_Set_Cap;

   ----------
   -- Load --
   ----------

   procedure Load (Item : in out Boolean_In_Client) is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      Rose.System_Calls.Initialize_Send (Params, Item.Interface_Cap);
      Rose.System_Calls.Receive_Caps (Params, Subprogram_Count);
      Rose.System_Calls.Invoke_Capability (Params);
      if Params.Control.Flags (Rose.Invocation.Error) then
         raise Rose.Interfaces.Objects.Invocation_Error with "Boolean_In.Open";
      end if;
      Item.Set := Params.Caps (Set_Index);
      Item.Is_Open := True;
   end Load;

   ----------
   -- Open --
   ----------

   procedure Open
     (Client        : out Boolean_In_Client;
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
     (Client : out Boolean_In_Client;
      Set    : Rose.Capabilities.Capability)
   is
   begin
      Client.Set := Set;
      Client.Is_Open := True;
   end Open_Cap_Set;

   ---------
   -- Set --
   ---------

   overriding procedure Set (Item : in out Boolean_In_Client; On : Boolean) is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      if not Item.Is_Open then
         Load (Item);
      end if;
      Rose.System_Calls.Initialize_Send (Params, Item.Set);
      Rose.System_Calls.Send_Word (Params, Natural (Boolean'Pos (On)));
      Rose.System_Calls.Invoke_Capability (Params);
      if Params.Control.Flags (Rose.Invocation.Error) then
         raise Rose.Interfaces.Objects.Invocation_Error with "Boolean_In.Set";
      end if;
   end Set;

end Rose.Interfaces.Boolean_In.Client;
