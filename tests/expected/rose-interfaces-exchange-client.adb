with Rose.System_Calls;

package body Rose.Interfaces.Exchange.Client is

   use type Rose.Invocation.Invocation_Error;

   Last_Error : Rose.Invocation.Invocation_Error := Rose.Invocation.OK;

   -----------
   -- Close --
   -----------

   procedure Close (Client : in out Exchange_Client) is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      Client.Is_Open := False;
      Rose.System_Calls.Initialize_Send
        (Params,
         Rose.System_Calls.Delete_Cap_Capability);
      Rose.System_Calls.Send_Cap (Params, Client.Create_Endpoint);
      Rose.System_Calls.Invoke_Capability (Params);
      Rose.System_Calls.Initialize_Send
        (Params,
         Rose.System_Calls.Delete_Cap_Capability);
      Rose.System_Calls.Send_Cap (Params, Client.Split);
      Rose.System_Calls.Invoke_Capability (Params);
      Rose.System_Calls.Initialize_Send
        (Params,
         Rose.System_Calls.Delete_Cap_Capability);
      Rose.System_Calls.Send_Cap (Params, Client.Rename);
      Rose.System_Calls.Invoke_Capability (Params);
      Rose.System_Calls.Initialize_Send
        (Params,
         Rose.System_Calls.Delete_Cap_Capability);
      Rose.System_Calls.Send_Cap (Params, Client.Partner);
      Rose.System_Calls.Invoke_Capability (Params);
      Rose.System_Calls.Initialize_Send
        (Params,
         Rose.System_Calls.Delete_Cap_Capability);
      Rose.System_Calls.Send_Cap (Params, Client.Gather);
      Rose.System_Calls.Invoke_Capability (Params);
      Rose.System_Calls.Initialize_Send
        (Params,
         Rose.System_Calls.Delete_Cap_Capability);
      Rose.System_Calls.Send_Cap (Params, Client.Interface_Cap);
      Rose.System_Calls.Invoke_Capability (Params);
   end Close;

   ---------------------
   -- Create_Endpoint --
   ---------------------

   procedure Create_Endpoint
     (Item    : Exchange_Client;
      Id      : Rose.Words.Word_64;
      Receive : out Rose.Capabilities.Capability;
      Send    : out Rose.Capabilities.Capability)
   is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      Rose.System_Calls.Initialize_Send (Params, Item.Create_Endpoint);
      Rose.System_Calls.Send_Word (Params, Id);
      Rose.System_Calls.Receive_Caps (Params, 2);
      Rose.System_Calls.Invoke_Capability (Params);
      Last_Error := Rose.Invocation.OK;
      if Params.Control.Flags (Rose.Invocation.Error) then
         Last_Error := Params.Error;
      end if;
      Receive := Params.Caps (0);
      Send := Params.Caps (1);
   end Create_Endpoint;

   ------------
   -- Gather --
   ------------

   procedure Gather
     (Item  : Exchange_Client;
      Caps  : Rose.Capabilities.Capability_Array;
      First : out Rose.Capabilities.Capability)
   is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      Rose.System_Calls.Initialize_Send (Params, Item.Gather);
      for Cap of Caps loop
         Rose.System_Calls.Send_Cap (Params, Cap);
      end loop;
      Rose.System_Calls.Receive_Caps (Params, 1);
      Rose.System_Calls.Invoke_Capability (Params);
      Last_Error := Rose.Invocation.OK;
      if Params.Control.Flags (Rose.Invocation.Error) then
         Last_Error := Params.Error;
      end if;
      First := Params.Caps (0);
   end Gather;

   -----------------------------
   -- Get_Create_Endpoint_Cap --
   -----------------------------

   function Get_Create_Endpoint_Cap
     (Item : Exchange_Client)
      return Rose.Capabilities.Capability
   is (Item.Create_Endpoint);

   --------------------
   -- Get_Gather_Cap --
   --------------------

   function Get_Gather_Cap
     (Item : Exchange_Client)
      return Rose.Capabilities.Capability
   is (Item.Gather);

   -----------------------
   -- Get_Interface_Cap --
   -----------------------

   function Get_Interface_Cap
     (Item : Exchange_Client)
      return Rose.Capabilities.Capability
   is (Item.Interface_Cap);

   --------------------
   -- Get_Last_Error --
   --------------------

   function Get_Last_Error
      return Rose.Invocation.Invocation_Error
   is (Last_Error);

   ---------------------
   -- Get_Partner_Cap --
   ---------------------

   function Get_Partner_Cap
     (Item : Exchange_Client)
      return Rose.Capabilities.Capability
   is (Item.Partner);

   --------------------
   -- Get_Rename_Cap --
   --------------------

   function Get_Rename_Cap
     (Item : Exchange_Client)
      return Rose.Capabilities.Capability
   is (Item.Rename);

   -------------------
   -- Get_Split_Cap --
   -------------------

   function Get_Split_Cap
     (Item : Exchange_Client)
      return Rose.Capabilities.Capability
   is (Item.Split);

   ---------------
   -- Has_Error --
   ---------------

   function Has_Error return Boolean is (Last_Error /= Rose.Invocation.OK);

   ----------
   -- Open --
   ----------

   procedure Open
     (Client        : out Exchange_Client;
      Interface_Cap : Rose.Capabilities.Capability)
   is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      Client.Is_Open := False;
      Client.Interface_Cap := Interface_Cap;
      Rose.System_Calls.Initialize_Send (Params, Interface_Cap);
      Rose.System_Calls.Receive_Caps (Params, Subprogram_Count);
      Rose.System_Calls.Invoke_Capability (Params);
      Client.Create_Endpoint := Params.Caps (Create_Endpoint_Index);
      Client.Split := Params.Caps (Split_Index);
      Client.Rename := Params.Caps (Rename_Index);
      Client.Partner := Params.Caps (Partner_Index);
      Client.Gather := Params.Caps (Gather_Index);
      Client.Is_Open := True;
   end Open;

   ------------------
   -- Open_Cap_Set --
   ------------------

   procedure Open_Cap_Set
     (Client          : out Exchange_Client;
      Create_Endpoint : Rose.Capabilities.Capability;
      Split           : Rose.Capabilities.Capability;
      Rename          : Rose.Capabilities.Capability;
      Partner         : Rose.Capabilities.Capability;
      Gather          : Rose.Capabilities.Capability)
   is
   begin
      Client.Create_Endpoint := Create_Endpoint;
      Client.Split := Split;
      Client.Rename := Rename;
      Client.Partner := Partner;
      Client.Gather := Gather;
      Client.Is_Open := True;
   end Open_Cap_Set;

   -------------
   -- Partner --
   -------------

   procedure Partner
     (Item       : Exchange_Client;
      Other      : out Exchange_Client;
      Label      : out String;
      Label_Last : out Natural)
   is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      Rose.System_Calls.Initialize_Send (Params, Item.Partner);
      Rose.System_Calls.Receive_Buffer (Params, Label'Length);
      Rose.System_Calls.Receive_Words (Params, 1);
      Rose.System_Calls.Receive_Caps (Params, 1);
      Rose.System_Calls.Invoke_Capability (Params);
      Last_Error := Rose.Invocation.OK;
      if Params.Control.Flags (Rose.Invocation.Error) then
         Last_Error := Params.Error;
      end if;
      Open (Other, Params.Caps (0));
      Rose.System_Calls.Copy_Text
        (Params,
         Natural (Rose.System_Calls.Get_Word_32 (Params, 0)),
         Label,
         Label_Last);
   end Partner;

   ------------
   -- Rename --
   ------------

   procedure Rename
     (Item      : Exchange_Client;
      Cap       : in out Rose.Capabilities.Capability;
      Name      : in out String;
      Name_Last : out Natural)
   is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      Rose.System_Calls.Initialize_Send (Params, Item.Rename);
      Rose.System_Calls.Send_Cap (Params, Cap);
      Rose.System_Calls.Send_Text (Params, Name);
      Params.Control.Flags (Rose.Invocation.Writable_Buffer) := True;
      Rose.System_Calls.Receive_Words (Params, 1);
      Rose.System_Calls.Receive_Caps (Params, 1);
      Rose.System_Calls.Invoke_Capability (Params);
      Last_Error := Rose.Invocation.OK;
      if Params.Control.Flags (Rose.Invocation.Error) then
         Last_Error := Params.Error;
      end if;
      Cap := Params.Caps (0);
      Rose.System_Calls.Copy_Text
        (Params,
         Natural (Rose.System_Calls.Get_Word_32 (Params, 0)),
         Name,
         Name_Last);
   end Rename;

   -----------
   -- Split --
   -----------

   function Split
     (Item  : Exchange_Client;
      Whole : Rose.Capabilities.Capability;
      Part  : out Rose.Capabilities.Capability)
      return Rose.Capabilities.Capability
   is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      Rose.System_Calls.Initialize_Send (Params, Item.Split);
      Rose.System_Calls.Send_Cap (Params, Whole);
      Rose.System_Calls.Receive_Caps (Params, 2);
      Rose.System_Calls.Invoke_Capability (Params);
      Last_Error := Rose.Invocation.OK;
      if Params.Control.Flags (Rose.Invocation.Error) then
         Last_Error := Params.Error;
      end if;
      Part := Params.Caps (0);
      return Params.Caps (1);
   end Split;

end Rose.Interfaces.Exchange.Client;
