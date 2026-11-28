with Rose.Interfaces.Objects;
with Rose.Invocation;
with Rose.System_Calls;
with Rose.Words;
with System.Storage_Elements;

package body Rose.Interfaces.Catalogue.Client is

   procedure Load (Item : in out Catalogue_Client);

   -------------------
   -- Catalogue_Cap --
   -------------------

   overriding function Catalogue_Cap
     (Item : in out Catalogue_Client)
      return Rose.Capabilities.Capability
   is (Item.Interface_Cap);

   -----------
   -- Close --
   -----------

   procedure Close (Client : in out Catalogue_Client) is
   begin
      if Client.Is_Open then
         Rose.System_Calls.Delete_Cap (Client.Total);
         Rose.System_Calls.Delete_Cap (Client.Resize);
         Rose.System_Calls.Delete_Cap (Client.Find);
      end if;
      Client.Is_Open := False;
      Rose.System_Calls.Delete_Cap (Client.Interface_Cap);
   end Close;

   ----------
   -- Find --
   ----------

   overriding function Find
     (Item  : in out Catalogue_Client;
      Index : Natural)
      return Rose.Interfaces.Catalogue.Entry_Info
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
         raise Rose.Interfaces.Objects.Invocation_Error with "Catalogue.Find";
      end if;
      declare
         Received : System.Storage_Elements.Storage_Array
           (1 .. System.Storage_Elements.Storage_Count
              (Natural (Rose.System_Calls.Get_Word_32 (Params, 0))));
      begin
         Rose.System_Calls.Copy_Received_Buffer
           (Received'Length,
            Received'Address);
         return Rose.Interfaces.Catalogue.Decode (Received);
      end;
   end Find;

   --------------
   -- From_Cap --
   --------------

   function From_Cap
     (Cap : Rose.Capabilities.Capability)
      return Catalogue_Client
   is (Catalogue_Client'(Interface_Cap => Cap, others => <>));

   ------------------
   -- Get_Find_Cap --
   ------------------

   function Get_Find_Cap
     (Item : in out Catalogue_Client)
      return Rose.Capabilities.Capability
   is
   begin
      if not Item.Is_Open then
         Load (Item);
      end if;
      return Item.Find;
   end Get_Find_Cap;

   -----------------------
   -- Get_Interface_Cap --
   -----------------------

   function Get_Interface_Cap
     (Item : Catalogue_Client)
      return Rose.Capabilities.Capability
   is (Item.Interface_Cap);

   --------------------
   -- Get_Resize_Cap --
   --------------------

   function Get_Resize_Cap
     (Item : in out Catalogue_Client)
      return Rose.Capabilities.Capability
   is
   begin
      if not Item.Is_Open then
         Load (Item);
      end if;
      return Item.Resize;
   end Get_Resize_Cap;

   -------------------
   -- Get_Total_Cap --
   -------------------

   function Get_Total_Cap
     (Item : in out Catalogue_Client)
      return Rose.Capabilities.Capability
   is
   begin
      if not Item.Is_Open then
         Load (Item);
      end if;
      return Item.Total;
   end Get_Total_Cap;

   ----------
   -- Load --
   ----------

   procedure Load (Item : in out Catalogue_Client) is
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
                 with "Catalogue.Open";
            end if;
         end if;
         Cap :=
           Rose.Invocation.Sent_Cap
             (Params,
              Rose.Invocation.Capability_Index (Index - First));
         Index := Index + 1;
      end loop;
      Item.Total := Caps (Total_Index + 1);
      Item.Resize := Caps (Resize_Index + 1);
      Item.Find := Caps (Find_Index + 1);
      Item.Is_Open := True;
   end Load;

   ----------
   -- Open --
   ----------

   procedure Open
     (Client        : out Catalogue_Client;
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
     (Client : out Catalogue_Client;
      Total  : Rose.Capabilities.Capability;
      Resize : Rose.Capabilities.Capability;
      Find   : Rose.Capabilities.Capability)
   is
   begin
      Client.Interface_Cap := Rose.Capabilities.Null_Capability;
      Client.Total := Total;
      Client.Resize := Resize;
      Client.Find := Find;
      Client.Is_Open := True;
   end Open_Cap_Set;

   ------------
   -- Resize --
   ------------

   overriding procedure Resize
     (Item : in out Catalogue_Client;
      Size : Rose.Interfaces.Core.Units.Bytes;
      Done : out Rose.Interfaces.Core.Units.Percent)
   is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      if not Item.Is_Open then
         Load (Item);
      end if;
      Rose.System_Calls.Initialize_Send (Params, Item.Resize);
      Rose.System_Calls.Send_Word (Params, Rose.Words.Word_64 (Size));
      Rose.System_Calls.Receive_Words (Params, 1);
      Rose.System_Calls.Invoke_Capability (Params);
      if Params.Control.Flags (Rose.Invocation.Error) then
         raise Rose.Interfaces.Objects.Invocation_Error
           with "Catalogue.Resize";
      end if;
      Done :=
        Rose.Interfaces.Core.Units.Percent
          (Rose.System_Calls.Get_Word_32 (Params, 0));
   end Resize;

   -----------
   -- Total --
   -----------

   overriding function Total
     (Item : in out Catalogue_Client)
      return Rose.Interfaces.Core.Units.Bytes
   is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      if not Item.Is_Open then
         Load (Item);
      end if;
      Rose.System_Calls.Initialize_Send (Params, Item.Total);
      Rose.System_Calls.Receive_Words (Params, 2);
      Rose.System_Calls.Invoke_Capability (Params);
      if Params.Control.Flags (Rose.Invocation.Error) then
         raise Rose.Interfaces.Objects.Invocation_Error with "Catalogue.Total";
      end if;
      return Rose.Interfaces.Core.Units.Bytes
        (Rose.System_Calls.Get_Word_64 (Params, 0));
   end Total;

end Rose.Interfaces.Catalogue.Client;
