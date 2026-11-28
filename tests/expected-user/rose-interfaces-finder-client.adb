with Rose.Interfaces.Objects;
with Rose.Invocation;
with Rose.System_Calls;
with System.Storage_Elements;

package body Rose.Interfaces.Finder.Client is

   procedure Load (Item : in out Finder_Client);

   -----------
   -- Close --
   -----------

   procedure Close (Client : in out Finder_Client) is
   begin
      if Client.Is_Open then
         Rose.System_Calls.Delete_Cap (Client.Get);
      end if;
      Client.Is_Open := False;
      Rose.System_Calls.Delete_Cap (Client.Interface_Cap);
   end Close;

   ----------------
   -- Finder_Cap --
   ----------------

   overriding function Finder_Cap
     (Item : in out Finder_Client)
      return Rose.Capabilities.Capability
   is (Item.Interface_Cap);

   --------------
   -- From_Cap --
   --------------

   function From_Cap
     (Cap : Rose.Capabilities.Capability)
      return Finder_Client
   is (Finder_Client'(Interface_Cap => Cap, others => <>));

   ---------
   -- Get --
   ---------

   overriding function Get
     (Item  : in out Finder_Client;
      Index : Natural)
      return Rose.Interfaces.Finder.File_Info
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
         raise Rose.Interfaces.Objects.Invocation_Error with "Finder.Get";
      end if;
      declare
         Received : System.Storage_Elements.Storage_Array
           (1 .. System.Storage_Elements.Storage_Count
              (Natural (Rose.System_Calls.Get_Word_32 (Params, 0))));
      begin
         Rose.System_Calls.Copy_Received_Buffer
           (Received'Length,
            Received'Address);
         return Rose.Interfaces.Finder.Decode (Received);
      end;
   end Get;

   -----------------
   -- Get_Get_Cap --
   -----------------

   function Get_Get_Cap
     (Item : in out Finder_Client)
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
     (Item : Finder_Client)
      return Rose.Capabilities.Capability
   is (Item.Interface_Cap);

   ----------
   -- Load --
   ----------

   procedure Load (Item : in out Finder_Client) is
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
                 with "Finder.Open";
            end if;
         end if;
         Cap :=
           Rose.Invocation.Sent_Cap
             (Params,
              Rose.Invocation.Capability_Index (Index - First));
         Index := Index + 1;
      end loop;
      Item.Get := Caps (Get_Index + 1);
      Item.Is_Open := True;
   end Load;

   ----------
   -- Open --
   ----------

   procedure Open
     (Client        : out Finder_Client;
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
     (Client : out Finder_Client;
      Get    : Rose.Capabilities.Capability)
   is
   begin
      Client.Interface_Cap := Rose.Capabilities.Null_Capability;
      Client.Get := Get;
      Client.Is_Open := True;
   end Open_Cap_Set;

end Rose.Interfaces.Finder.Client;
