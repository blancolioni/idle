with Rose.Interfaces.Objects;
with Rose.Invocation;
with Rose.System_Calls;

package body Rose.Interfaces.Resource.Client is

   procedure Load (Item : in out Resource_Client);

   -----------
   -- Close --
   -----------

   procedure Close (Client : in out Resource_Client) is
      use type Rose.Capabilities.Capability;
   begin
      if Client.Is_Open
        or else Client.Interface_Cap /= Rose.Capabilities.Null_Capability
      then
         Release (Client);
      end if;
      if Client.Is_Open then
         Rose.System_Calls.Delete_Cap (Client.Release);
      end if;
      Client.Is_Open := False;
      Rose.System_Calls.Delete_Cap (Client.Interface_Cap);
   end Close;

   --------------
   -- From_Cap --
   --------------

   function From_Cap
     (Cap : Rose.Capabilities.Capability)
      return Resource_Client
   is (Resource_Client'(Interface_Cap => Cap, others => <>));

   -----------------------
   -- Get_Interface_Cap --
   -----------------------

   function Get_Interface_Cap
     (Item : Resource_Client)
      return Rose.Capabilities.Capability
   is (Item.Interface_Cap);

   ---------------------
   -- Get_Release_Cap --
   ---------------------

   function Get_Release_Cap
     (Item : in out Resource_Client)
      return Rose.Capabilities.Capability
   is
   begin
      if not Item.Is_Open then
         Load (Item);
      end if;
      return Item.Release;
   end Get_Release_Cap;

   ----------
   -- Load --
   ----------

   procedure Load (Item : in out Resource_Client) is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      Rose.System_Calls.Initialize_Send (Params, Item.Interface_Cap);
      Rose.System_Calls.Receive_Caps (Params, Subprogram_Count);
      Rose.System_Calls.Invoke_Capability (Params);
      if Params.Control.Flags (Rose.Invocation.Error) then
         raise Rose.Interfaces.Objects.Invocation_Error with "Resource.Open";
      end if;
      Item.Release := Params.Caps (Release_Index);
      Item.Is_Open := True;
   end Load;

   ----------
   -- Open --
   ----------

   procedure Open
     (Client        : out Resource_Client;
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
     (Client  : out Resource_Client;
      Release : Rose.Capabilities.Capability)
   is
   begin
      Client.Release := Release;
      Client.Is_Open := True;
   end Open_Cap_Set;

   -------------
   -- Release --
   -------------

   overriding procedure Release (Item : in out Resource_Client) is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      if not Item.Is_Open then
         Load (Item);
      end if;
      Rose.System_Calls.Initialize_Send (Params, Item.Release);
      Rose.System_Calls.Invoke_Capability (Params);
      if Params.Control.Flags (Rose.Invocation.Error) then
         raise Rose.Interfaces.Objects.Invocation_Error
           with "Resource.Release";
      end if;
   end Release;

   ------------------
   -- Resource_Cap --
   ------------------

   overriding function Resource_Cap
     (Item : in out Resource_Client)
      return Rose.Capabilities.Capability
   is (Item.Interface_Cap);

end Rose.Interfaces.Resource.Client;
