with Rose.Interfaces.Objects;
with Rose.Invocation;
with Rose.System_Calls;

package body Rose.Interfaces.Partner.Client is

   procedure Load (Item : in out Partner_Client);

   -----------
   -- Close --
   -----------

   procedure Close (Client : in out Partner_Client) is
   begin
      if Client.Is_Open then
         Rose.System_Calls.Delete_Cap (Client.Pair);
         Rose.System_Calls.Delete_Cap (Client.Next);
      end if;
      Client.Is_Open := False;
      Rose.System_Calls.Delete_Cap (Client.Interface_Cap);
   end Close;

   --------------
   -- From_Cap --
   --------------

   function From_Cap
     (Cap : Rose.Capabilities.Capability)
      return Partner_Client
   is (Partner_Client'(Interface_Cap => Cap, others => <>));

   -----------------------
   -- Get_Interface_Cap --
   -----------------------

   function Get_Interface_Cap
     (Item : Partner_Client)
      return Rose.Capabilities.Capability
   is (Item.Interface_Cap);

   ------------------
   -- Get_Next_Cap --
   ------------------

   function Get_Next_Cap
     (Item : in out Partner_Client)
      return Rose.Capabilities.Capability
   is
   begin
      if not Item.Is_Open then
         Load (Item);
      end if;
      return Item.Next;
   end Get_Next_Cap;

   ------------------
   -- Get_Pair_Cap --
   ------------------

   function Get_Pair_Cap
     (Item : in out Partner_Client)
      return Rose.Capabilities.Capability
   is
   begin
      if not Item.Is_Open then
         Load (Item);
      end if;
      return Item.Pair;
   end Get_Pair_Cap;

   ----------
   -- Load --
   ----------

   procedure Load (Item : in out Partner_Client) is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      Rose.System_Calls.Initialize_Send (Params, Item.Interface_Cap);
      Rose.System_Calls.Receive_Caps (Params, Subprogram_Count);
      Rose.System_Calls.Invoke_Capability (Params);
      if Params.Control.Flags (Rose.Invocation.Error) then
         raise Rose.Interfaces.Objects.Invocation_Error with "Partner.Open";
      end if;
      Item.Pair := Params.Caps (Pair_Index);
      Item.Next := Params.Caps (Next_Index);
      Item.Is_Open := True;
   end Load;

   ----------
   -- Next --
   ----------

   overriding function Next
     (Item : in out Partner_Client)
      return Rose.Interfaces.Partner.Partner_Object'Class
   is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      if not Item.Is_Open then
         Load (Item);
      end if;
      Rose.System_Calls.Initialize_Send (Params, Item.Next);
      Rose.System_Calls.Receive_Caps (Params, 1);
      Rose.System_Calls.Invoke_Capability (Params);
      if Params.Control.Flags (Rose.Invocation.Error) then
         raise Rose.Interfaces.Objects.Invocation_Error with "Partner.Next";
      end if;
      return From_Cap (Params.Caps (0));
   end Next;

   ----------
   -- Open --
   ----------

   procedure Open
     (Client        : out Partner_Client;
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
     (Client : out Partner_Client;
      Pair   : Rose.Capabilities.Capability;
      Next   : Rose.Capabilities.Capability)
   is
   begin
      Client.Pair := Pair;
      Client.Next := Next;
      Client.Is_Open := True;
   end Open_Cap_Set;

   ----------
   -- Pair --
   ----------

   overriding procedure Pair
     (Item  : in out Partner_Client;
      Other : in out Partner_Client;
      Peer  : in out Rose.Interfaces.Partner.Partner_Object'Class)
   is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      if not Item.Is_Open then
         Load (Item);
      end if;
      Rose.System_Calls.Initialize_Send (Params, Item.Pair);
      Rose.System_Calls.Send_Cap (Params, Peer.Partner_Cap);
      Rose.System_Calls.Receive_Caps (Params, 2);
      Rose.System_Calls.Invoke_Capability (Params);
      if Params.Control.Flags (Rose.Invocation.Error) then
         raise Rose.Interfaces.Objects.Invocation_Error with "Partner.Pair";
      end if;
      Open (Other, Params.Caps (0));
   end Pair;

   -----------------
   -- Partner_Cap --
   -----------------

   overriding function Partner_Cap
     (Item : in out Partner_Client)
      return Rose.Capabilities.Capability
   is (Item.Interface_Cap);

end Rose.Interfaces.Partner.Client;
