with Rose.Interfaces.Objects;
with Rose.Invocation;
with Rose.System_Calls;

package body Rose.Interfaces.Cap.Client is

   procedure Load (Item : in out Cap_Client);

   -------------
   -- Cap_Cap --
   -------------

   overriding function Cap_Cap
     (Item : in out Cap_Client)
      return Rose.Capabilities.Capability
   is (Item.Interface_Cap);

   -----------
   -- Close --
   -----------

   procedure Close (Client : in out Cap_Client) is
   begin
      if Client.Is_Open then
         Rose.System_Calls.Delete_Cap (Client.Destroy);
         Rose.System_Calls.Delete_Cap (Client.Get_Object_Id);
      end if;
      Client.Is_Open := False;
      Rose.System_Calls.Delete_Cap (Client.Interface_Cap);
   end Close;

   -------------
   -- Destroy --
   -------------

   overriding procedure Destroy (Item : in out Cap_Client) is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      if not Item.Is_Open then
         Load (Item);
      end if;
      Rose.System_Calls.Initialize_Send (Params, Item.Destroy);
      Rose.System_Calls.Invoke_Capability (Params);
      if Params.Control.Flags (Rose.Invocation.Error) then
         raise Rose.Interfaces.Objects.Invocation_Error with "Cap.Destroy";
      end if;
   end Destroy;

   --------------
   -- From_Cap --
   --------------

   function From_Cap
     (Cap : Rose.Capabilities.Capability)
      return Cap_Client
   is (Cap_Client'(Interface_Cap => Cap, others => <>));

   ---------------------
   -- Get_Destroy_Cap --
   ---------------------

   function Get_Destroy_Cap
     (Item : in out Cap_Client)
      return Rose.Capabilities.Capability
   is
   begin
      if not Item.Is_Open then
         Load (Item);
      end if;
      return Item.Destroy;
   end Get_Destroy_Cap;

   ---------------------------
   -- Get_Get_Object_Id_Cap --
   ---------------------------

   function Get_Get_Object_Id_Cap
     (Item : in out Cap_Client)
      return Rose.Capabilities.Capability
   is
   begin
      if not Item.Is_Open then
         Load (Item);
      end if;
      return Item.Get_Object_Id;
   end Get_Get_Object_Id_Cap;

   -----------------------
   -- Get_Interface_Cap --
   -----------------------

   function Get_Interface_Cap
     (Item : Cap_Client)
      return Rose.Capabilities.Capability
   is (Item.Interface_Cap);

   -------------------
   -- Get_Object_Id --
   -------------------

   overriding function Get_Object_Id
     (Item : in out Cap_Client)
      return Rose.Objects.Object_Id
   is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      if not Item.Is_Open then
         Load (Item);
      end if;
      Rose.System_Calls.Initialize_Send (Params, Item.Get_Object_Id);
      Rose.System_Calls.Receive_Words (Params, 2);
      Rose.System_Calls.Invoke_Capability (Params);
      if Params.Control.Flags (Rose.Invocation.Error) then
         raise Rose.Interfaces.Objects.Invocation_Error
           with "Cap.Get_Object_Id";
      end if;
      return Rose.System_Calls.Get_Object_Id (Params, 0);
   end Get_Object_Id;

   ----------
   -- Load --
   ----------

   procedure Load (Item : in out Cap_Client) is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      Rose.System_Calls.Initialize_Send (Params, Item.Interface_Cap);
      Rose.System_Calls.Receive_Caps (Params, Subprogram_Count);
      Rose.System_Calls.Invoke_Capability (Params);
      if Params.Control.Flags (Rose.Invocation.Error) then
         raise Rose.Interfaces.Objects.Invocation_Error with "Cap.Open";
      end if;
      Item.Destroy := Params.Caps (Destroy_Index);
      Item.Get_Object_Id := Params.Caps (Get_Object_Id_Index);
      Item.Is_Open := True;
   end Load;

   ----------
   -- Open --
   ----------

   procedure Open
     (Client        : out Cap_Client;
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
     (Client        : out Cap_Client;
      Destroy       : Rose.Capabilities.Capability;
      Get_Object_Id : Rose.Capabilities.Capability)
   is
   begin
      Client.Destroy := Destroy;
      Client.Get_Object_Id := Get_Object_Id;
      Client.Is_Open := True;
   end Open_Cap_Set;

end Rose.Interfaces.Cap.Client;
