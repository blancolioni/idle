with Rose.System_Calls;

package body Rose.Interfaces.Flags.Client is

   use type Rose.Invocation.Invocation_Error;

   Last_Error : Rose.Invocation.Invocation_Error := Rose.Invocation.OK;

   -----------
   -- Close --
   -----------

   procedure Close (Client : in out Flags_Client) is
   begin
      Client.Is_Open := False;
      Rose.System_Calls.Delete_Cap (Client.Is_Set);
      Rose.System_Calls.Delete_Cap (Client.Query);
      Rose.System_Calls.Delete_Cap (Client.Toggle);
      Rose.System_Calls.Delete_Cap (Client.Interface_Cap);
   end Close;

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
     (Item : Flags_Client)
      return Rose.Capabilities.Capability
   is (Item.Is_Set);

   --------------------
   -- Get_Last_Error --
   --------------------

   function Get_Last_Error
      return Rose.Invocation.Invocation_Error
   is (Last_Error);

   -------------------
   -- Get_Query_Cap --
   -------------------

   function Get_Query_Cap
     (Item : Flags_Client)
      return Rose.Capabilities.Capability
   is (Item.Query);

   --------------------
   -- Get_Toggle_Cap --
   --------------------

   function Get_Toggle_Cap
     (Item : Flags_Client)
      return Rose.Capabilities.Capability
   is (Item.Toggle);

   ---------------
   -- Has_Error --
   ---------------

   function Has_Error return Boolean is (Last_Error /= Rose.Invocation.OK);

   ------------
   -- Is_Set --
   ------------

   function Is_Set
     (Item    : Flags_Client;
      Name    : String;
      Default : Boolean)
      return Boolean
   is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      Rose.System_Calls.Initialize_Send (Params, Item.Is_Set);
      Rose.System_Calls.Send_Text (Params, Name);
      Rose.System_Calls.Send_Word (Params, Natural (Boolean'Pos (Default)));
      Rose.System_Calls.Receive_Words (Params, 1);
      Rose.System_Calls.Invoke_Capability (Params);
      Last_Error := Rose.Invocation.OK;
      if Params.Control.Flags (Rose.Invocation.Error) then
         Last_Error := Params.Error;
      end if;
      return Rose.System_Calls.Get_Word_32 (Params, 0) /= 0;
   end Is_Set;

   ----------
   -- Open --
   ----------

   procedure Open
     (Client        : out Flags_Client;
      Interface_Cap : Rose.Capabilities.Capability)
   is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      Client.Is_Open := False;
      Client.Interface_Cap := Interface_Cap;
      Rose.System_Calls.Initialize_Send (Params, Interface_Cap);
      Rose.System_Calls.Receive_Caps (Params, Subprogram_Count);
      Rose.System_Calls.Invoke_Capability (Params);
      Client.Is_Set := Params.Caps (Is_Set_Index);
      Client.Query := Params.Caps (Query_Index);
      Client.Toggle := Params.Caps (Toggle_Index);
      Client.Is_Open := True;
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

   procedure Query
     (Item    : Flags_Client;
      Index   : Rose.Words.Word;
      Trusted : out Boolean;
      Count   : out Natural)
   is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      Rose.System_Calls.Initialize_Send (Params, Item.Query);
      Rose.System_Calls.Send_Word (Params, Index);
      Rose.System_Calls.Receive_Words (Params, 2);
      Rose.System_Calls.Invoke_Capability (Params);
      Last_Error := Rose.Invocation.OK;
      if Params.Control.Flags (Rose.Invocation.Error) then
         Last_Error := Params.Error;
      end if;
      Trusted := Rose.System_Calls.Get_Word_32 (Params, 0) /= 0;
      Count := Natural (Rose.System_Calls.Get_Word_32 (Params, 1));
   end Query;

   ------------
   -- Toggle --
   ------------

   procedure Toggle (Item : Flags_Client; Value : in out Boolean) is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      Rose.System_Calls.Initialize_Send (Params, Item.Toggle);
      Rose.System_Calls.Send_Word (Params, Natural (Boolean'Pos (Value)));
      Rose.System_Calls.Receive_Words (Params, 1);
      Rose.System_Calls.Invoke_Capability (Params);
      Last_Error := Rose.Invocation.OK;
      if Params.Control.Flags (Rose.Invocation.Error) then
         Last_Error := Params.Error;
      end if;
      Value := Rose.System_Calls.Get_Word_32 (Params, 0) /= 0;
   end Toggle;

end Rose.Interfaces.Flags.Client;
