with Rose.Interfaces.Objects;
with Rose.Invocation;
with Rose.System_Calls;
with Rose.Words;

package body Rose.Interfaces.Boolean_Out.Client is

   use type Rose.Words.Word_32;

   procedure Load (Item : in out Boolean_Out_Client);

   ---------------------
   -- Boolean_Out_Cap --
   ---------------------

   overriding function Boolean_Out_Cap
     (Item : in out Boolean_Out_Client)
      return Rose.Capabilities.Capability
   is (Item.Interface_Cap);

   -----------
   -- Close --
   -----------

   procedure Close (Client : in out Boolean_Out_Client) is
   begin
      if Client.Is_Open then
         Rose.System_Calls.Delete_Cap (Client.Get);
      end if;
      Client.Is_Open := False;
      Rose.System_Calls.Delete_Cap (Client.Interface_Cap);
   end Close;

   --------------
   -- From_Cap --
   --------------

   function From_Cap
     (Cap : Rose.Capabilities.Capability)
      return Boolean_Out_Client
   is (Boolean_Out_Client'(Interface_Cap => Cap, others => <>));

   ---------
   -- Get --
   ---------

   overriding procedure Get
     (Item : in out Boolean_Out_Client;
      On   : out Boolean)
   is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      if not Item.Is_Open then
         Load (Item);
      end if;
      Rose.System_Calls.Initialize_Send (Params, Item.Get);
      Rose.System_Calls.Receive_Words (Params, 1);
      Rose.System_Calls.Invoke_Capability (Params);
      if Params.Control.Flags (Rose.Invocation.Error) then
         raise Rose.Interfaces.Objects.Invocation_Error with "Boolean_Out.Get";
      end if;
      On := Rose.System_Calls.Get_Word_32 (Params, 0) /= 0;
   end Get;

   -----------------
   -- Get_Get_Cap --
   -----------------

   function Get_Get_Cap
     (Item : in out Boolean_Out_Client)
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
     (Item : Boolean_Out_Client)
      return Rose.Capabilities.Capability
   is (Item.Interface_Cap);

   ----------
   -- Load --
   ----------

   procedure Load (Item : in out Boolean_Out_Client) is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      Rose.System_Calls.Initialize_Send (Params, Item.Interface_Cap);
      Rose.System_Calls.Receive_Caps (Params, Subprogram_Count);
      Rose.System_Calls.Invoke_Capability (Params);
      if Params.Control.Flags (Rose.Invocation.Error) then
         raise Rose.Interfaces.Objects.Invocation_Error
           with "Boolean_Out.Open";
      end if;
      Item.Get := Params.Caps (Get_Index);
      Item.Is_Open := True;
   end Load;

   ----------
   -- Open --
   ----------

   procedure Open
     (Client        : out Boolean_Out_Client;
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
     (Client : out Boolean_Out_Client;
      Get    : Rose.Capabilities.Capability)
   is
   begin
      Client.Get := Get;
      Client.Is_Open := True;
   end Open_Cap_Set;

end Rose.Interfaces.Boolean_Out.Client;
