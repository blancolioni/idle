with Rose.System_Calls;

package body Rose.Interfaces.Boolean_In.Client is

   use type Rose.Invocation.Invocation_Error;

   Last_Error : Rose.Invocation.Invocation_Error := Rose.Invocation.OK;

   -----------
   -- Close --
   -----------

   procedure Close (Client : in out Boolean_In_Client) is
   begin
      Client.Is_Open := False;
      Rose.System_Calls.Delete_Cap (Client.Set);
      Rose.System_Calls.Delete_Cap (Client.Interface_Cap);
   end Close;

   -----------------------
   -- Get_Interface_Cap --
   -----------------------

   function Get_Interface_Cap
     (Item : Boolean_In_Client)
      return Rose.Capabilities.Capability
   is (Item.Interface_Cap);

   --------------------
   -- Get_Last_Error --
   --------------------

   function Get_Last_Error
      return Rose.Invocation.Invocation_Error
   is (Last_Error);

   -----------------
   -- Get_Set_Cap --
   -----------------

   function Get_Set_Cap
     (Item : Boolean_In_Client)
      return Rose.Capabilities.Capability
   is (Item.Set);

   ---------------
   -- Has_Error --
   ---------------

   function Has_Error return Boolean is (Last_Error /= Rose.Invocation.OK);

   ----------
   -- Open --
   ----------

   procedure Open
     (Client        : out Boolean_In_Client;
      Interface_Cap : Rose.Capabilities.Capability)
   is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      Client.Is_Open := False;
      Client.Interface_Cap := Interface_Cap;
      Rose.System_Calls.Initialize_Send (Params, Interface_Cap);
      Rose.System_Calls.Receive_Caps (Params, Subprogram_Count);
      Rose.System_Calls.Invoke_Capability (Params);
      Client.Set := Params.Caps (Set_Index);
      Client.Is_Open := True;
   end Open;

   ------------------
   -- Open_Cap_Set --
   ------------------

   procedure Open_Cap_Set
     (Client : out Boolean_In_Client;
      Set    : Rose.Capabilities.Capability)
   is
   begin
      Client.Set := Set;
      Client.Is_Open := True;
   end Open_Cap_Set;

   ---------
   -- Set --
   ---------

   procedure Set (Item : Boolean_In_Client; On : Boolean) is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      Rose.System_Calls.Initialize_Send (Params, Item.Set);
      Rose.System_Calls.Send_Word (Params, Natural (Boolean'Pos (On)));
      Rose.System_Calls.Invoke_Capability (Params);
      Last_Error := Rose.Invocation.OK;
      if Params.Control.Flags (Rose.Invocation.Error) then
         Last_Error := Params.Error;
      end if;
   end Set;

end Rose.Interfaces.Boolean_In.Client;
