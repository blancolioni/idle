with Rose.Interfaces.Objects;
with Rose.Invocation;
with Rose.System_Calls;

package body Rose.Interfaces.Seekable.Client is

   procedure Load (Item : in out Seekable_Client);

   -----------
   -- Close --
   -----------

   procedure Close (Client : in out Seekable_Client) is
   begin
      if Client.Is_Open then
         Rose.System_Calls.Delete_Cap (Client.Seek);
      end if;
      Client.Is_Open := False;
      Rose.System_Calls.Delete_Cap (Client.Interface_Cap);
   end Close;

   --------------
   -- From_Cap --
   --------------

   function From_Cap
     (Cap : Rose.Capabilities.Capability)
      return Seekable_Client
   is (Seekable_Client'(Interface_Cap => Cap, others => <>));

   -----------------------
   -- Get_Interface_Cap --
   -----------------------

   function Get_Interface_Cap
     (Item : Seekable_Client)
      return Rose.Capabilities.Capability
   is (Item.Interface_Cap);

   ------------------
   -- Get_Seek_Cap --
   ------------------

   function Get_Seek_Cap
     (Item : in out Seekable_Client)
      return Rose.Capabilities.Capability
   is
   begin
      if not Item.Is_Open then
         Load (Item);
      end if;
      return Item.Seek;
   end Get_Seek_Cap;

   ----------
   -- Load --
   ----------

   procedure Load (Item : in out Seekable_Client) is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      Rose.System_Calls.Initialize_Send (Params, Item.Interface_Cap);
      Rose.System_Calls.Receive_Caps (Params, Subprogram_Count);
      Rose.System_Calls.Invoke_Capability (Params);
      if Params.Control.Flags (Rose.Invocation.Error) then
         raise Rose.Interfaces.Objects.Invocation_Error with "Seekable.Open";
      end if;
      Item.Seek := Params.Caps (Seek_Index);
      Item.Is_Open := True;
   end Load;

   ----------
   -- Open --
   ----------

   procedure Open
     (Client        : out Seekable_Client;
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
     (Client : out Seekable_Client;
      Seek   : Rose.Capabilities.Capability)
   is
   begin
      Client.Seek := Seek;
      Client.Is_Open := True;
   end Open_Cap_Set;

   ----------
   -- Seek --
   ----------

   overriding procedure Seek
     (Item              : in out Seekable_Client;
      Offset_From_Start : Rose.Words.Word_64)
   is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      if not Item.Is_Open then
         Load (Item);
      end if;
      Rose.System_Calls.Initialize_Send (Params, Item.Seek);
      Rose.System_Calls.Send_Word (Params, Offset_From_Start);
      Rose.System_Calls.Invoke_Capability (Params);
      if Params.Control.Flags (Rose.Invocation.Error) then
         raise Rose.Interfaces.Objects.Invocation_Error with "Seekable.Seek";
      end if;
   end Seek;

   ------------------
   -- Seekable_Cap --
   ------------------

   overriding function Seekable_Cap
     (Item : in out Seekable_Client)
      return Rose.Capabilities.Capability
   is (Item.Interface_Cap);

end Rose.Interfaces.Seekable.Client;
