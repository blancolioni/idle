with Rose.Interfaces.Objects;
with Rose.Interfaces.Process.Client;
with Rose.Invocation;
with Rose.System_Calls;

package body Rose.Interfaces.Launch.Client is

   procedure Load (Item : in out Launch_Client);

   -----------
   -- Close --
   -----------

   procedure Close (Client : in out Launch_Client) is
   begin
      if Client.Is_Open then
         Rose.System_Calls.Delete_Cap (Client.Launch);
         Rose.System_Calls.Delete_Cap (Client.Launch_Command);
         Rose.System_Calls.Delete_Cap (Client.Metadata);
      end if;
      Client.Is_Open := False;
      Rose.System_Calls.Delete_Cap (Client.Interface_Cap);
   end Close;

   --------------
   -- From_Cap --
   --------------

   function From_Cap
     (Cap : Rose.Capabilities.Capability)
      return Launch_Client
   is (Launch_Client'(Interface_Cap => Cap, others => <>));

   -----------------------
   -- Get_Interface_Cap --
   -----------------------

   function Get_Interface_Cap
     (Item : Launch_Client)
      return Rose.Capabilities.Capability
   is (Item.Interface_Cap);

   --------------------
   -- Get_Launch_Cap --
   --------------------

   function Get_Launch_Cap
     (Item : in out Launch_Client)
      return Rose.Capabilities.Capability
   is
   begin
      if not Item.Is_Open then
         Load (Item);
      end if;
      return Item.Launch;
   end Get_Launch_Cap;

   ----------------------------
   -- Get_Launch_Command_Cap --
   ----------------------------

   function Get_Launch_Command_Cap
     (Item : in out Launch_Client)
      return Rose.Capabilities.Capability
   is
   begin
      if not Item.Is_Open then
         Load (Item);
      end if;
      return Item.Launch_Command;
   end Get_Launch_Command_Cap;

   ----------------------
   -- Get_Metadata_Cap --
   ----------------------

   function Get_Metadata_Cap
     (Item : in out Launch_Client)
      return Rose.Capabilities.Capability
   is
   begin
      if not Item.Is_Open then
         Load (Item);
      end if;
      return Item.Metadata;
   end Get_Metadata_Cap;

   ------------
   -- Launch --
   ------------

   overriding function Launch
     (Item        : in out Launch_Client;
      Caps        : Rose.Capabilities.Capability_Array;
      Environment : System.Storage_Elements.Storage_Array)
      return Rose.Interfaces.Process.Process_Object'Class
   is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      if not Item.Is_Open then
         Load (Item);
      end if;
      Rose.System_Calls.Initialize_Send (Params, Item.Launch);
      for Cap of Caps loop
         Rose.System_Calls.Send_Cap (Params, Cap);
      end loop;
      Rose.System_Calls.Send_Storage_Array (Params, Environment, False);
      Rose.System_Calls.Receive_Caps (Params, 1);
      Rose.System_Calls.Invoke_Capability (Params);
      if Params.Control.Flags (Rose.Invocation.Error) then
         raise Rose.Interfaces.Objects.Invocation_Error with "Launch.Launch";
      end if;
      return Rose.Interfaces.Process.Client.From_Cap (Params.Caps (0));
   end Launch;

   ----------------
   -- Launch_Cap --
   ----------------

   overriding function Launch_Cap
     (Item : in out Launch_Client)
      return Rose.Capabilities.Capability
   is (Item.Interface_Cap);

   --------------------
   -- Launch_Command --
   --------------------

   overriding function Launch_Command
     (Item : in out Launch_Client;
      Caps : Rose.Capabilities.Capability_Array)
      return Rose.Capabilities.Capability
   is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      if not Item.Is_Open then
         Load (Item);
      end if;
      Rose.System_Calls.Initialize_Send (Params, Item.Launch_Command);
      for Cap of Caps loop
         Rose.System_Calls.Send_Cap (Params, Cap);
      end loop;
      Rose.System_Calls.Receive_Caps (Params, 1);
      Rose.System_Calls.Invoke_Capability (Params);
      if Params.Control.Flags (Rose.Invocation.Error) then
         raise Rose.Interfaces.Objects.Invocation_Error
           with "Launch.Launch_Command";
      end if;
      return Params.Caps (0);
   end Launch_Command;

   ----------
   -- Load --
   ----------

   procedure Load (Item : in out Launch_Client) is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      Rose.System_Calls.Initialize_Send (Params, Item.Interface_Cap);
      Rose.System_Calls.Receive_Caps (Params, Subprogram_Count);
      Rose.System_Calls.Invoke_Capability (Params);
      if Params.Control.Flags (Rose.Invocation.Error) then
         raise Rose.Interfaces.Objects.Invocation_Error with "Launch.Open";
      end if;
      Item.Launch := Params.Caps (Launch_Index);
      Item.Launch_Command := Params.Caps (Launch_Command_Index);
      Item.Metadata := Params.Caps (Metadata_Index);
      Item.Is_Open := True;
   end Load;

   --------------
   -- Metadata --
   --------------

   overriding function Metadata (Item : in out Launch_Client) return String is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      if not Item.Is_Open then
         Load (Item);
      end if;
      Rose.System_Calls.Initialize_Send (Params, Item.Metadata);
      Rose.System_Calls.Receive_Words (Params, 1);
      Rose.System_Calls.Receive_Buffer (Params);
      Rose.System_Calls.Invoke_Capability (Params);
      if Params.Control.Flags (Rose.Invocation.Error) then
         raise Rose.Interfaces.Objects.Invocation_Error with "Launch.Metadata";
      end if;
      declare
         Result : String
           (1 .. Natural (Rose.System_Calls.Get_Word_32 (Params, 0)));
         Last   : Natural;
      begin
         Rose.System_Calls.Copy_Text (Params, Result'Length, Result, Last);
         return Result (1 .. Last);
      end;
   end Metadata;

   ----------
   -- Open --
   ----------

   procedure Open
     (Client        : out Launch_Client;
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
     (Client         : out Launch_Client;
      Launch         : Rose.Capabilities.Capability;
      Launch_Command : Rose.Capabilities.Capability;
      Metadata       : Rose.Capabilities.Capability)
   is
   begin
      Client.Launch := Launch;
      Client.Launch_Command := Launch_Command;
      Client.Metadata := Metadata;
      Client.Is_Open := True;
   end Open_Cap_Set;

end Rose.Interfaces.Launch.Client;
