with Rose.Interfaces.Objects;
with Rose.Invocation;
with Rose.System_Calls;

package body Rose.Interfaces.Flags.Client is

   procedure Load (Item : in out Flags_Client);

   -----------
   -- Close --
   -----------

   procedure Close (Client : in out Flags_Client) is
   begin
      if Client.Is_Open then
         Rose.System_Calls.Delete_Cap (Client.Is_Set);
         Rose.System_Calls.Delete_Cap (Client.Query);
         Rose.System_Calls.Delete_Cap (Client.Toggle);
      end if;
      Client.Is_Open := False;
      Rose.System_Calls.Delete_Cap (Client.Interface_Cap);
   end Close;

   ---------------
   -- Flags_Cap --
   ---------------

   overriding function Flags_Cap
     (Item : in out Flags_Client)
      return Rose.Capabilities.Capability
   is (Item.Interface_Cap);

   --------------
   -- From_Cap --
   --------------

   function From_Cap
     (Cap : Rose.Capabilities.Capability)
      return Flags_Client
   is (Flags_Client'(Interface_Cap => Cap, others => <>));

   -----------------------
   -- Get_Interface_Cap --
   -----------------------

   function Get_Interface_Cap
     (Item : Flags_Client)
      return Rose.Capabilities.Capability
   is (Item.Interface_Cap);

   --------------------
   -- Get_Is_Set_Cap --
   --------------------

   function Get_Is_Set_Cap
     (Item : in out Flags_Client)
      return Rose.Capabilities.Capability
   is
   begin
      if not Item.Is_Open then
         Load (Item);
      end if;
      return Item.Is_Set;
   end Get_Is_Set_Cap;

   -------------------
   -- Get_Query_Cap --
   -------------------

   function Get_Query_Cap
     (Item : in out Flags_Client)
      return Rose.Capabilities.Capability
   is
   begin
      if not Item.Is_Open then
         Load (Item);
      end if;
      return Item.Query;
   end Get_Query_Cap;

   --------------------
   -- Get_Toggle_Cap --
   --------------------

   function Get_Toggle_Cap
     (Item : in out Flags_Client)
      return Rose.Capabilities.Capability
   is
   begin
      if not Item.Is_Open then
         Load (Item);
      end if;
      return Item.Toggle;
   end Get_Toggle_Cap;

   ------------
   -- Is_Set --
   ------------

   overriding function Is_Set
     (Item    : in out Flags_Client;
      Name    : String;
      Default : Boolean)
      return Boolean
   is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      if not Item.Is_Open then
         Load (Item);
      end if;
      Rose.System_Calls.Initialize_Send (Params, Item.Is_Set);
      Rose.System_Calls.Send_Text (Params, Name);
      Rose.System_Calls.Send_Word (Params, Natural (Boolean'Pos (Default)));
      Rose.System_Calls.Receive_Words (Params, 1);
      Rose.System_Calls.Invoke_Capability (Params);
      if Params.Control.Flags (Rose.Invocation.Error) then
         raise Rose.Interfaces.Objects.Invocation_Error with "Flags.Is_Set";
      end if;
      return Rose.System_Calls.Get_Word_32 (Params, 0) /= 0;
   end Is_Set;

   ----------
   -- Load --
   ----------

   procedure Load (Item : in out Flags_Client) is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      Rose.System_Calls.Initialize_Send (Params, Item.Interface_Cap);
      Rose.System_Calls.Receive_Caps (Params, Subprogram_Count);
      Rose.System_Calls.Invoke_Capability (Params);
      if Params.Control.Flags (Rose.Invocation.Error) then
         raise Rose.Interfaces.Objects.Invocation_Error with "Flags.Open";
      end if;
      Item.Is_Set := Params.Caps (Is_Set_Index);
      Item.Query := Params.Caps (Query_Index);
      Item.Toggle := Params.Caps (Toggle_Index);
      Item.Is_Open := True;
   end Load;

   ----------
   -- Open --
   ----------

   procedure Open
     (Client        : out Flags_Client;
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
     (Client : out Flags_Client;
      Is_Set : Rose.Capabilities.Capability;
      Query  : Rose.Capabilities.Capability;
      Toggle : Rose.Capabilities.Capability)
   is
   begin
      Client.Is_Set := Is_Set;
      Client.Query := Query;
      Client.Toggle := Toggle;
      Client.Is_Open := True;
   end Open_Cap_Set;

   -----------
   -- Query --
   -----------

   overriding procedure Query
     (Item    : in out Flags_Client;
      Index   : Rose.Words.Word;
      Trusted : out Boolean;
      Count   : out Natural)
   is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      if not Item.Is_Open then
         Load (Item);
      end if;
      Rose.System_Calls.Initialize_Send (Params, Item.Query);
      Rose.System_Calls.Send_Word (Params, Index);
      Rose.System_Calls.Receive_Words (Params, 2);
      Rose.System_Calls.Invoke_Capability (Params);
      if Params.Control.Flags (Rose.Invocation.Error) then
         raise Rose.Interfaces.Objects.Invocation_Error with "Flags.Query";
      end if;
      Trusted := Rose.System_Calls.Get_Word_32 (Params, 0) /= 0;
      Count := Natural (Rose.System_Calls.Get_Word_32 (Params, 1));
   end Query;

   ------------
   -- Toggle --
   ------------

   overriding procedure Toggle
     (Item  : in out Flags_Client;
      Value : in out Boolean)
   is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      if not Item.Is_Open then
         Load (Item);
      end if;
      Rose.System_Calls.Initialize_Send (Params, Item.Toggle);
      Rose.System_Calls.Send_Word (Params, Natural (Boolean'Pos (Value)));
      Rose.System_Calls.Receive_Words (Params, 1);
      Rose.System_Calls.Invoke_Capability (Params);
      if Params.Control.Flags (Rose.Invocation.Error) then
         raise Rose.Interfaces.Objects.Invocation_Error with "Flags.Toggle";
      end if;
      Value := Rose.System_Calls.Get_Word_32 (Params, 0) /= 0;
   end Toggle;

end Rose.Interfaces.Flags.Client;
