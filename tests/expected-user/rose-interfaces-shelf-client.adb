with Rose.Interfaces.Objects;
with Rose.Invocation;
with Rose.System_Calls;
with System.Storage_Elements;

package body Rose.Interfaces.Shelf.Client is

   procedure Load (Item : in out Shelf_Client);

   -----------
   -- Close --
   -----------

   procedure Close (Client : in out Shelf_Client) is
   begin
      if Client.Is_Open then
         Rose.System_Calls.Delete_Cap (Client.Put);
         Rose.System_Calls.Delete_Cap (Client.Get);
         Rose.System_Calls.Delete_Cap (Client.Get_Old);
         Rose.System_Calls.Delete_Cap (Client.Pack);
      end if;
      Client.Is_Open := False;
      Rose.System_Calls.Delete_Cap (Client.Interface_Cap);
   end Close;

   --------------
   -- From_Cap --
   --------------

   function From_Cap
     (Cap : Rose.Capabilities.Capability)
      return Shelf_Client
   is (Shelf_Client'(Interface_Cap => Cap, others => <>));

   ---------
   -- Get --
   ---------

   overriding function Get
     (Item  : in out Shelf_Client;
      Index : Natural)
      return Rose.Interfaces.Shelf.File_Info
   is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      if not Item.Is_Open then
         Load (Item);
      end if;
      Rose.System_Calls.Initialize_Send (Params, Item.Get);
      Rose.System_Calls.Send_Word (Params, Index);
      Rose.System_Calls.Receive_Words (Params, 1);
      Rose.System_Calls.Receive_Buffer (Params);
      Rose.System_Calls.Invoke_Capability (Params);
      if Params.Control.Flags (Rose.Invocation.Error) then
         raise Rose.Interfaces.Objects.Invocation_Error with "Shelf.Get";
      end if;
      declare
         Received : System.Storage_Elements.Storage_Array
           (1 .. System.Storage_Elements.Storage_Count
              (Natural (Rose.System_Calls.Get_Word_32 (Params, 0))));
      begin
         Rose.System_Calls.Copy_Received_Buffer
           (Received'Length,
            Received'Address);
         return Rose.Interfaces.Shelf.Decode (Received);
      end;
   end Get;

   -----------------
   -- Get_Get_Cap --
   -----------------

   function Get_Get_Cap
     (Item : in out Shelf_Client)
      return Rose.Capabilities.Capability
   is
   begin
      if not Item.Is_Open then
         Load (Item);
      end if;
      return Item.Get;
   end Get_Get_Cap;

   ---------------------
   -- Get_Get_Old_Cap --
   ---------------------

   function Get_Get_Old_Cap
     (Item : in out Shelf_Client)
      return Rose.Capabilities.Capability
   is
   begin
      if not Item.Is_Open then
         Load (Item);
      end if;
      return Item.Get_Old;
   end Get_Get_Old_Cap;

   -----------------------
   -- Get_Interface_Cap --
   -----------------------

   function Get_Interface_Cap
     (Item : Shelf_Client)
      return Rose.Capabilities.Capability
   is (Item.Interface_Cap);

   -------------
   -- Get_Old --
   -------------

   overriding function Get_Old
     (Item  : in out Shelf_Client;
      Index : Natural)
      return Rose.Interfaces.Shelf.File_Info_V1
   is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      if not Item.Is_Open then
         Load (Item);
      end if;
      Rose.System_Calls.Initialize_Send (Params, Item.Get_Old);
      Rose.System_Calls.Send_Word (Params, Index);
      Rose.System_Calls.Receive_Words (Params, 1);
      Rose.System_Calls.Receive_Buffer (Params);
      Rose.System_Calls.Invoke_Capability (Params);
      if Params.Control.Flags (Rose.Invocation.Error) then
         raise Rose.Interfaces.Objects.Invocation_Error with "Shelf.Get_Old";
      end if;
      declare
         Received : System.Storage_Elements.Storage_Array
           (1 .. System.Storage_Elements.Storage_Count
              (Natural (Rose.System_Calls.Get_Word_32 (Params, 0))));
      begin
         Rose.System_Calls.Copy_Received_Buffer
           (Received'Length,
            Received'Address);
         return Rose.Interfaces.Shelf.Decode (Received);
      end;
   end Get_Old;

   ------------------
   -- Get_Pack_Cap --
   ------------------

   function Get_Pack_Cap
     (Item : in out Shelf_Client)
      return Rose.Capabilities.Capability
   is
   begin
      if not Item.Is_Open then
         Load (Item);
      end if;
      return Item.Pack;
   end Get_Pack_Cap;

   -----------------
   -- Get_Put_Cap --
   -----------------

   function Get_Put_Cap
     (Item : in out Shelf_Client)
      return Rose.Capabilities.Capability
   is
   begin
      if not Item.Is_Open then
         Load (Item);
      end if;
      return Item.Put;
   end Get_Put_Cap;

   ----------
   -- Load --
   ----------

   procedure Load (Item : in out Shelf_Client) is
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
                 with "Shelf.Open";
            end if;
         end if;
         Cap :=
           Rose.Invocation.Sent_Cap
             (Params,
              Rose.Invocation.Capability_Index (Index - First));
         Index := Index + 1;
      end loop;
      Item.Put := Caps (Put_Index + 1);
      Item.Get := Caps (Get_Index + 1);
      Item.Get_Old := Caps (Get_Old_Index + 1);
      Item.Pack := Caps (Pack_Index + 1);
      Item.Is_Open := True;
   end Load;

   ----------
   -- Open --
   ----------

   procedure Open
     (Client        : out Shelf_Client;
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
     (Client  : out Shelf_Client;
      Put     : Rose.Capabilities.Capability;
      Get     : Rose.Capabilities.Capability;
      Get_Old : Rose.Capabilities.Capability;
      Pack    : Rose.Capabilities.Capability)
   is
   begin
      Client.Interface_Cap := Rose.Capabilities.Null_Capability;
      Client.Put := Put;
      Client.Get := Get;
      Client.Get_Old := Get_Old;
      Client.Pack := Pack;
      Client.Is_Open := True;
   end Open_Cap_Set;

   ----------
   -- Pack --
   ----------

   overriding function Pack
     (Item : in out Shelf_Client)
      return Rose.Interfaces.Shelf.Bundle
   is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      if not Item.Is_Open then
         Load (Item);
      end if;
      Rose.System_Calls.Initialize_Send (Params, Item.Pack);
      Rose.System_Calls.Receive_Words (Params, 1);
      Rose.System_Calls.Receive_Buffer (Params);
      Rose.System_Calls.Invoke_Capability (Params);
      if Params.Control.Flags (Rose.Invocation.Error) then
         raise Rose.Interfaces.Objects.Invocation_Error with "Shelf.Pack";
      end if;
      declare
         Received : System.Storage_Elements.Storage_Array
           (1 .. System.Storage_Elements.Storage_Count
              (Natural (Rose.System_Calls.Get_Word_32 (Params, 0))));
      begin
         Rose.System_Calls.Copy_Received_Buffer
           (Received'Length,
            Received'Address);
         return Rose.Interfaces.Shelf.Decode (Received);
      end;
   end Pack;

   ---------
   -- Put --
   ---------

   overriding procedure Put
     (Item : in out Shelf_Client;
      Info : Rose.Interfaces.Shelf.File_Info_V1)
   is
      Params       : aliased Rose.Invocation.Invocation_Record;
      Info_Encoded : constant System.Storage_Elements.Storage_Array :=
        Rose.Interfaces.Shelf.Encode (Info);
   begin
      if not Item.Is_Open then
         Load (Item);
      end if;
      Rose.System_Calls.Initialize_Send (Params, Item.Put);
      Rose.System_Calls.Send_Storage_Array (Params, Info_Encoded, False);
      Rose.System_Calls.Invoke_Capability (Params);
      if Params.Control.Flags (Rose.Invocation.Error) then
         raise Rose.Interfaces.Objects.Invocation_Error with "Shelf.Put";
      end if;
   end Put;

   ---------------
   -- Shelf_Cap --
   ---------------

   overriding function Shelf_Cap
     (Item : in out Shelf_Client)
      return Rose.Capabilities.Capability
   is (Item.Interface_Cap);

end Rose.Interfaces.Shelf.Client;
