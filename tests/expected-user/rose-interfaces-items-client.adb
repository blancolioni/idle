with Rose.Interfaces.Objects;
with Rose.Invocation;
with Rose.System_Calls;

package body Rose.Interfaces.Items.Client is

   procedure Load (Item : in out Items_Client);

   -----------
   -- Close --
   -----------

   procedure Close (Client : in out Items_Client) is
   begin
      if Client.Is_Open then
         Rose.System_Calls.Delete_Cap (Client.Pair);
         Rose.System_Calls.Delete_Cap (Client.Store);
         Rose.System_Calls.Delete_Cap (Client.Single);
      end if;
      Client.Is_Open := False;
      Rose.System_Calls.Delete_Cap (Client.Interface_Cap);
   end Close;

   --------------
   -- From_Cap --
   --------------

   function From_Cap
     (Cap : Rose.Capabilities.Capability)
      return Items_Client
   is (Items_Client'(Interface_Cap => Cap, others => <>));

   -----------------------
   -- Get_Interface_Cap --
   -----------------------

   function Get_Interface_Cap
     (Item : Items_Client)
      return Rose.Capabilities.Capability
   is (Item.Interface_Cap);

   ------------------
   -- Get_Pair_Cap --
   ------------------

   function Get_Pair_Cap
     (Item : in out Items_Client)
      return Rose.Capabilities.Capability
   is
   begin
      if not Item.Is_Open then
         Load (Item);
      end if;
      return Item.Pair;
   end Get_Pair_Cap;

   --------------------
   -- Get_Single_Cap --
   --------------------

   function Get_Single_Cap
     (Item : in out Items_Client)
      return Rose.Capabilities.Capability
   is
   begin
      if not Item.Is_Open then
         Load (Item);
      end if;
      return Item.Single;
   end Get_Single_Cap;

   -------------------
   -- Get_Store_Cap --
   -------------------

   function Get_Store_Cap
     (Item : in out Items_Client)
      return Rose.Capabilities.Capability
   is
   begin
      if not Item.Is_Open then
         Load (Item);
      end if;
      return Item.Store;
   end Get_Store_Cap;

   ---------------
   -- Items_Cap --
   ---------------

   overriding function Items_Cap
     (Item : in out Items_Client)
      return Rose.Capabilities.Capability
   is (Item.Interface_Cap);

   ----------
   -- Load --
   ----------

   procedure Load (Item : in out Items_Client) is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      Rose.System_Calls.Initialize_Send (Params, Item.Interface_Cap);
      Rose.System_Calls.Receive_Caps (Params, Subprogram_Count);
      Rose.System_Calls.Invoke_Capability (Params);
      if Params.Control.Flags (Rose.Invocation.Error) then
         raise Rose.Interfaces.Objects.Invocation_Error with "Items.Open";
      end if;
      Item.Pair := Params.Caps (Pair_Index);
      Item.Store := Params.Caps (Store_Index);
      Item.Single := Params.Caps (Single_Index);
      Item.Is_Open := True;
   end Load;

   ----------
   -- Open --
   ----------

   procedure Open
     (Client        : out Items_Client;
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
     (Client : out Items_Client;
      Pair   : Rose.Capabilities.Capability;
      Store  : Rose.Capabilities.Capability;
      Single : Rose.Capabilities.Capability)
   is
   begin
      Client.Pair := Pair;
      Client.Store := Store;
      Client.Single := Single;
      Client.Is_Open := True;
   end Open_Cap_Set;

   ----------
   -- Pair --
   ----------

   overriding function Pair
     (Item     : in out Items_Client;
      Name     : String;
      Password : String)
      return Rose.Capabilities.Capability
   is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      if not Item.Is_Open then
         Load (Item);
      end if;
      Rose.System_Calls.Initialize_Send (Params, Item.Pair);
      Rose.System_Calls.Start_Items (Params);
      Rose.System_Calls.Send_Text_Item (Params, Name);
      Rose.System_Calls.Send_Text_Item (Params, Password);
      Rose.System_Calls.Receive_Caps (Params, 1);
      Rose.System_Calls.Invoke_Capability (Params);
      if Params.Control.Flags (Rose.Invocation.Error) then
         raise Rose.Interfaces.Objects.Invocation_Error with "Items.Pair";
      end if;
      return Params.Caps (0);
   end Pair;

   ------------
   -- Single --
   ------------

   overriding procedure Single (Item : in out Items_Client; Name : String) is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      if not Item.Is_Open then
         Load (Item);
      end if;
      Rose.System_Calls.Initialize_Send (Params, Item.Single);
      Rose.System_Calls.Send_Text (Params, Name);
      Rose.System_Calls.Invoke_Capability (Params);
      if Params.Control.Flags (Rose.Invocation.Error) then
         raise Rose.Interfaces.Objects.Invocation_Error with "Items.Single";
      end if;
   end Single;

   -----------
   -- Store --
   -----------

   overriding procedure Store
     (Item  : in out Items_Client;
      Index : Rose.Words.Word;
      Key   : String;
      Data  : System.Storage_Elements.Storage_Array;
      Owner : Rose.Capabilities.Capability)
   is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      if not Item.Is_Open then
         Load (Item);
      end if;
      Rose.System_Calls.Initialize_Send (Params, Item.Store);
      Rose.System_Calls.Start_Items (Params);
      Rose.System_Calls.Send_Word (Params, Index);
      Rose.System_Calls.Send_Text_Item (Params, Key);
      Rose.System_Calls.Send_Storage_Item (Params, Data);
      Rose.System_Calls.Send_Cap (Params, Owner);
      Rose.System_Calls.Invoke_Capability (Params);
      if Params.Control.Flags (Rose.Invocation.Error) then
         raise Rose.Interfaces.Objects.Invocation_Error with "Items.Store";
      end if;
   end Store;

end Rose.Interfaces.Items.Client;
