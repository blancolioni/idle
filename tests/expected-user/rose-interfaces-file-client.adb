with Rose.Interfaces.File_Reader.Client;
with Rose.Interfaces.Objects;
with Rose.Interfaces.Seekable_File_Reader.Client;
with Rose.Invocation;
with Rose.System_Calls;

package body Rose.Interfaces.File.Client is

   procedure Load (Item : in out File_Client);

   -----------
   -- Close --
   -----------

   procedure Close (Client : in out File_Client) is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      if Client.Is_Open then
         Rose.System_Calls.Initialize_Send
           (Params,
            Rose.System_Calls.Delete_Cap_Capability);
         Rose.System_Calls.Send_Cap (Params, Client.Size);
         Rose.System_Calls.Invoke_Capability (Params);
         Rose.System_Calls.Initialize_Send
           (Params,
            Rose.System_Calls.Delete_Cap_Capability);
         Rose.System_Calls.Send_Cap (Params, Client.Open_Reader);
         Rose.System_Calls.Invoke_Capability (Params);
         Rose.System_Calls.Initialize_Send
           (Params,
            Rose.System_Calls.Delete_Cap_Capability);
         Rose.System_Calls.Send_Cap (Params, Client.Open_Seekable_Reader);
         Rose.System_Calls.Invoke_Capability (Params);
      end if;
      Client.Is_Open := False;
      Rose.System_Calls.Initialize_Send
        (Params,
         Rose.System_Calls.Delete_Cap_Capability);
      Rose.System_Calls.Send_Cap (Params, Client.Interface_Cap);
      Rose.System_Calls.Invoke_Capability (Params);
   end Close;

   --------------
   -- File_Cap --
   --------------

   overriding function File_Cap
     (Item : in out File_Client)
      return Rose.Capabilities.Capability
   is (Item.Interface_Cap);

   --------------
   -- From_Cap --
   --------------

   function From_Cap
     (Cap : Rose.Capabilities.Capability)
      return File_Client
   is (File_Client'(Interface_Cap => Cap, others => <>));

   -----------------------
   -- Get_Interface_Cap --
   -----------------------

   function Get_Interface_Cap
     (Item : File_Client)
      return Rose.Capabilities.Capability
   is (Item.Interface_Cap);

   -------------------------
   -- Get_Open_Reader_Cap --
   -------------------------

   function Get_Open_Reader_Cap
     (Item : in out File_Client)
      return Rose.Capabilities.Capability
   is
   begin
      if not Item.Is_Open then
         Load (Item);
      end if;
      return Item.Open_Reader;
   end Get_Open_Reader_Cap;

   ----------------------------------
   -- Get_Open_Seekable_Reader_Cap --
   ----------------------------------

   function Get_Open_Seekable_Reader_Cap
     (Item : in out File_Client)
      return Rose.Capabilities.Capability
   is
   begin
      if not Item.Is_Open then
         Load (Item);
      end if;
      return Item.Open_Seekable_Reader;
   end Get_Open_Seekable_Reader_Cap;

   ------------------
   -- Get_Size_Cap --
   ------------------

   function Get_Size_Cap
     (Item : in out File_Client)
      return Rose.Capabilities.Capability
   is
   begin
      if not Item.Is_Open then
         Load (Item);
      end if;
      return Item.Size;
   end Get_Size_Cap;

   ----------
   -- Load --
   ----------

   procedure Load (Item : in out File_Client) is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      Rose.System_Calls.Initialize_Send (Params, Item.Interface_Cap);
      Rose.System_Calls.Receive_Caps (Params, Subprogram_Count);
      Rose.System_Calls.Invoke_Capability (Params);
      if Params.Control.Flags (Rose.Invocation.Error) then
         raise Rose.Interfaces.Objects.Invocation_Error with "File.Open";
      end if;
      Item.Size := Params.Caps (Size_Index);
      Item.Open_Reader := Params.Caps (Open_Reader_Index);
      Item.Open_Seekable_Reader := Params.Caps (Open_Seekable_Reader_Index);
      Item.Is_Open := True;
   end Load;

   ----------
   -- Open --
   ----------

   procedure Open
     (Client        : out File_Client;
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
     (Client               : out File_Client;
      Size                 : Rose.Capabilities.Capability;
      Open_Reader          : Rose.Capabilities.Capability;
      Open_Seekable_Reader : Rose.Capabilities.Capability)
   is
   begin
      Client.Size := Size;
      Client.Open_Reader := Open_Reader;
      Client.Open_Seekable_Reader := Open_Seekable_Reader;
      Client.Is_Open := True;
   end Open_Cap_Set;

   -----------------
   -- Open_Reader --
   -----------------

   overriding function Open_Reader
     (Item : in out File_Client)
      return Rose.Interfaces.File_Reader.File_Reader_Object'Class
   is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      if not Item.Is_Open then
         Load (Item);
      end if;
      Rose.System_Calls.Initialize_Send (Params, Item.Open_Reader);
      Rose.System_Calls.Receive_Caps (Params, 1);
      Rose.System_Calls.Invoke_Capability (Params);
      if Params.Control.Flags (Rose.Invocation.Error) then
         raise Rose.Interfaces.Objects.Invocation_Error
           with "File.Open_Reader";
      end if;
      return Rose.Interfaces.File_Reader.Client.From_Cap (Params.Caps (0));
   end Open_Reader;

   --------------------------
   -- Open_Seekable_Reader --
   --------------------------

   overriding function Open_Seekable_Reader
     (Item : in out File_Client)
      return
        Rose.Interfaces.Seekable_File_Reader.Seekable_File_Reader_Object'Class
   is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      if not Item.Is_Open then
         Load (Item);
      end if;
      Rose.System_Calls.Initialize_Send (Params, Item.Open_Seekable_Reader);
      Rose.System_Calls.Receive_Caps (Params, 1);
      Rose.System_Calls.Invoke_Capability (Params);
      if Params.Control.Flags (Rose.Invocation.Error) then
         raise Rose.Interfaces.Objects.Invocation_Error
           with "File.Open_Seekable_Reader";
      end if;
      return Rose.Interfaces.Seekable_File_Reader.Client.From_Cap
        (Params.Caps (0));
   end Open_Seekable_Reader;

   ----------
   -- Size --
   ----------

   overriding function Size
     (Item : in out File_Client)
      return System.Storage_Elements.Storage_Count
   is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      if not Item.Is_Open then
         Load (Item);
      end if;
      Rose.System_Calls.Initialize_Send (Params, Item.Size);
      Rose.System_Calls.Receive_Words (Params, 1);
      Rose.System_Calls.Invoke_Capability (Params);
      if Params.Control.Flags (Rose.Invocation.Error) then
         raise Rose.Interfaces.Objects.Invocation_Error with "File.Size";
      end if;
      return System.Storage_Elements.Storage_Count
        (Rose.System_Calls.Get_Word_32 (Params, 0));
   end Size;

end Rose.Interfaces.File.Client;
