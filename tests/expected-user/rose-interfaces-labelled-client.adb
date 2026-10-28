with Rose.Interfaces.Objects;
with Rose.Invocation;
with Rose.System_Calls;

package body Rose.Interfaces.Labelled.Client is

   procedure Load (Item : in out Labelled_Client);

   -----------
   -- Badge --
   -----------

   overriding function Badge
     (Item : in out Labelled_Client)
      return Rose.Capabilities.Capability
   is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      if not Item.Is_Open then
         Load (Item);
      end if;
      Rose.System_Calls.Initialize_Send (Params, Item.Badge);
      Rose.System_Calls.Receive_Caps (Params, 1);
      Rose.System_Calls.Invoke_Capability (Params);
      if Params.Control.Flags (Rose.Invocation.Error) then
         raise Rose.Interfaces.Objects.Invocation_Error with "Labelled.Badge";
      end if;
      return Params.Caps (0);
   end Badge;

   -----------
   -- Close --
   -----------

   procedure Close (Client : in out Labelled_Client) is
   begin
      if Client.Is_Open then
         Rose.System_Calls.Delete_Cap (Client.Badge);
         Rose.System_Calls.Delete_Cap (Client.Set_Label);
      end if;
      Client.Is_Open := False;
      Rose.System_Calls.Delete_Cap (Client.Interface_Cap);
   end Close;

   --------------
   -- From_Cap --
   --------------

   function From_Cap
     (Cap : Rose.Capabilities.Capability)
      return Labelled_Client
   is (Labelled_Client'(Interface_Cap => Cap, others => <>));

   -------------------
   -- Get_Badge_Cap --
   -------------------

   function Get_Badge_Cap
     (Item : in out Labelled_Client)
      return Rose.Capabilities.Capability
   is
   begin
      if not Item.Is_Open then
         Load (Item);
      end if;
      return Item.Badge;
   end Get_Badge_Cap;

   -----------------------
   -- Get_Interface_Cap --
   -----------------------

   function Get_Interface_Cap
     (Item : Labelled_Client)
      return Rose.Capabilities.Capability
   is (Item.Interface_Cap);

   -----------------------
   -- Get_Set_Label_Cap --
   -----------------------

   function Get_Set_Label_Cap
     (Item : in out Labelled_Client)
      return Rose.Capabilities.Capability
   is
   begin
      if not Item.Is_Open then
         Load (Item);
      end if;
      return Item.Set_Label;
   end Get_Set_Label_Cap;

   ------------------
   -- Labelled_Cap --
   ------------------

   overriding function Labelled_Cap
     (Item : in out Labelled_Client)
      return Rose.Capabilities.Capability
   is (Item.Interface_Cap);

   ----------
   -- Load --
   ----------

   procedure Load (Item : in out Labelled_Client) is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      Rose.System_Calls.Initialize_Send (Params, Item.Interface_Cap);
      Rose.System_Calls.Receive_Caps (Params, Subprogram_Count);
      Rose.System_Calls.Invoke_Capability (Params);
      if Params.Control.Flags (Rose.Invocation.Error) then
         raise Rose.Interfaces.Objects.Invocation_Error with "Labelled.Open";
      end if;
      Item.Badge := Params.Caps (Badge_Index);
      Item.Set_Label := Params.Caps (Set_Label_Index);
      Item.Is_Open := True;
   end Load;

   ----------
   -- Open --
   ----------

   procedure Open
     (Client        : out Labelled_Client;
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
     (Client    : out Labelled_Client;
      Badge     : Rose.Capabilities.Capability;
      Set_Label : Rose.Capabilities.Capability)
   is
   begin
      Client.Badge := Badge;
      Client.Set_Label := Set_Label;
      Client.Is_Open := True;
   end Open_Cap_Set;

   ---------------
   -- Set_Label --
   ---------------

   overriding procedure Set_Label
     (Item  : in out Labelled_Client;
      Label : Rose.Words.Word)
   is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      if not Item.Is_Open then
         Load (Item);
      end if;
      Rose.System_Calls.Initialize_Send (Params, Item.Set_Label);
      Rose.System_Calls.Send_Word (Params, Label);
      Rose.System_Calls.Invoke_Capability (Params);
      if Params.Control.Flags (Rose.Invocation.Error) then
         raise Rose.Interfaces.Objects.Invocation_Error
           with "Labelled.Set_Label";
      end if;
   end Set_Label;

end Rose.Interfaces.Labelled.Client;
