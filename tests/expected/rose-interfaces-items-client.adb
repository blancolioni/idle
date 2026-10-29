with Rose.System_Calls;

package body Rose.Interfaces.Items.Client is

   use type Rose.Invocation.Invocation_Error;

   Last_Error : Rose.Invocation.Invocation_Error := Rose.Invocation.OK;

   -----------
   -- Close --
   -----------

   procedure Close (Client : in out Items_Client) is
   begin
      Client.Is_Open := False;
      Rose.System_Calls.Delete_Cap (Client.Pair);
      Rose.System_Calls.Delete_Cap (Client.Store);
      Rose.System_Calls.Delete_Cap (Client.Single);
      Rose.System_Calls.Delete_Cap (Client.Interface_Cap);
   end Close;

   -----------------------
   -- Get_Interface_Cap --
   -----------------------

   function Get_Interface_Cap
     (Item : Items_Client)
      return Rose.Capabilities.Capability
   is (Item.Interface_Cap);

   --------------------
   -- Get_Last_Error --
   --------------------

   function Get_Last_Error
      return Rose.Invocation.Invocation_Error
   is (Last_Error);

   ------------------
   -- Get_Pair_Cap --
   ------------------

   function Get_Pair_Cap
     (Item : Items_Client)
      return Rose.Capabilities.Capability
   is (Item.Pair);

   --------------------
   -- Get_Single_Cap --
   --------------------

   function Get_Single_Cap
     (Item : Items_Client)
      return Rose.Capabilities.Capability
   is (Item.Single);

   -------------------
   -- Get_Store_Cap --
   -------------------

   function Get_Store_Cap
     (Item : Items_Client)
      return Rose.Capabilities.Capability
   is (Item.Store);

   ---------------
   -- Has_Error --
   ---------------

   function Has_Error return Boolean is (Last_Error /= Rose.Invocation.OK);

   ----------
   -- Open --
   ----------

   procedure Open
     (Client        : out Items_Client;
      Interface_Cap : Rose.Capabilities.Capability)
   is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      Client.Is_Open := False;
      Client.Interface_Cap := Interface_Cap;
      Rose.System_Calls.Initialize_Send (Params, Interface_Cap);
      Rose.System_Calls.Receive_Caps (Params, Subprogram_Count);
      Rose.System_Calls.Invoke_Capability (Params);
      Client.Pair := Params.Caps (Pair_Index);
      Client.Store := Params.Caps (Store_Index);
      Client.Single := Params.Caps (Single_Index);
      Client.Is_Open := True;
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

   function Pair
     (Item     : Items_Client;
      Name     : String;
      Password : String)
      return Rose.Capabilities.Capability
   is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      Rose.System_Calls.Initialize_Send (Params, Item.Pair);
      Rose.System_Calls.Start_Items (Params);
      Rose.System_Calls.Send_Text_Item (Params, Name);
      Rose.System_Calls.Send_Text_Item (Params, Password);
      Rose.System_Calls.Receive_Caps (Params, 1);
      Rose.System_Calls.Invoke_Capability (Params);
      Last_Error := Rose.Invocation.OK;
      if Params.Control.Flags (Rose.Invocation.Error) then
         Last_Error := Params.Error;
      end if;
      return Params.Caps (0);
   end Pair;

   ------------
   -- Single --
   ------------

   procedure Single (Item : Items_Client; Name : String) is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      Rose.System_Calls.Initialize_Send (Params, Item.Single);
      Rose.System_Calls.Send_Text (Params, Name);
      Rose.System_Calls.Invoke_Capability (Params);
      Last_Error := Rose.Invocation.OK;
      if Params.Control.Flags (Rose.Invocation.Error) then
         Last_Error := Params.Error;
      end if;
   end Single;

   -----------
   -- Store --
   -----------

   procedure Store
     (Item  : Items_Client;
      Index : Rose.Words.Word;
      Key   : String;
      Data  : System.Storage_Elements.Storage_Array;
      Owner : Rose.Capabilities.Capability)
   is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      Rose.System_Calls.Initialize_Send (Params, Item.Store);
      Rose.System_Calls.Start_Items (Params);
      Rose.System_Calls.Send_Word (Params, Index);
      Rose.System_Calls.Send_Text_Item (Params, Key);
      Rose.System_Calls.Send_Storage_Item (Params, Data);
      Rose.System_Calls.Send_Cap (Params, Owner);
      Rose.System_Calls.Invoke_Capability (Params);
      Last_Error := Rose.Invocation.OK;
      if Params.Control.Flags (Rose.Invocation.Error) then
         Last_Error := Params.Error;
      end if;
   end Store;

end Rose.Interfaces.Items.Client;
