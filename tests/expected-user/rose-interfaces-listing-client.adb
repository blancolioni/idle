with Rose.Interfaces.Objects;
with Rose.Invocation;
with Rose.System_Calls;
with System.Storage_Elements;

package body Rose.Interfaces.Listing.Client is

   procedure Load (Item : in out Listing_Client);

   ---------
   -- Add --
   ---------

   overriding procedure Add
     (Item : in out Listing_Client;
      Info : Rose.Interfaces.Listing.File_Info)
   is
      Params       : aliased Rose.Invocation.Invocation_Record;
      Info_Encoded : constant System.Storage_Elements.Storage_Array :=
        Rose.Interfaces.Listing.Encode (Info);
   begin
      if not Item.Is_Open then
         Load (Item);
      end if;
      Rose.System_Calls.Initialize_Send (Params, Item.Add);
      Rose.System_Calls.Send_Storage_Array (Params, Info_Encoded, False);
      Rose.System_Calls.Invoke_Capability (Params);
      if Params.Control.Flags (Rose.Invocation.Error) then
         raise Rose.Interfaces.Objects.Invocation_Error with "Listing.Add";
      end if;
   end Add;

   -----------
   -- Close --
   -----------

   procedure Close (Client : in out Listing_Client) is
   begin
      if Client.Is_Open then
         Rose.System_Calls.Delete_Cap (Client.Add);
         Rose.System_Calls.Delete_Cap (Client.Rename);
         Rose.System_Calls.Delete_Cap (Client.Find);
         Rose.System_Calls.Delete_Cap (Client.Get);
         Rose.System_Calls.Delete_Cap (Client.Now);
      end if;
      Client.Is_Open := False;
      Rose.System_Calls.Delete_Cap (Client.Interface_Cap);
   end Close;

   ----------
   -- Find --
   ----------

   overriding function Find
     (Item  : in out Listing_Client;
      Index : Natural)
      return Rose.Interfaces.Listing.File_Info
   is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      if not Item.Is_Open then
         Load (Item);
      end if;
      Rose.System_Calls.Initialize_Send (Params, Item.Find);
      Rose.System_Calls.Send_Word (Params, Index);
      Rose.System_Calls.Receive_Words (Params, 1);
      Rose.System_Calls.Receive_Buffer (Params);
      Rose.System_Calls.Invoke_Capability (Params);
      if Params.Control.Flags (Rose.Invocation.Error) then
         raise Rose.Interfaces.Objects.Invocation_Error with "Listing.Find";
      end if;
      declare
         Received : System.Storage_Elements.Storage_Array
           (1 .. System.Storage_Elements.Storage_Count
              (Natural (Rose.System_Calls.Get_Word_32 (Params, 0))));
      begin
         Rose.System_Calls.Copy_Received_Buffer
           (Received'Length,
            Received'Address);
         return Rose.Interfaces.Listing.Decode (Received);
      end;
   end Find;

   --------------
   -- From_Cap --
   --------------

   function From_Cap
     (Cap : Rose.Capabilities.Capability)
      return Listing_Client
   is (Listing_Client'(Interface_Cap => Cap, others => <>));

   ---------
   -- Get --
   ---------

   overriding procedure Get
     (Item  : in out Listing_Client;
      Index : Natural;
      Info  : out Rose.Interfaces.Listing.File_Info;
      Count : out Natural)
   is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      if not Item.Is_Open then
         Load (Item);
      end if;
      Rose.System_Calls.Initialize_Send (Params, Item.Get);
      Rose.System_Calls.Send_Word (Params, Index);
      Rose.System_Calls.Receive_Buffer (Params);
      Rose.System_Calls.Receive_Words (Params, 2);
      Rose.System_Calls.Invoke_Capability (Params);
      if Params.Control.Flags (Rose.Invocation.Error) then
         raise Rose.Interfaces.Objects.Invocation_Error with "Listing.Get";
      end if;
      declare
         Received : System.Storage_Elements.Storage_Array
           (1 .. System.Storage_Elements.Storage_Count
              (Natural (Rose.System_Calls.Get_Word_32 (Params, 0))));
      begin
         Rose.System_Calls.Copy_Received_Buffer
           (Received'Length,
            Received'Address);
         Info := Rose.Interfaces.Listing.Decode (Received);
      end;
      Count := Natural (Rose.System_Calls.Get_Word_32 (Params, 1));
   end Get;

   -----------------
   -- Get_Add_Cap --
   -----------------

   function Get_Add_Cap
     (Item : in out Listing_Client)
      return Rose.Capabilities.Capability
   is
   begin
      if not Item.Is_Open then
         Load (Item);
      end if;
      return Item.Add;
   end Get_Add_Cap;

   ------------------
   -- Get_Find_Cap --
   ------------------

   function Get_Find_Cap
     (Item : in out Listing_Client)
      return Rose.Capabilities.Capability
   is
   begin
      if not Item.Is_Open then
         Load (Item);
      end if;
      return Item.Find;
   end Get_Find_Cap;

   -----------------
   -- Get_Get_Cap --
   -----------------

   function Get_Get_Cap
     (Item : in out Listing_Client)
      return Rose.Capabilities.Capability
   is
   begin
      if not Item.Is_Open then
         Load (Item);
      end if;
      return Item.Get;
   end Get_Get_Cap;

   -----------------------
   -- Get_Interface_Cap --
   -----------------------

   function Get_Interface_Cap
     (Item : Listing_Client)
      return Rose.Capabilities.Capability
   is (Item.Interface_Cap);

   -----------------
   -- Get_Now_Cap --
   -----------------

   function Get_Now_Cap
     (Item : in out Listing_Client)
      return Rose.Capabilities.Capability
   is
   begin
      if not Item.Is_Open then
         Load (Item);
      end if;
      return Item.Now;
   end Get_Now_Cap;

   --------------------
   -- Get_Rename_Cap --
   --------------------

   function Get_Rename_Cap
     (Item : in out Listing_Client)
      return Rose.Capabilities.Capability
   is
   begin
      if not Item.Is_Open then
         Load (Item);
      end if;
      return Item.Rename;
   end Get_Rename_Cap;

   -----------------
   -- Listing_Cap --
   -----------------

   overriding function Listing_Cap
     (Item : in out Listing_Client)
      return Rose.Capabilities.Capability
   is (Item.Interface_Cap);

   ----------
   -- Load --
   ----------

   procedure Load (Item : in out Listing_Client) is
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
                 with "Listing.Open";
            end if;
         end if;
         Cap :=
           Rose.Invocation.Sent_Cap
             (Params,
              Rose.Invocation.Capability_Index (Index - First));
         Index := Index + 1;
      end loop;
      Item.Add := Caps (Add_Index + 1);
      Item.Rename := Caps (Rename_Index + 1);
      Item.Find := Caps (Find_Index + 1);
      Item.Get := Caps (Get_Index + 1);
      Item.Now := Caps (Now_Index + 1);
      Item.Is_Open := True;
   end Load;

   ---------
   -- Now --
   ---------

   overriding function Now
     (Item : in out Listing_Client)
      return Rose.Interfaces.Listing.Stamp
   is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      if not Item.Is_Open then
         Load (Item);
      end if;
      Rose.System_Calls.Initialize_Send (Params, Item.Now);
      Rose.System_Calls.Receive_Words (Params, 1);
      Rose.System_Calls.Receive_Buffer (Params);
      Rose.System_Calls.Invoke_Capability (Params);
      if Params.Control.Flags (Rose.Invocation.Error) then
         raise Rose.Interfaces.Objects.Invocation_Error with "Listing.Now";
      end if;
      declare
         Received : System.Storage_Elements.Storage_Array
           (1 .. System.Storage_Elements.Storage_Count
              (Natural (Rose.System_Calls.Get_Word_32 (Params, 0))));
      begin
         Rose.System_Calls.Copy_Received_Buffer
           (Received'Length,
            Received'Address);
         return Rose.Interfaces.Listing.Decode (Received);
      end;
   end Now;

   ----------
   -- Open --
   ----------

   procedure Open
     (Client        : out Listing_Client;
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
     (Client : out Listing_Client;
      Add    : Rose.Capabilities.Capability;
      Rename : Rose.Capabilities.Capability;
      Find   : Rose.Capabilities.Capability;
      Get    : Rose.Capabilities.Capability;
      Now    : Rose.Capabilities.Capability)
   is
   begin
      Client.Interface_Cap := Rose.Capabilities.Null_Capability;
      Client.Add := Add;
      Client.Rename := Rename;
      Client.Find := Find;
      Client.Get := Get;
      Client.Now := Now;
      Client.Is_Open := True;
   end Open_Cap_Set;

   ------------
   -- Rename --
   ------------

   overriding procedure Rename
     (Item     : in out Listing_Client;
      Info     : Rose.Interfaces.Listing.File_Info;
      New_Name : String)
   is
      Params       : aliased Rose.Invocation.Invocation_Record;
      Info_Encoded : constant System.Storage_Elements.Storage_Array :=
        Rose.Interfaces.Listing.Encode (Info);
   begin
      if not Item.Is_Open then
         Load (Item);
      end if;
      Rose.System_Calls.Initialize_Send (Params, Item.Rename);
      Rose.System_Calls.Start_Items (Params);
      Rose.System_Calls.Send_Storage_Item (Params, Info_Encoded);
      Rose.System_Calls.Send_Text_Item (Params, New_Name);
      Rose.System_Calls.Invoke_Capability (Params);
      if Params.Control.Flags (Rose.Invocation.Error) then
         raise Rose.Interfaces.Objects.Invocation_Error with "Listing.Rename";
      end if;
   end Rename;

end Rose.Interfaces.Listing.Client;
