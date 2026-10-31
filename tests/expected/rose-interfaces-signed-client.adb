with Rose.System_Calls;

package body Rose.Interfaces.Signed.Client is

   use type Rose.Invocation.Invocation_Error;

   Last_Error : Rose.Invocation.Invocation_Error := Rose.Invocation.OK;

   ------------
   -- Bounds --
   ------------

   procedure Bounds
     (Item : Signed_Client;
      Low  : out Standard.Interfaces.Integer_64;
      High : out Standard.Interfaces.Integer_64)
   is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      Rose.System_Calls.Initialize_Send (Params, Item.Bounds);
      Rose.System_Calls.Receive_Words (Params, 4);
      Rose.System_Calls.Invoke_Capability (Params);
      Last_Error := Rose.Invocation.OK;
      if Params.Control.Flags (Rose.Invocation.Error) then
         Last_Error := Params.Error;
      end if;
      Low := Rose.System_Calls.Get_Integer_64 (Params, 0);
      High := Rose.System_Calls.Get_Integer_64 (Params, 2);
   end Bounds;

   -----------
   -- Clamp --
   -----------

   function Clamp
     (Item  : Signed_Client;
      Value : Standard.Interfaces.Integer_32;
      Low   : Standard.Interfaces.Integer_32)
      return Standard.Interfaces.Integer_32
   is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      Rose.System_Calls.Initialize_Send (Params, Item.Clamp);
      Rose.System_Calls.Send_Integer_32 (Params, Value);
      Rose.System_Calls.Send_Integer_32 (Params, Low);
      Rose.System_Calls.Receive_Words (Params, 1);
      Rose.System_Calls.Invoke_Capability (Params);
      Last_Error := Rose.Invocation.OK;
      if Params.Control.Flags (Rose.Invocation.Error) then
         Last_Error := Params.Error;
      end if;
      return Rose.System_Calls.Get_Integer_32 (Params, 0);
   end Clamp;

   -----------
   -- Close --
   -----------

   procedure Close (Client : in out Signed_Client) is
   begin
      Client.Is_Open := False;
      Rose.System_Calls.Delete_Cap (Client.Clamp);
      Rose.System_Calls.Delete_Cap (Client.Position);
      Rose.System_Calls.Delete_Cap (Client.Offset);
      Rose.System_Calls.Delete_Cap (Client.Difference);
      Rose.System_Calls.Delete_Cap (Client.Bounds);
      Rose.System_Calls.Delete_Cap (Client.Interface_Cap);
   end Close;

   ----------------
   -- Difference --
   ----------------

   function Difference
     (Item  : Signed_Client;
      Left  : Standard.Interfaces.Integer_64;
      Right : Standard.Interfaces.Integer_64)
      return Standard.Interfaces.Integer_64
   is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      Rose.System_Calls.Initialize_Send (Params, Item.Difference);
      Rose.System_Calls.Send_Integer_64 (Params, Left);
      Rose.System_Calls.Send_Integer_64 (Params, Right);
      Rose.System_Calls.Receive_Words (Params, 2);
      Rose.System_Calls.Invoke_Capability (Params);
      Last_Error := Rose.Invocation.OK;
      if Params.Control.Flags (Rose.Invocation.Error) then
         Last_Error := Params.Error;
      end if;
      return Rose.System_Calls.Get_Integer_64 (Params, 0);
   end Difference;

   --------------------
   -- Get_Bounds_Cap --
   --------------------

   function Get_Bounds_Cap
     (Item : Signed_Client)
      return Rose.Capabilities.Capability
   is (Item.Bounds);

   -------------------
   -- Get_Clamp_Cap --
   -------------------

   function Get_Clamp_Cap
     (Item : Signed_Client)
      return Rose.Capabilities.Capability
   is (Item.Clamp);

   ------------------------
   -- Get_Difference_Cap --
   ------------------------

   function Get_Difference_Cap
     (Item : Signed_Client)
      return Rose.Capabilities.Capability
   is (Item.Difference);

   -----------------------
   -- Get_Interface_Cap --
   -----------------------

   function Get_Interface_Cap
     (Item : Signed_Client)
      return Rose.Capabilities.Capability
   is (Item.Interface_Cap);

   --------------------
   -- Get_Last_Error --
   --------------------

   function Get_Last_Error
      return Rose.Invocation.Invocation_Error
   is (Last_Error);

   --------------------
   -- Get_Offset_Cap --
   --------------------

   function Get_Offset_Cap
     (Item : Signed_Client)
      return Rose.Capabilities.Capability
   is (Item.Offset);

   ----------------------
   -- Get_Position_Cap --
   ----------------------

   function Get_Position_Cap
     (Item : Signed_Client)
      return Rose.Capabilities.Capability
   is (Item.Position);

   ---------------
   -- Has_Error --
   ---------------

   function Has_Error return Boolean is (Last_Error /= Rose.Invocation.OK);

   ------------
   -- Offset --
   ------------

   procedure Offset
     (Item    : Signed_Client;
      Delta_X : in out Standard.Interfaces.Integer_32)
   is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      Rose.System_Calls.Initialize_Send (Params, Item.Offset);
      Rose.System_Calls.Send_Integer_32 (Params, Delta_X);
      Rose.System_Calls.Receive_Words (Params, 1);
      Rose.System_Calls.Invoke_Capability (Params);
      Last_Error := Rose.Invocation.OK;
      if Params.Control.Flags (Rose.Invocation.Error) then
         Last_Error := Params.Error;
      end if;
      Delta_X := Rose.System_Calls.Get_Integer_32 (Params, 0);
   end Offset;

   ----------
   -- Open --
   ----------

   procedure Open
     (Client        : out Signed_Client;
      Interface_Cap : Rose.Capabilities.Capability)
   is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      Client.Is_Open := False;
      Client.Interface_Cap := Interface_Cap;
      Rose.System_Calls.Initialize_Send (Params, Interface_Cap);
      Rose.System_Calls.Receive_Caps (Params, Subprogram_Count);
      Rose.System_Calls.Invoke_Capability (Params);
      Client.Clamp := Params.Caps (Clamp_Index);
      Client.Position := Params.Caps (Position_Index);
      Client.Offset := Params.Caps (Offset_Index);
      Client.Difference := Params.Caps (Difference_Index);
      Client.Bounds := Params.Caps (Bounds_Index);
      Client.Is_Open := True;
   end Open;

   ------------------
   -- Open_Cap_Set --
   ------------------

   procedure Open_Cap_Set
     (Client     : out Signed_Client;
      Clamp      : Rose.Capabilities.Capability;
      Position   : Rose.Capabilities.Capability;
      Offset     : Rose.Capabilities.Capability;
      Difference : Rose.Capabilities.Capability;
      Bounds     : Rose.Capabilities.Capability)
   is
   begin
      Client.Clamp := Clamp;
      Client.Position := Position;
      Client.Offset := Offset;
      Client.Difference := Difference;
      Client.Bounds := Bounds;
      Client.Is_Open := True;
   end Open_Cap_Set;

   --------------
   -- Position --
   --------------

   procedure Position
     (Item  : Signed_Client;
      Index : Rose.Words.Word;
      X     : out Standard.Interfaces.Integer_32;
      Y     : out Standard.Interfaces.Integer_32;
      Count : out Natural)
   is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      Rose.System_Calls.Initialize_Send (Params, Item.Position);
      Rose.System_Calls.Send_Word (Params, Index);
      Rose.System_Calls.Receive_Words (Params, 3);
      Rose.System_Calls.Invoke_Capability (Params);
      Last_Error := Rose.Invocation.OK;
      if Params.Control.Flags (Rose.Invocation.Error) then
         Last_Error := Params.Error;
      end if;
      X := Rose.System_Calls.Get_Integer_32 (Params, 0);
      Y := Rose.System_Calls.Get_Integer_32 (Params, 1);
      Count := Natural (Rose.System_Calls.Get_Word_32 (Params, 2));
   end Position;

end Rose.Interfaces.Signed.Client;
