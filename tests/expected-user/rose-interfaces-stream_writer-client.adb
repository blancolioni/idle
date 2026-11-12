with Rose.Interfaces.Objects;
with Rose.Invocation;
with Rose.System_Calls;
with System.Storage_Elements;

package body Rose.Interfaces.Stream_Writer.Client is

   procedure Load (Item : in out Stream_Writer_Client);

   -----------
   -- Close --
   -----------

   procedure Close (Client : in out Stream_Writer_Client) is
   begin
      if Client.Is_Open then
         Rose.System_Calls.Delete_Cap (Client.Write);
      end if;
      Client.Is_Open := False;
      Rose.System_Calls.Delete_Cap (Client.Interface_Cap);
   end Close;

   --------------
   -- From_Cap --
   --------------

   function From_Cap
     (Cap : Rose.Capabilities.Capability)
      return Stream_Writer_Client
   is (Stream_Writer_Client'(Interface_Cap => Cap, others => <>));

   -----------------------
   -- Get_Interface_Cap --
   -----------------------

   function Get_Interface_Cap
     (Item : Stream_Writer_Client)
      return Rose.Capabilities.Capability
   is (Item.Interface_Cap);

   -------------------
   -- Get_Write_Cap --
   -------------------

   function Get_Write_Cap
     (Item : in out Stream_Writer_Client)
      return Rose.Capabilities.Capability
   is
   begin
      if not Item.Is_Open then
         Load (Item);
      end if;
      return Item.Write;
   end Get_Write_Cap;

   ----------
   -- Load --
   ----------

   procedure Load (Item : in out Stream_Writer_Client) is
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
                 with "Stream_Writer.Open";
            end if;
         end if;
         Cap := Params.Caps (Rose.Invocation.Capability_Index (Index - First));
         Index := Index + 1;
      end loop;
      Item.Write := Caps (Write_Index + 1);
      Item.Is_Open := True;
   end Load;

   ----------
   -- Open --
   ----------

   procedure Open
     (Client        : out Stream_Writer_Client;
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
     (Client : out Stream_Writer_Client;
      Write  : Rose.Capabilities.Capability)
   is
   begin
      Client.Write := Write;
      Client.Is_Open := True;
   end Open_Cap_Set;

   -----------------------
   -- Stream_Writer_Cap --
   -----------------------

   overriding function Stream_Writer_Cap
     (Item : in out Stream_Writer_Client)
      return Rose.Capabilities.Capability
   is (Item.Interface_Cap);

   -----------
   -- Write --
   -----------

   overriding procedure Write
     (Item   : in out Stream_Writer_Client;
      Buffer : Ada.Streams.Stream_Element_Array)
   is
      Params         : aliased Rose.Invocation.Invocation_Record;
      Buffer_Storage : System.Storage_Elements.Storage_Array
        (1 .. Buffer'Length)
        with Import, Address => Buffer'Address;
   begin
      if not Item.Is_Open then
         Load (Item);
      end if;
      Rose.System_Calls.Initialize_Send (Params, Item.Write);
      Rose.System_Calls.Send_Storage_Array (Params, Buffer_Storage, False);
      Rose.System_Calls.Invoke_Capability (Params);
      if Params.Control.Flags (Rose.Invocation.Error) then
         raise Rose.Interfaces.Objects.Invocation_Error
           with "Stream_Writer.Write";
      end if;
   end Write;

end Rose.Interfaces.Stream_Writer.Client;
