with Rose.System_Calls;
with Rose.Words;

package body Rose.Interfaces.Boolean_Result.Client is

   use type Rose.Words.Word_32;

   use type Rose.Invocation.Invocation_Error;

   Last_Error : Rose.Invocation.Invocation_Error := Rose.Invocation.OK;

   -----------
   -- Close --
   -----------

   procedure Close (Client : in out Boolean_Result_Client) is
   begin
      Client.Is_Open := False;
      Rose.System_Calls.Delete_Cap (Client.Is_Ready);
      Rose.System_Calls.Delete_Cap (Client.Interface_Cap);
   end Close;

   -----------------------
   -- Get_Interface_Cap --
   -----------------------

   function Get_Interface_Cap
     (Item : Boolean_Result_Client)
      return Rose.Capabilities.Capability
   is (Item.Interface_Cap);

   ----------------------
   -- Get_Is_Ready_Cap --
   ----------------------

   function Get_Is_Ready_Cap
     (Item : Boolean_Result_Client)
      return Rose.Capabilities.Capability
   is (Item.Is_Ready);

   --------------------
   -- Get_Last_Error --
   --------------------

   function Get_Last_Error
      return Rose.Invocation.Invocation_Error
   is (Last_Error);

   ---------------
   -- Has_Error --
   ---------------

   function Has_Error return Boolean is (Last_Error /= Rose.Invocation.OK);

   --------------
   -- Is_Ready --
   --------------

   function Is_Ready (Item : Boolean_Result_Client) return Boolean is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      Rose.System_Calls.Initialize_Send (Params, Item.Is_Ready);
      Rose.System_Calls.Receive_Words (Params, 1);
      Rose.System_Calls.Invoke_Capability (Params);
      Last_Error := Rose.Invocation.OK;
      if Params.Control.Flags (Rose.Invocation.Error) then
         Last_Error := Params.Error;
      end if;
      return Rose.System_Calls.Get_Word_32 (Params, 0) /= 0;
   end Is_Ready;

   ----------
   -- Open --
   ----------

   procedure Open
     (Client        : out Boolean_Result_Client;
      Interface_Cap : Rose.Capabilities.Capability)
   is
      Params : aliased Rose.Invocation.Invocation_Record;
      Caps   : Rose.Capabilities.Capability_Array (1 .. Subprogram_Count);
      Index  : Natural := 0;
      First  : Natural := Natural'Last;
   begin
      Client.Is_Open := False;
      Client.Interface_Cap := Interface_Cap;
      for Cap of Caps loop
         if First > Index
           or else Index - First >= Rose.Invocation.Max_Capabilities
         then
            First := Index;
            Rose.System_Calls.Initialize_Send (Params, Interface_Cap);
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
         end if;
         Cap := Params.Caps (Rose.Invocation.Capability_Index (Index - First));
         Index := Index + 1;
      end loop;
      Client.Is_Ready := Caps (Is_Ready_Index + 1);
      Client.Is_Open := True;
   end Open;

   ------------------
   -- Open_Cap_Set --
   ------------------

   procedure Open_Cap_Set
     (Client   : out Boolean_Result_Client;
      Is_Ready : Rose.Capabilities.Capability)
   is
   begin
      Client.Is_Ready := Is_Ready;
      Client.Is_Open := True;
   end Open_Cap_Set;

end Rose.Interfaces.Boolean_Result.Client;
