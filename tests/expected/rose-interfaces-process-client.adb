with Rose.System_Calls;

package body Rose.Interfaces.Process.Client is

   use type Rose.Invocation.Invocation_Error;

   Last_Error : Rose.Invocation.Invocation_Error := Rose.Invocation.OK;

   -------------------------------
   -- Add_Nonpersistent_Segment --
   -------------------------------

   procedure Add_Nonpersistent_Segment
     (Item          : Process_Client;
      Virtual_Base  : Rose.Words.Word;
      Virtual_Bound : Rose.Words.Word;
      Flags         : Rose.Words.Word)
   is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      Rose.System_Calls.Initialize_Send
        (Params,
         Item.Add_Nonpersistent_Segment);
      Rose.System_Calls.Send_Word (Params, Virtual_Base);
      Rose.System_Calls.Send_Word (Params, Virtual_Bound);
      Rose.System_Calls.Send_Word (Params, Flags);
      Rose.System_Calls.Invoke_Capability (Params);
      Last_Error := Rose.Invocation.OK;
      if Params.Control.Flags (Rose.Invocation.Error) then
         Last_Error := Params.Error;
      end if;
   end Add_Nonpersistent_Segment;

   -----------------
   -- Add_Segment --
   -----------------

   procedure Add_Segment
     (Item          : Process_Client;
      Virtual_Base  : Rose.Words.Word;
      Virtual_Bound : Rose.Words.Word;
      Region        : Rose.Interfaces.Region.Client.Region_Client;
      Region_Offset : Rose.Words.Word;
      Flags         : Rose.Words.Word)
   is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      Rose.System_Calls.Initialize_Send (Params, Item.Add_Segment);
      Rose.System_Calls.Send_Word (Params, Virtual_Base);
      Rose.System_Calls.Send_Word (Params, Virtual_Bound);
      Rose.System_Calls.Send_Cap
        (Params,
         Rose.Interfaces.Region.Client.Get_Interface_Cap (Region));
      Rose.System_Calls.Send_Word (Params, Region_Offset);
      Rose.System_Calls.Send_Word (Params, Flags);
      Rose.System_Calls.Invoke_Capability (Params);
      Last_Error := Rose.Invocation.OK;
      if Params.Control.Flags (Rose.Invocation.Error) then
         Last_Error := Params.Error;
      end if;
   end Add_Segment;

   -----------
   -- Close --
   -----------

   procedure Close (Client : in out Process_Client) is
   begin
      Client.Is_Open := False;
      Rose.System_Calls.Delete_Cap (Client.Add_Segment);
      Rose.System_Calls.Delete_Cap (Client.Add_Nonpersistent_Segment);
      Rose.System_Calls.Delete_Cap (Client.Published_Interface);
      Rose.System_Calls.Delete_Cap (Client.Destroy);
      Rose.System_Calls.Delete_Cap (Client.Get_Object_Id);
      Rose.System_Calls.Delete_Cap (Client.Heap_Interface);
      Rose.System_Calls.Delete_Cap (Client.Exit_Process);
      Rose.System_Calls.Delete_Cap (Client.Publish_Interface);
      Rose.System_Calls.Delete_Cap (Client.Interface_Cap);
   end Close;

   -------------
   -- Destroy --
   -------------

   procedure Destroy (Item : Process_Client) is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      Rose.System_Calls.Initialize_Send (Params, Item.Destroy);
      Rose.System_Calls.Invoke_Capability (Params);
      Last_Error := Rose.Invocation.OK;
      if Params.Control.Flags (Rose.Invocation.Error) then
         Last_Error := Params.Error;
      end if;
   end Destroy;

   ------------------
   -- Exit_Process --
   ------------------

   procedure Exit_Process (Item : Process_Client; Exit_Status : Natural) is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      Rose.System_Calls.Initialize_Send (Params, Item.Exit_Process);
      Rose.System_Calls.Send_Word (Params, Exit_Status);
      Rose.System_Calls.Invoke_Capability (Params);
      Last_Error := Rose.Invocation.OK;
      if Params.Control.Flags (Rose.Invocation.Error) then
         Last_Error := Params.Error;
      end if;
   end Exit_Process;

   ---------------------------------------
   -- Get_Add_Nonpersistent_Segment_Cap --
   ---------------------------------------

   function Get_Add_Nonpersistent_Segment_Cap
     (Item : Process_Client)
      return Rose.Capabilities.Capability
   is (Item.Add_Nonpersistent_Segment);

   -------------------------
   -- Get_Add_Segment_Cap --
   -------------------------

   function Get_Add_Segment_Cap
     (Item : Process_Client)
      return Rose.Capabilities.Capability
   is (Item.Add_Segment);

   ---------------------
   -- Get_Destroy_Cap --
   ---------------------

   function Get_Destroy_Cap
     (Item : Process_Client)
      return Rose.Capabilities.Capability
   is (Item.Destroy);

   --------------------------
   -- Get_Exit_Process_Cap --
   --------------------------

   function Get_Exit_Process_Cap
     (Item : Process_Client)
      return Rose.Capabilities.Capability
   is (Item.Exit_Process);

   ---------------------------
   -- Get_Get_Object_Id_Cap --
   ---------------------------

   function Get_Get_Object_Id_Cap
     (Item : Process_Client)
      return Rose.Capabilities.Capability
   is (Item.Get_Object_Id);

   ----------------------------
   -- Get_Heap_Interface_Cap --
   ----------------------------

   function Get_Heap_Interface_Cap
     (Item : Process_Client)
      return Rose.Capabilities.Capability
   is (Item.Heap_Interface);

   -----------------------
   -- Get_Interface_Cap --
   -----------------------

   function Get_Interface_Cap
     (Item : Process_Client)
      return Rose.Capabilities.Capability
   is (Item.Interface_Cap);

   --------------------
   -- Get_Last_Error --
   --------------------

   function Get_Last_Error
      return Rose.Invocation.Invocation_Error
   is (Last_Error);

   -------------------
   -- Get_Object_Id --
   -------------------

   function Get_Object_Id
     (Item : Process_Client)
      return Rose.Objects.Object_Id
   is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      Rose.System_Calls.Initialize_Send (Params, Item.Get_Object_Id);
      Rose.System_Calls.Receive_Words (Params, 2);
      Rose.System_Calls.Invoke_Capability (Params);
      Last_Error := Rose.Invocation.OK;
      if Params.Control.Flags (Rose.Invocation.Error) then
         Last_Error := Params.Error;
      end if;
      return Rose.System_Calls.Get_Object_Id (Params, 0);
   end Get_Object_Id;

   -------------------------------
   -- Get_Publish_Interface_Cap --
   -------------------------------

   function Get_Publish_Interface_Cap
     (Item : Process_Client)
      return Rose.Capabilities.Capability
   is (Item.Publish_Interface);

   ---------------------------------
   -- Get_Published_Interface_Cap --
   ---------------------------------

   function Get_Published_Interface_Cap
     (Item : Process_Client)
      return Rose.Capabilities.Capability
   is (Item.Published_Interface);

   ---------------
   -- Has_Error --
   ---------------

   function Has_Error return Boolean is (Last_Error /= Rose.Invocation.OK);

   --------------------
   -- Heap_Interface --
   --------------------

   function Heap_Interface
     (Item : Process_Client)
      return Rose.Interfaces.Heap.Client.Heap_Client
   is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      Rose.System_Calls.Initialize_Send (Params, Item.Heap_Interface);
      Rose.System_Calls.Receive_Caps (Params, 1);
      Rose.System_Calls.Invoke_Capability (Params);
      Last_Error := Rose.Invocation.OK;
      if Params.Control.Flags (Rose.Invocation.Error) then
         Last_Error := Params.Error;
      end if;
      declare
         Result : Rose.Interfaces.Heap.Client.Heap_Client;
      begin
         Rose.Interfaces.Heap.Client.Open (Result, Params.Caps (0));
         return Result;
      end;
   end Heap_Interface;

   ----------
   -- Open --
   ----------

   procedure Open
     (Client        : out Process_Client;
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
      Client.Add_Segment := Caps (Add_Segment_Index + 1);
      Client.Add_Nonpersistent_Segment :=
        Caps (Add_Nonpersistent_Segment_Index + 1);
      Client.Published_Interface := Caps (Published_Interface_Index + 1);
      Client.Destroy := Caps (Destroy_Index + 1);
      Client.Get_Object_Id := Caps (Get_Object_Id_Index + 1);
      Client.Heap_Interface := Caps (Heap_Interface_Index + 1);
      Client.Exit_Process := Caps (Exit_Process_Index + 1);
      Client.Publish_Interface := Caps (Publish_Interface_Index + 1);
      Client.Is_Open := True;
   end Open;

   ------------------
   -- Open_Cap_Set --
   ------------------

   procedure Open_Cap_Set
     (Client                    : out Process_Client;
      Add_Segment               : Rose.Capabilities.Capability;
      Add_Nonpersistent_Segment : Rose.Capabilities.Capability;
      Published_Interface       : Rose.Capabilities.Capability;
      Destroy                   : Rose.Capabilities.Capability;
      Get_Object_Id             : Rose.Capabilities.Capability;
      Heap_Interface            : Rose.Capabilities.Capability;
      Exit_Process              : Rose.Capabilities.Capability;
      Publish_Interface         : Rose.Capabilities.Capability)
   is
   begin
      Client.Add_Segment := Add_Segment;
      Client.Add_Nonpersistent_Segment := Add_Nonpersistent_Segment;
      Client.Published_Interface := Published_Interface;
      Client.Destroy := Destroy;
      Client.Get_Object_Id := Get_Object_Id;
      Client.Heap_Interface := Heap_Interface;
      Client.Exit_Process := Exit_Process;
      Client.Publish_Interface := Publish_Interface;
      Client.Is_Open := True;
   end Open_Cap_Set;

   -----------------------
   -- Publish_Interface --
   -----------------------

   procedure Publish_Interface
     (Item          : Process_Client;
      Interface_Cap : Rose.Capabilities.Capability)
   is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      Rose.System_Calls.Initialize_Send (Params, Item.Publish_Interface);
      Rose.System_Calls.Send_Cap (Params, Interface_Cap);
      Rose.System_Calls.Invoke_Capability (Params);
      Last_Error := Rose.Invocation.OK;
      if Params.Control.Flags (Rose.Invocation.Error) then
         Last_Error := Params.Error;
      end if;
   end Publish_Interface;

   -------------------------
   -- Published_Interface --
   -------------------------

   function Published_Interface
     (Item : Process_Client)
      return Rose.Capabilities.Capability
   is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      Rose.System_Calls.Initialize_Send (Params, Item.Published_Interface);
      Rose.System_Calls.Receive_Caps (Params, 1);
      Rose.System_Calls.Invoke_Capability (Params);
      Last_Error := Rose.Invocation.OK;
      if Params.Control.Flags (Rose.Invocation.Error) then
         Last_Error := Params.Error;
      end if;
      return Params.Caps (0);
   end Published_Interface;

end Rose.Interfaces.Process.Client;
