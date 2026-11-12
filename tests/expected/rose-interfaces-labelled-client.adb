with Rose.System_Calls;

package body Rose.Interfaces.Labelled.Client is

   use type Rose.Invocation.Invocation_Error;

   Last_Error : Rose.Invocation.Invocation_Error := Rose.Invocation.OK;

   -----------
   -- Badge --
   -----------

   function Badge
     (Item : Labelled_Client)
      return Rose.Capabilities.Capability
   is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      Rose.System_Calls.Initialize_Send (Params, Item.Badge);
      Rose.System_Calls.Receive_Caps (Params, 1);
      Rose.System_Calls.Invoke_Capability (Params);
      Last_Error := Rose.Invocation.OK;
      if Params.Control.Flags (Rose.Invocation.Error) then
         Last_Error := Params.Error;
      end if;
      return Params.Caps (0);
   end Badge;

   -----------
   -- Close --
   -----------

   procedure Close (Client : in out Labelled_Client) is
   begin
      Client.Is_Open := False;
      Rose.System_Calls.Delete_Cap (Client.Badge);
      Rose.System_Calls.Delete_Cap (Client.Set_Label);
      Rose.System_Calls.Delete_Cap (Client.Interface_Cap);
   end Close;

   -------------------
   -- Get_Badge_Cap --
   -------------------

   function Get_Badge_Cap
     (Item : Labelled_Client)
      return Rose.Capabilities.Capability
   is (Item.Badge);

   -----------------------
   -- Get_Interface_Cap --
   -----------------------

   function Get_Interface_Cap
     (Item : Labelled_Client)
      return Rose.Capabilities.Capability
   is (Item.Interface_Cap);

   --------------------
   -- Get_Last_Error --
   --------------------

   function Get_Last_Error
      return Rose.Invocation.Invocation_Error
   is (Last_Error);

   -----------------------
   -- Get_Set_Label_Cap --
   -----------------------

   function Get_Set_Label_Cap
     (Item : Labelled_Client)
      return Rose.Capabilities.Capability
   is (Item.Set_Label);

   ---------------
   -- Has_Error --
   ---------------

   function Has_Error return Boolean is (Last_Error /= Rose.Invocation.OK);

   ----------
   -- Open --
   ----------

   procedure Open
     (Client        : out Labelled_Client;
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
      Client.Badge := Caps (Badge_Index + 1);
      Client.Set_Label := Caps (Set_Label_Index + 1);
      Client.Is_Open := True;
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

   procedure Set_Label (Item : Labelled_Client; Label : Rose.Words.Word) is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      Rose.System_Calls.Initialize_Send (Params, Item.Set_Label);
      Rose.System_Calls.Send_Word (Params, Label);
      Rose.System_Calls.Invoke_Capability (Params);
      Last_Error := Rose.Invocation.OK;
      if Params.Control.Flags (Rose.Invocation.Error) then
         Last_Error := Params.Error;
      end if;
   end Set_Label;

end Rose.Interfaces.Labelled.Client;
