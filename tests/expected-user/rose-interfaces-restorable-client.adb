with Rose.Interfaces.Objects;
with Rose.Invocation;
with Rose.System_Calls;

package body Rose.Interfaces.Restorable.Client is

   -----------
   -- Close --
   -----------

   procedure Close (Client : in out Restorable_Client) is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      Client.Is_Open := False;
      Rose.System_Calls.Initialize_Send
        (Params,
         Rose.System_Calls.Delete_Cap_Capability);
      Rose.System_Calls.Send_Cap (Params, Client.Restored);
      Rose.System_Calls.Invoke_Capability (Params);
      Rose.System_Calls.Initialize_Send
        (Params,
         Rose.System_Calls.Delete_Cap_Capability);
      Rose.System_Calls.Send_Cap (Params, Client.Interface_Cap);
      Rose.System_Calls.Invoke_Capability (Params);
   end Close;

   -----------------------
   -- Get_Interface_Cap --
   -----------------------

   function Get_Interface_Cap
     (Item : Restorable_Client)
      return Rose.Capabilities.Capability
   is (Item.Interface_Cap);

   ----------------------
   -- Get_Restored_Cap --
   ----------------------

   function Get_Restored_Cap
     (Item : Restorable_Client)
      return Rose.Capabilities.Capability
   is (Item.Restored);

   ----------
   -- Open --
   ----------

   procedure Open
     (Client        : out Restorable_Client;
      Interface_Cap : Rose.Capabilities.Capability)
   is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      Client.Is_Open := False;
      Client.Interface_Cap := Interface_Cap;
      Rose.System_Calls.Initialize_Send (Params, Interface_Cap);
      Rose.System_Calls.Receive_Caps (Params, Subprogram_Count);
      Rose.System_Calls.Invoke_Capability (Params);
      Client.Restored := Params.Caps (Restored_Index);
      Client.Is_Open := True;
   end Open;

   ------------------
   -- Open_Cap_Set --
   ------------------

   procedure Open_Cap_Set
     (Client   : out Restorable_Client;
      Restored : Rose.Capabilities.Capability)
   is
   begin
      Client.Restored := Restored;
      Client.Is_Open := True;
   end Open_Cap_Set;

   --------------
   -- Restored --
   --------------

   overriding procedure Restored (Item : in out Restorable_Client) is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      Rose.System_Calls.Initialize_Send (Params, Item.Restored);
      Rose.System_Calls.Invoke_Capability (Params);
      if Params.Control.Flags (Rose.Invocation.Error) then
         raise Rose.Interfaces.Objects.Invocation_Error
           with "Restorable.Restored";
      end if;
   end Restored;

end Rose.Interfaces.Restorable.Client;
