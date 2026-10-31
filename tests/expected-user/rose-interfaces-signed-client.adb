with Rose.Interfaces.Objects;
with Rose.Invocation;
with Rose.System_Calls;

package body Rose.Interfaces.Signed.Client is

   procedure Load (Item : in out Signed_Client);

   ------------
   -- Bounds --
   ------------

   overriding procedure Bounds
     (Item : in out Signed_Client;
      Low  : out Long_Long_Integer;
      High : out Long_Long_Integer)
   is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      if not Item.Is_Open then
         Load (Item);
      end if;
      Rose.System_Calls.Initialize_Send (Params, Item.Bounds);
      Rose.System_Calls.Receive_Words (Params, 4);
      Rose.System_Calls.Invoke_Capability (Params);
      if Params.Control.Flags (Rose.Invocation.Error) then
         raise Rose.Interfaces.Objects.Invocation_Error with "Signed.Bounds";
      end if;
      Low := Rose.System_Calls.Get_Integer_64 (Params, 0);
      High := Rose.System_Calls.Get_Integer_64 (Params, 2);
   end Bounds;

   -----------
   -- Clamp --
   -----------

   overriding function Clamp
     (Item  : in out Signed_Client;
      Value : Integer;
      Low   : Integer)
      return Integer
   is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      if not Item.Is_Open then
         Load (Item);
      end if;
      Rose.System_Calls.Initialize_Send (Params, Item.Clamp);
      Rose.System_Calls.Send_Integer (Params, Value);
      Rose.System_Calls.Send_Integer (Params, Low);
      Rose.System_Calls.Receive_Words (Params, 1);
      Rose.System_Calls.Invoke_Capability (Params);
      if Params.Control.Flags (Rose.Invocation.Error) then
         raise Rose.Interfaces.Objects.Invocation_Error with "Signed.Clamp";
      end if;
      return Rose.System_Calls.Get_Integer (Params, 0);
   end Clamp;

   -----------
   -- Close --
   -----------

   procedure Close (Client : in out Signed_Client) is
   begin
      if Client.Is_Open then
         Rose.System_Calls.Delete_Cap (Client.Clamp);
         Rose.System_Calls.Delete_Cap (Client.Position);
         Rose.System_Calls.Delete_Cap (Client.Offset);
         Rose.System_Calls.Delete_Cap (Client.Difference);
         Rose.System_Calls.Delete_Cap (Client.Bounds);
      end if;
      Client.Is_Open := False;
      Rose.System_Calls.Delete_Cap (Client.Interface_Cap);
   end Close;

   ----------------
   -- Difference --
   ----------------

   overriding function Difference
     (Item  : in out Signed_Client;
      Left  : Long_Long_Integer;
      Right : Long_Long_Integer)
      return Long_Long_Integer
   is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      if not Item.Is_Open then
         Load (Item);
      end if;
      Rose.System_Calls.Initialize_Send (Params, Item.Difference);
      Rose.System_Calls.Send_Integer_64 (Params, Left);
      Rose.System_Calls.Send_Integer_64 (Params, Right);
      Rose.System_Calls.Receive_Words (Params, 2);
      Rose.System_Calls.Invoke_Capability (Params);
      if Params.Control.Flags (Rose.Invocation.Error) then
         raise Rose.Interfaces.Objects.Invocation_Error
           with "Signed.Difference";
      end if;
      return Rose.System_Calls.Get_Integer_64 (Params, 0);
   end Difference;

   --------------
   -- From_Cap --
   --------------

   function From_Cap
     (Cap : Rose.Capabilities.Capability)
      return Signed_Client
   is (Signed_Client'(Interface_Cap => Cap, others => <>));

   --------------------
   -- Get_Bounds_Cap --
   --------------------

   function Get_Bounds_Cap
     (Item : in out Signed_Client)
      return Rose.Capabilities.Capability
   is
   begin
      if not Item.Is_Open then
         Load (Item);
      end if;
      return Item.Bounds;
   end Get_Bounds_Cap;

   -------------------
   -- Get_Clamp_Cap --
   -------------------

   function Get_Clamp_Cap
     (Item : in out Signed_Client)
      return Rose.Capabilities.Capability
   is
   begin
      if not Item.Is_Open then
         Load (Item);
      end if;
      return Item.Clamp;
   end Get_Clamp_Cap;

   ------------------------
   -- Get_Difference_Cap --
   ------------------------

   function Get_Difference_Cap
     (Item : in out Signed_Client)
      return Rose.Capabilities.Capability
   is
   begin
      if not Item.Is_Open then
         Load (Item);
      end if;
      return Item.Difference;
   end Get_Difference_Cap;

   -----------------------
   -- Get_Interface_Cap --
   -----------------------

   function Get_Interface_Cap
     (Item : Signed_Client)
      return Rose.Capabilities.Capability
   is (Item.Interface_Cap);

   --------------------
   -- Get_Offset_Cap --
   --------------------

   function Get_Offset_Cap
     (Item : in out Signed_Client)
      return Rose.Capabilities.Capability
   is
   begin
      if not Item.Is_Open then
         Load (Item);
      end if;
      return Item.Offset;
   end Get_Offset_Cap;

   ----------------------
   -- Get_Position_Cap --
   ----------------------

   function Get_Position_Cap
     (Item : in out Signed_Client)
      return Rose.Capabilities.Capability
   is
   begin
      if not Item.Is_Open then
         Load (Item);
      end if;
      return Item.Position;
   end Get_Position_Cap;

   ----------
   -- Load --
   ----------

   procedure Load (Item : in out Signed_Client) is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      Rose.System_Calls.Initialize_Send (Params, Item.Interface_Cap);
      Rose.System_Calls.Receive_Caps (Params, Subprogram_Count);
      Rose.System_Calls.Invoke_Capability (Params);
      if Params.Control.Flags (Rose.Invocation.Error) then
         raise Rose.Interfaces.Objects.Invocation_Error with "Signed.Open";
      end if;
      Item.Clamp := Params.Caps (Clamp_Index);
      Item.Position := Params.Caps (Position_Index);
      Item.Offset := Params.Caps (Offset_Index);
      Item.Difference := Params.Caps (Difference_Index);
      Item.Bounds := Params.Caps (Bounds_Index);
      Item.Is_Open := True;
   end Load;

   ------------
   -- Offset --
   ------------

   overriding procedure Offset
     (Item    : in out Signed_Client;
      Delta_X : in out Integer)
   is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      if not Item.Is_Open then
         Load (Item);
      end if;
      Rose.System_Calls.Initialize_Send (Params, Item.Offset);
      Rose.System_Calls.Send_Integer (Params, Delta_X);
      Rose.System_Calls.Receive_Words (Params, 1);
      Rose.System_Calls.Invoke_Capability (Params);
      if Params.Control.Flags (Rose.Invocation.Error) then
         raise Rose.Interfaces.Objects.Invocation_Error with "Signed.Offset";
      end if;
      Delta_X := Rose.System_Calls.Get_Integer (Params, 0);
   end Offset;

   ----------
   -- Open --
   ----------

   procedure Open
     (Client        : out Signed_Client;
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

   overriding procedure Position
     (Item  : in out Signed_Client;
      Index : Rose.Words.Word;
      X     : out Integer;
      Y     : out Integer;
      Count : out Natural)
   is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      if not Item.Is_Open then
         Load (Item);
      end if;
      Rose.System_Calls.Initialize_Send (Params, Item.Position);
      Rose.System_Calls.Send_Word (Params, Index);
      Rose.System_Calls.Receive_Words (Params, 3);
      Rose.System_Calls.Invoke_Capability (Params);
      if Params.Control.Flags (Rose.Invocation.Error) then
         raise Rose.Interfaces.Objects.Invocation_Error with "Signed.Position";
      end if;
      X := Rose.System_Calls.Get_Integer (Params, 0);
      Y := Rose.System_Calls.Get_Integer (Params, 1);
      Count := Natural (Rose.System_Calls.Get_Word_32 (Params, 2));
   end Position;

   ----------------
   -- Signed_Cap --
   ----------------

   overriding function Signed_Cap
     (Item : in out Signed_Client)
      return Rose.Capabilities.Capability
   is (Item.Interface_Cap);

end Rose.Interfaces.Signed.Client;
