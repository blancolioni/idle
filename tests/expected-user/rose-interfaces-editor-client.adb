with Rose.Interfaces.Objects;
with Rose.Invocation;
with Rose.System_Calls;
with System.Storage_Elements;

package body Rose.Interfaces.Editor.Client is

   procedure Load (Item : in out Editor_Client);

   -----------
   -- Close --
   -----------

   procedure Close (Client : in out Editor_Client) is
   begin
      if Client.Is_Open then
         Rose.System_Calls.Delete_Cap (Client.Show);
      end if;
      Client.Is_Open := False;
      Rose.System_Calls.Delete_Cap (Client.Interface_Cap);
   end Close;

   ----------------
   -- Editor_Cap --
   ----------------

   overriding function Editor_Cap
     (Item : in out Editor_Client)
      return Rose.Capabilities.Capability
   is (Item.Interface_Cap);

   --------------
   -- From_Cap --
   --------------

   function From_Cap
     (Cap : Rose.Capabilities.Capability)
      return Editor_Client
   is (Editor_Client'(Interface_Cap => Cap, others => <>));

   -----------------------
   -- Get_Interface_Cap --
   -----------------------

   function Get_Interface_Cap
     (Item : Editor_Client)
      return Rose.Capabilities.Capability
   is (Item.Interface_Cap);

   ------------------
   -- Get_Show_Cap --
   ------------------

   function Get_Show_Cap
     (Item : in out Editor_Client)
      return Rose.Capabilities.Capability
   is
   begin
      if not Item.Is_Open then
         Load (Item);
      end if;
      return Item.Show;
   end Get_Show_Cap;

   ----------
   -- Load --
   ----------

   procedure Load (Item : in out Editor_Client) is
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
                 with "Editor.Open";
            end if;
         end if;
         Cap :=
           Rose.Invocation.Sent_Cap
             (Params,
              Rose.Invocation.Capability_Index (Index - First));
         Index := Index + 1;
      end loop;
      Item.Show := Caps (Show_Index + 1);
      Item.Is_Open := True;
   end Load;

   ----------
   -- Open --
   ----------

   procedure Open
     (Client        : out Editor_Client;
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
     (Client : out Editor_Client;
      Show   : Rose.Capabilities.Capability)
   is
   begin
      Client.Interface_Cap := Rose.Capabilities.Null_Capability;
      Client.Show := Show;
      Client.Is_Open := True;
   end Open_Cap_Set;

   ----------
   -- Show --
   ----------

   overriding procedure Show
     (Item  : in out Editor_Client;
      Place : Rose.Interfaces.Editor.Location)
   is
      Params        : aliased Rose.Invocation.Invocation_Record;
      Place_Encoded : constant System.Storage_Elements.Storage_Array :=
        Rose.Interfaces.Editor.Encode (Place);
   begin
      if not Item.Is_Open then
         Load (Item);
      end if;
      Rose.System_Calls.Initialize_Send (Params, Item.Show);
      Rose.System_Calls.Send_Storage_Array (Params, Place_Encoded, False);
      Rose.System_Calls.Invoke_Capability (Params);
      if Params.Control.Flags (Rose.Invocation.Error) then
         raise Rose.Interfaces.Objects.Invocation_Error with "Editor.Show";
      end if;
   end Show;

end Rose.Interfaces.Editor.Client;
