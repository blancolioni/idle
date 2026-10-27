with Rose.Interfaces.Objects;
with Rose.Invocation;
with Rose.System_Calls;

package body Rose.Interfaces.Exchange.Client is

   procedure Load (Item : in out Exchange_Client);

   -----------
   -- Close --
   -----------

   procedure Close (Client : in out Exchange_Client) is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      if Client.Is_Open then
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
      end if;
      Client.Is_Open := False;
      Rose.System_Calls.Initialize_Send
        (Params,
         Rose.System_Calls.Delete_Cap_Capability);
      Rose.System_Calls.Send_Cap (Params, Client.Interface_Cap);
      Rose.System_Calls.Invoke_Capability (Params);
   end Close;

   ---------------------
   -- Create_Endpoint --
   ---------------------

   overriding procedure Create_Endpoint
     (Item    : in out Exchange_Client;
      Id      : Rose.Words.Word_64;
      Receive : out Rose.Capabilities.Capability;
      Send    : out Rose.Capabilities.Capability)
   is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      if not Item.Is_Open then
         Load (Item);
      end if;
      Rose.System_Calls.Initialize_Send (Params, Item.Create_Endpoint);
      Rose.System_Calls.Send_Word (Params, Id);
      Rose.System_Calls.Receive_Caps (Params, 2);
      Rose.System_Calls.Invoke_Capability (Params);
      if Params.Control.Flags (Rose.Invocation.Error) then
         raise Rose.Interfaces.Objects.Invocation_Error
           with "Exchange.Create_Endpoint";
      end if;
      Receive := Params.Caps (0);
      Send := Params.Caps (1);
   end Create_Endpoint;

   ------------------
   -- Exchange_Cap --
   ------------------

   overriding function Exchange_Cap
     (Item : in out Exchange_Client)
      return Rose.Capabilities.Capability
   is (Item.Interface_Cap);

   --------------
   -- From_Cap --
   --------------

   function From_Cap
     (Cap : Rose.Capabilities.Capability)
      return Exchange_Client
   is (Exchange_Client'(Interface_Cap => Cap, others => <>));

   ------------
   -- Gather --
   ------------

   overriding procedure Gather
     (Item  : in out Exchange_Client;
      Caps  : Rose.Capabilities.Capability_Array;
      First : out Rose.Capabilities.Capability)
   is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      if not Item.Is_Open then
         Load (Item);
      end if;
      Rose.System_Calls.Initialize_Send (Params, Item.Gather);
      for Cap of Caps loop
         Rose.System_Calls.Send_Cap (Params, Cap);
      end loop;
      Rose.System_Calls.Receive_Caps (Params, 1);
      Rose.System_Calls.Invoke_Capability (Params);
      if Params.Control.Flags (Rose.Invocation.Error) then
         raise Rose.Interfaces.Objects.Invocation_Error with "Exchange.Gather";
      end if;
      First := Params.Caps (0);
   end Gather;

   -----------------------------
   -- Get_Create_Endpoint_Cap --
   -----------------------------

   function Get_Create_Endpoint_Cap
     (Item : in out Exchange_Client)
      return Rose.Capabilities.Capability
   is
   begin
      if not Item.Is_Open then
         Load (Item);
      end if;
      return Item.Create_Endpoint;
   end Get_Create_Endpoint_Cap;

   --------------------
   -- Get_Gather_Cap --
   --------------------

   function Get_Gather_Cap
     (Item : in out Exchange_Client)
      return Rose.Capabilities.Capability
   is
   begin
      if not Item.Is_Open then
         Load (Item);
      end if;
      return Item.Gather;
   end Get_Gather_Cap;

   -----------------------
   -- Get_Interface_Cap --
   -----------------------

   function Get_Interface_Cap
     (Item : Exchange_Client)
      return Rose.Capabilities.Capability
   is (Item.Interface_Cap);

   ---------------------
   -- Get_Partner_Cap --
   ---------------------

   function Get_Partner_Cap
     (Item : in out Exchange_Client)
      return Rose.Capabilities.Capability
   is
   begin
      if not Item.Is_Open then
         Load (Item);
      end if;
      return Item.Partner;
   end Get_Partner_Cap;

   --------------------
   -- Get_Rename_Cap --
   --------------------

   function Get_Rename_Cap
     (Item : in out Exchange_Client)
      return Rose.Capabilities.Capability
   is
   begin
      if not Item.Is_Open then
         Load (Item);
      end if;
      return Item.Rename;
   end Get_Rename_Cap;

   -------------------
   -- Get_Split_Cap --
   -------------------

   function Get_Split_Cap
     (Item : in out Exchange_Client)
      return Rose.Capabilities.Capability
   is
   begin
      if not Item.Is_Open then
         Load (Item);
      end if;
      return Item.Split;
   end Get_Split_Cap;

   ----------
   -- Load --
   ----------

   procedure Load (Item : in out Exchange_Client) is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      Rose.System_Calls.Initialize_Send (Params, Item.Interface_Cap);
      Rose.System_Calls.Receive_Caps (Params, Subprogram_Count);
      Rose.System_Calls.Invoke_Capability (Params);
      if Params.Control.Flags (Rose.Invocation.Error) then
         raise Rose.Interfaces.Objects.Invocation_Error with "Exchange.Open";
      end if;
      Item.Create_Endpoint := Params.Caps (Create_Endpoint_Index);
      Item.Split := Params.Caps (Split_Index);
      Item.Rename := Params.Caps (Rename_Index);
      Item.Partner := Params.Caps (Partner_Index);
      Item.Gather := Params.Caps (Gather_Index);
      Item.Is_Open := True;
   end Load;

   ----------
   -- Open --
   ----------

   procedure Open
     (Client        : out Exchange_Client;
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

   overriding procedure Partner
     (Item  : in out Exchange_Client;
      Other : in out Exchange_Client;
      Label : out Rose.Texts.Text)
   is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      if not Item.Is_Open then
         Load (Item);
      end if;
      Rose.System_Calls.Initialize_Send (Params, Item.Partner);
      Rose.System_Calls.Receive_Buffer (Params, Rose.Texts.Max_Length);
      Rose.System_Calls.Receive_Words (Params, 1);
      Rose.System_Calls.Receive_Caps (Params, 1);
      Rose.System_Calls.Invoke_Capability (Params);
      if Params.Control.Flags (Rose.Invocation.Error) then
         raise Rose.Interfaces.Objects.Invocation_Error
           with "Exchange.Partner";
      end if;
      Open (Other, Params.Caps (0));
      declare
         Received      : String (1 .. Rose.Texts.Max_Length);
         Received_Last : Natural;
      begin
         Rose.System_Calls.Copy_Text
           (Params,
            Natural (Rose.System_Calls.Get_Word_32 (Params, 0)),
            Received,
            Received_Last);
         Label := Rose.Texts.To_Text (Received (1 .. Received_Last));
      end;
   end Partner;

   ------------
   -- Rename --
   ------------

   overriding procedure Rename
     (Item : in out Exchange_Client;
      Cap  : in out Rose.Capabilities.Capability;
      Name : in out Rose.Texts.Text)
   is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      if not Item.Is_Open then
         Load (Item);
      end if;
      Rose.System_Calls.Initialize_Send (Params, Item.Rename);
      Rose.System_Calls.Send_Cap (Params, Cap);
      Rose.System_Calls.Send_Text (Params, Rose.Texts.To_String (Name));
      Params.Control.Flags (Rose.Invocation.Writable_Buffer) := True;
      Rose.System_Calls.Receive_Words (Params, 1);
      Rose.System_Calls.Receive_Caps (Params, 1);
      Rose.System_Calls.Invoke_Capability (Params);
      if Params.Control.Flags (Rose.Invocation.Error) then
         raise Rose.Interfaces.Objects.Invocation_Error with "Exchange.Rename";
      end if;
      Cap := Params.Caps (0);
      declare
         Received      : String (1 .. Rose.Texts.Max_Length);
         Received_Last : Natural;
      begin
         Rose.System_Calls.Copy_Text
           (Params,
            Natural (Rose.System_Calls.Get_Word_32 (Params, 0)),
            Received,
            Received_Last);
         Name := Rose.Texts.To_Text (Received (1 .. Received_Last));
      end;
   end Rename;

   -----------
   -- Split --
   -----------

   overriding function Split
     (Item  : in out Exchange_Client;
      Whole : Rose.Capabilities.Capability;
      Part  : out Rose.Capabilities.Capability)
      return Rose.Capabilities.Capability
   is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      if not Item.Is_Open then
         Load (Item);
      end if;
      Rose.System_Calls.Initialize_Send (Params, Item.Split);
      Rose.System_Calls.Send_Cap (Params, Whole);
      Rose.System_Calls.Receive_Caps (Params, 2);
      Rose.System_Calls.Invoke_Capability (Params);
      if Params.Control.Flags (Rose.Invocation.Error) then
         raise Rose.Interfaces.Objects.Invocation_Error with "Exchange.Split";
      end if;
      Part := Params.Caps (0);
      return Params.Caps (1);
   end Split;

end Rose.Interfaces.Exchange.Client;
