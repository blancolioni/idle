with Rose.System_Calls;

package body Rose.Interfaces.Directory.Client is

   use type Rose.Invocation.Invocation_Error;

   Last_Error : Rose.Invocation.Invocation_Error := Rose.Invocation.OK;

   -----------
   -- Close --
   -----------

   procedure Close (Client : in out Directory_Client) is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      Client.Is_Open := False;
      Rose.System_Calls.Initialize_Send
        (Params,
         Rose.System_Calls.Delete_Cap_Capability);
      Rose.System_Calls.Send_Cap (Params, Client.Directory_Entry_Count);
      Rose.System_Calls.Invoke_Capability (Params);
      Rose.System_Calls.Initialize_Send
        (Params,
         Rose.System_Calls.Delete_Cap_Capability);
      Rose.System_Calls.Send_Cap (Params, Client.Directory_Entry_Name);
      Rose.System_Calls.Invoke_Capability (Params);
      Rose.System_Calls.Initialize_Send
        (Params,
         Rose.System_Calls.Delete_Cap_Capability);
      Rose.System_Calls.Send_Cap (Params, Client.Directory_Entry_Kind);
      Rose.System_Calls.Invoke_Capability (Params);
      Rose.System_Calls.Initialize_Send
        (Params,
         Rose.System_Calls.Delete_Cap_Capability);
      Rose.System_Calls.Send_Cap (Params, Client.Directory_Entry_Size);
      Rose.System_Calls.Invoke_Capability (Params);
      Rose.System_Calls.Initialize_Send
        (Params,
         Rose.System_Calls.Delete_Cap_Capability);
      Rose.System_Calls.Send_Cap (Params, Client.Find_Entry);
      Rose.System_Calls.Invoke_Capability (Params);
      Rose.System_Calls.Initialize_Send
        (Params,
         Rose.System_Calls.Delete_Cap_Capability);
      Rose.System_Calls.Send_Cap (Params, Client.Get_Ordinary_File);
      Rose.System_Calls.Invoke_Capability (Params);
      Rose.System_Calls.Initialize_Send
        (Params,
         Rose.System_Calls.Delete_Cap_Capability);
      Rose.System_Calls.Send_Cap (Params, Client.Get_Directory);
      Rose.System_Calls.Invoke_Capability (Params);
      Rose.System_Calls.Initialize_Send
        (Params,
         Rose.System_Calls.Delete_Cap_Capability);
      Rose.System_Calls.Send_Cap (Params, Client.Interface_Cap);
      Rose.System_Calls.Invoke_Capability (Params);
   end Close;

   ---------------------------
   -- Directory_Entry_Count --
   ---------------------------

   function Directory_Entry_Count (Item : Directory_Client) return Natural is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      Rose.System_Calls.Initialize_Send (Params, Item.Directory_Entry_Count);
      Rose.System_Calls.Receive_Words (Params, 1);
      Rose.System_Calls.Invoke_Capability (Params);
      Last_Error := Rose.Invocation.OK;
      if Params.Control.Flags (Rose.Invocation.Error) then
         Last_Error := Params.Error;
      end if;
      return Natural (Rose.System_Calls.Get_Word_32 (Params, 0));
   end Directory_Entry_Count;

   --------------------------
   -- Directory_Entry_Kind --
   --------------------------

   function Directory_Entry_Kind
     (Item  : Directory_Client;
      Index : Positive)
      return Rose.Interfaces.Directory.File_Kind
   is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      Rose.System_Calls.Initialize_Send (Params, Item.Directory_Entry_Kind);
      Rose.System_Calls.Send_Word (Params, Index);
      Rose.System_Calls.Receive_Words (Params, 1);
      Rose.System_Calls.Invoke_Capability (Params);
      Last_Error := Rose.Invocation.OK;
      if Params.Control.Flags (Rose.Invocation.Error) then
         Last_Error := Params.Error;
      end if;
      return Rose.Interfaces.Directory.File_Kind'Val
        (Rose.System_Calls.Get_Word_32 (Params, 0));
   end Directory_Entry_Kind;

   --------------------------
   -- Directory_Entry_Name --
   --------------------------

   procedure Directory_Entry_Name
     (Item   : Directory_Client;
      Index  : Positive;
      Result : out String;
      Last   : out Natural)
   is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      Rose.System_Calls.Initialize_Send (Params, Item.Directory_Entry_Name);
      Rose.System_Calls.Send_Word (Params, Index);
      Rose.System_Calls.Receive_Words (Params, 1);
      Rose.System_Calls.Receive_Buffer (Params);
      Rose.System_Calls.Invoke_Capability (Params);
      Last_Error := Rose.Invocation.OK;
      if Params.Control.Flags (Rose.Invocation.Error) then
         Last_Error := Params.Error;
      end if;
      Rose.System_Calls.Copy_Text
        (Params,
         Natural (Rose.System_Calls.Get_Word_32 (Params, 0)),
         Result,
         Last);
   end Directory_Entry_Name;

   --------------------------
   -- Directory_Entry_Size --
   --------------------------

   function Directory_Entry_Size
     (Item  : Directory_Client;
      Index : Positive)
      return System.Storage_Elements.Storage_Count
   is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      Rose.System_Calls.Initialize_Send (Params, Item.Directory_Entry_Size);
      Rose.System_Calls.Send_Word (Params, Index);
      Rose.System_Calls.Receive_Words (Params, 1);
      Rose.System_Calls.Invoke_Capability (Params);
      Last_Error := Rose.Invocation.OK;
      if Params.Control.Flags (Rose.Invocation.Error) then
         Last_Error := Params.Error;
      end if;
      return System.Storage_Elements.Storage_Count
        (Rose.System_Calls.Get_Word_32 (Params, 0));
   end Directory_Entry_Size;

   ----------------
   -- Find_Entry --
   ----------------

   function Find_Entry
     (Item : Directory_Client;
      Name : String)
      return Natural
   is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      Rose.System_Calls.Initialize_Send (Params, Item.Find_Entry);
      Rose.System_Calls.Send_Text (Params, Name);
      Rose.System_Calls.Receive_Words (Params, 1);
      Rose.System_Calls.Invoke_Capability (Params);
      Last_Error := Rose.Invocation.OK;
      if Params.Control.Flags (Rose.Invocation.Error) then
         Last_Error := Params.Error;
      end if;
      return Natural (Rose.System_Calls.Get_Word_32 (Params, 0));
   end Find_Entry;

   -------------------
   -- Get_Directory --
   -------------------

   function Get_Directory
     (Item  : Directory_Client;
      Index : Positive)
      return Directory_Client
   is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      Rose.System_Calls.Initialize_Send (Params, Item.Get_Directory);
      Rose.System_Calls.Send_Word (Params, Index);
      Rose.System_Calls.Receive_Caps (Params, 1);
      Rose.System_Calls.Invoke_Capability (Params);
      Last_Error := Rose.Invocation.OK;
      if Params.Control.Flags (Rose.Invocation.Error) then
         Last_Error := Params.Error;
      end if;
      declare
         Result : Directory_Client;
      begin
         Open (Result, Params.Caps (0));
         return Result;
      end;
   end Get_Directory;

   -----------------------------------
   -- Get_Directory_Entry_Count_Cap --
   -----------------------------------

   function Get_Directory_Entry_Count_Cap
     (Item : Directory_Client)
      return Rose.Capabilities.Capability
   is (Item.Directory_Entry_Count);

   ----------------------------------
   -- Get_Directory_Entry_Kind_Cap --
   ----------------------------------

   function Get_Directory_Entry_Kind_Cap
     (Item : Directory_Client)
      return Rose.Capabilities.Capability
   is (Item.Directory_Entry_Kind);

   ----------------------------------
   -- Get_Directory_Entry_Name_Cap --
   ----------------------------------

   function Get_Directory_Entry_Name_Cap
     (Item : Directory_Client)
      return Rose.Capabilities.Capability
   is (Item.Directory_Entry_Name);

   ----------------------------------
   -- Get_Directory_Entry_Size_Cap --
   ----------------------------------

   function Get_Directory_Entry_Size_Cap
     (Item : Directory_Client)
      return Rose.Capabilities.Capability
   is (Item.Directory_Entry_Size);

   ------------------------
   -- Get_Find_Entry_Cap --
   ------------------------

   function Get_Find_Entry_Cap
     (Item : Directory_Client)
      return Rose.Capabilities.Capability
   is (Item.Find_Entry);

   ---------------------------
   -- Get_Get_Directory_Cap --
   ---------------------------

   function Get_Get_Directory_Cap
     (Item : Directory_Client)
      return Rose.Capabilities.Capability
   is (Item.Get_Directory);

   -------------------------------
   -- Get_Get_Ordinary_File_Cap --
   -------------------------------

   function Get_Get_Ordinary_File_Cap
     (Item : Directory_Client)
      return Rose.Capabilities.Capability
   is (Item.Get_Ordinary_File);

   -----------------------
   -- Get_Interface_Cap --
   -----------------------

   function Get_Interface_Cap
     (Item : Directory_Client)
      return Rose.Capabilities.Capability
   is (Item.Interface_Cap);

   --------------------
   -- Get_Last_Error --
   --------------------

   function Get_Last_Error
      return Rose.Invocation.Invocation_Error
   is (Last_Error);

   -----------------------
   -- Get_Ordinary_File --
   -----------------------

   function Get_Ordinary_File
     (Item  : Directory_Client;
      Index : Positive)
      return Rose.Interfaces.File.Client.File_Client
   is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      Rose.System_Calls.Initialize_Send (Params, Item.Get_Ordinary_File);
      Rose.System_Calls.Send_Word (Params, Index);
      Rose.System_Calls.Receive_Caps (Params, 1);
      Rose.System_Calls.Invoke_Capability (Params);
      Last_Error := Rose.Invocation.OK;
      if Params.Control.Flags (Rose.Invocation.Error) then
         Last_Error := Params.Error;
      end if;
      declare
         Result : Rose.Interfaces.File.Client.File_Client;
      begin
         Rose.Interfaces.File.Client.Open (Result, Params.Caps (0));
         return Result;
      end;
   end Get_Ordinary_File;

   ---------------
   -- Has_Error --
   ---------------

   function Has_Error return Boolean is (Last_Error /= Rose.Invocation.OK);

   ----------
   -- Open --
   ----------

   procedure Open
     (Client        : out Directory_Client;
      Interface_Cap : Rose.Capabilities.Capability)
   is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      Client.Is_Open := False;
      Client.Interface_Cap := Interface_Cap;
      Rose.System_Calls.Initialize_Send (Params, Interface_Cap);
      Rose.System_Calls.Receive_Caps (Params, Subprogram_Count);
      Rose.System_Calls.Invoke_Capability (Params);
      Client.Directory_Entry_Count :=
        Params.Caps (Directory_Entry_Count_Index);
      Client.Directory_Entry_Name := Params.Caps (Directory_Entry_Name_Index);
      Client.Directory_Entry_Kind := Params.Caps (Directory_Entry_Kind_Index);
      Client.Directory_Entry_Size := Params.Caps (Directory_Entry_Size_Index);
      Client.Find_Entry := Params.Caps (Find_Entry_Index);
      Client.Get_Ordinary_File := Params.Caps (Get_Ordinary_File_Index);
      Client.Get_Directory := Params.Caps (Get_Directory_Index);
      Client.Is_Open := True;
   end Open;

   ------------------
   -- Open_Cap_Set --
   ------------------

   procedure Open_Cap_Set
     (Client                : out Directory_Client;
      Directory_Entry_Count : Rose.Capabilities.Capability;
      Directory_Entry_Name  : Rose.Capabilities.Capability;
      Directory_Entry_Kind  : Rose.Capabilities.Capability;
      Directory_Entry_Size  : Rose.Capabilities.Capability;
      Find_Entry            : Rose.Capabilities.Capability;
      Get_Ordinary_File     : Rose.Capabilities.Capability;
      Get_Directory         : Rose.Capabilities.Capability)
   is
   begin
      Client.Directory_Entry_Count := Directory_Entry_Count;
      Client.Directory_Entry_Name := Directory_Entry_Name;
      Client.Directory_Entry_Kind := Directory_Entry_Kind;
      Client.Directory_Entry_Size := Directory_Entry_Size;
      Client.Find_Entry := Find_Entry;
      Client.Get_Ordinary_File := Get_Ordinary_File;
      Client.Get_Directory := Get_Directory;
      Client.Is_Open := True;
   end Open_Cap_Set;

end Rose.Interfaces.Directory.Client;
