with Rose.Interfaces.File.Client;
with Rose.Interfaces.Objects;
with Rose.Invocation;
with Rose.System_Calls;

package body Rose.Interfaces.Directory.Client is

   procedure Load (Item : in out Directory_Client);

   -----------
   -- Close --
   -----------

   procedure Close (Client : in out Directory_Client) is
   begin
      if Client.Is_Open then
         Rose.System_Calls.Delete_Cap (Client.Directory_Entry_Count);
         Rose.System_Calls.Delete_Cap (Client.Directory_Entry_Name);
         Rose.System_Calls.Delete_Cap (Client.Directory_Entry_Kind);
         Rose.System_Calls.Delete_Cap (Client.Directory_Entry_Size);
         Rose.System_Calls.Delete_Cap (Client.Find_Entry);
         Rose.System_Calls.Delete_Cap (Client.Get_Ordinary_File);
         Rose.System_Calls.Delete_Cap (Client.Get_Directory);
      end if;
      Client.Is_Open := False;
      Rose.System_Calls.Delete_Cap (Client.Interface_Cap);
   end Close;

   -------------------
   -- Directory_Cap --
   -------------------

   overriding function Directory_Cap
     (Item : in out Directory_Client)
      return Rose.Capabilities.Capability
   is (Item.Interface_Cap);

   ---------------------------
   -- Directory_Entry_Count --
   ---------------------------

   overriding function Directory_Entry_Count
     (Item : in out Directory_Client)
      return Natural
   is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      if not Item.Is_Open then
         Load (Item);
      end if;
      Rose.System_Calls.Initialize_Send (Params, Item.Directory_Entry_Count);
      Rose.System_Calls.Receive_Words (Params, 1);
      Rose.System_Calls.Invoke_Capability (Params);
      if Params.Control.Flags (Rose.Invocation.Error) then
         raise Rose.Interfaces.Objects.Invocation_Error
           with "Directory.Directory_Entry_Count";
      end if;
      return Natural (Rose.System_Calls.Get_Word_32 (Params, 0));
   end Directory_Entry_Count;

   --------------------------
   -- Directory_Entry_Kind --
   --------------------------

   overriding function Directory_Entry_Kind
     (Item  : in out Directory_Client;
      Index : Positive)
      return Rose.Interfaces.Directory.File_Kind
   is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      if not Item.Is_Open then
         Load (Item);
      end if;
      Rose.System_Calls.Initialize_Send (Params, Item.Directory_Entry_Kind);
      Rose.System_Calls.Send_Word (Params, Index);
      Rose.System_Calls.Receive_Words (Params, 1);
      Rose.System_Calls.Invoke_Capability (Params);
      if Params.Control.Flags (Rose.Invocation.Error) then
         raise Rose.Interfaces.Objects.Invocation_Error
           with "Directory.Directory_Entry_Kind";
      end if;
      return Rose.Interfaces.Directory.File_Kind'Val
        (Rose.System_Calls.Get_Word_32 (Params, 0));
   end Directory_Entry_Kind;

   --------------------------
   -- Directory_Entry_Name --
   --------------------------

   overriding function Directory_Entry_Name
     (Item  : in out Directory_Client;
      Index : Positive)
      return String
   is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      if not Item.Is_Open then
         Load (Item);
      end if;
      Rose.System_Calls.Initialize_Send (Params, Item.Directory_Entry_Name);
      Rose.System_Calls.Send_Word (Params, Index);
      Rose.System_Calls.Receive_Words (Params, 1);
      Rose.System_Calls.Receive_Buffer (Params);
      Rose.System_Calls.Invoke_Capability (Params);
      if Params.Control.Flags (Rose.Invocation.Error) then
         raise Rose.Interfaces.Objects.Invocation_Error
           with "Directory.Directory_Entry_Name";
      end if;
      declare
         Result : String
           (1 .. Natural (Rose.System_Calls.Get_Word_32 (Params, 0)));
         Last   : Natural;
      begin
         Rose.System_Calls.Copy_Text (Params, Result'Length, Result, Last);
         return Result (1 .. Last);
      end;
   end Directory_Entry_Name;

   --------------------------
   -- Directory_Entry_Size --
   --------------------------

   overriding function Directory_Entry_Size
     (Item  : in out Directory_Client;
      Index : Positive)
      return System.Storage_Elements.Storage_Count
   is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      if not Item.Is_Open then
         Load (Item);
      end if;
      Rose.System_Calls.Initialize_Send (Params, Item.Directory_Entry_Size);
      Rose.System_Calls.Send_Word (Params, Index);
      Rose.System_Calls.Receive_Words (Params, 1);
      Rose.System_Calls.Invoke_Capability (Params);
      if Params.Control.Flags (Rose.Invocation.Error) then
         raise Rose.Interfaces.Objects.Invocation_Error
           with "Directory.Directory_Entry_Size";
      end if;
      return System.Storage_Elements.Storage_Count
        (Rose.System_Calls.Get_Word_32 (Params, 0));
   end Directory_Entry_Size;

   ----------------
   -- Find_Entry --
   ----------------

   overriding function Find_Entry
     (Item : in out Directory_Client;
      Name : String)
      return Natural
   is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      if not Item.Is_Open then
         Load (Item);
      end if;
      Rose.System_Calls.Initialize_Send (Params, Item.Find_Entry);
      Rose.System_Calls.Send_Text (Params, Name);
      Rose.System_Calls.Receive_Words (Params, 1);
      Rose.System_Calls.Invoke_Capability (Params);
      if Params.Control.Flags (Rose.Invocation.Error) then
         raise Rose.Interfaces.Objects.Invocation_Error
           with "Directory.Find_Entry";
      end if;
      return Natural (Rose.System_Calls.Get_Word_32 (Params, 0));
   end Find_Entry;

   --------------
   -- From_Cap --
   --------------

   function From_Cap
     (Cap : Rose.Capabilities.Capability)
      return Directory_Client
   is (Directory_Client'(Interface_Cap => Cap, others => <>));

   -------------------
   -- Get_Directory --
   -------------------

   overriding function Get_Directory
     (Item  : in out Directory_Client;
      Index : Positive)
      return Rose.Interfaces.Directory.Directory_Object'Class
   is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      if not Item.Is_Open then
         Load (Item);
      end if;
      Rose.System_Calls.Initialize_Send (Params, Item.Get_Directory);
      Rose.System_Calls.Send_Word (Params, Index);
      Rose.System_Calls.Receive_Caps (Params, 1);
      Rose.System_Calls.Invoke_Capability (Params);
      if Params.Control.Flags (Rose.Invocation.Error) then
         raise Rose.Interfaces.Objects.Invocation_Error
           with "Directory.Get_Directory";
      end if;
      return From_Cap (Params.Caps (0));
   end Get_Directory;

   -----------------------------------
   -- Get_Directory_Entry_Count_Cap --
   -----------------------------------

   function Get_Directory_Entry_Count_Cap
     (Item : in out Directory_Client)
      return Rose.Capabilities.Capability
   is
   begin
      if not Item.Is_Open then
         Load (Item);
      end if;
      return Item.Directory_Entry_Count;
   end Get_Directory_Entry_Count_Cap;

   ----------------------------------
   -- Get_Directory_Entry_Kind_Cap --
   ----------------------------------

   function Get_Directory_Entry_Kind_Cap
     (Item : in out Directory_Client)
      return Rose.Capabilities.Capability
   is
   begin
      if not Item.Is_Open then
         Load (Item);
      end if;
      return Item.Directory_Entry_Kind;
   end Get_Directory_Entry_Kind_Cap;

   ----------------------------------
   -- Get_Directory_Entry_Name_Cap --
   ----------------------------------

   function Get_Directory_Entry_Name_Cap
     (Item : in out Directory_Client)
      return Rose.Capabilities.Capability
   is
   begin
      if not Item.Is_Open then
         Load (Item);
      end if;
      return Item.Directory_Entry_Name;
   end Get_Directory_Entry_Name_Cap;

   ----------------------------------
   -- Get_Directory_Entry_Size_Cap --
   ----------------------------------

   function Get_Directory_Entry_Size_Cap
     (Item : in out Directory_Client)
      return Rose.Capabilities.Capability
   is
   begin
      if not Item.Is_Open then
         Load (Item);
      end if;
      return Item.Directory_Entry_Size;
   end Get_Directory_Entry_Size_Cap;

   ------------------------
   -- Get_Find_Entry_Cap --
   ------------------------

   function Get_Find_Entry_Cap
     (Item : in out Directory_Client)
      return Rose.Capabilities.Capability
   is
   begin
      if not Item.Is_Open then
         Load (Item);
      end if;
      return Item.Find_Entry;
   end Get_Find_Entry_Cap;

   ---------------------------
   -- Get_Get_Directory_Cap --
   ---------------------------

   function Get_Get_Directory_Cap
     (Item : in out Directory_Client)
      return Rose.Capabilities.Capability
   is
   begin
      if not Item.Is_Open then
         Load (Item);
      end if;
      return Item.Get_Directory;
   end Get_Get_Directory_Cap;

   -------------------------------
   -- Get_Get_Ordinary_File_Cap --
   -------------------------------

   function Get_Get_Ordinary_File_Cap
     (Item : in out Directory_Client)
      return Rose.Capabilities.Capability
   is
   begin
      if not Item.Is_Open then
         Load (Item);
      end if;
      return Item.Get_Ordinary_File;
   end Get_Get_Ordinary_File_Cap;

   -----------------------
   -- Get_Interface_Cap --
   -----------------------

   function Get_Interface_Cap
     (Item : Directory_Client)
      return Rose.Capabilities.Capability
   is (Item.Interface_Cap);

   -----------------------
   -- Get_Ordinary_File --
   -----------------------

   overriding function Get_Ordinary_File
     (Item  : in out Directory_Client;
      Index : Positive)
      return Rose.Interfaces.File.File_Object'Class
   is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      if not Item.Is_Open then
         Load (Item);
      end if;
      Rose.System_Calls.Initialize_Send (Params, Item.Get_Ordinary_File);
      Rose.System_Calls.Send_Word (Params, Index);
      Rose.System_Calls.Receive_Caps (Params, 1);
      Rose.System_Calls.Invoke_Capability (Params);
      if Params.Control.Flags (Rose.Invocation.Error) then
         raise Rose.Interfaces.Objects.Invocation_Error
           with "Directory.Get_Ordinary_File";
      end if;
      return Rose.Interfaces.File.Client.From_Cap (Params.Caps (0));
   end Get_Ordinary_File;

   ----------
   -- Load --
   ----------

   procedure Load (Item : in out Directory_Client) is
      Params : aliased Rose.Invocation.Invocation_Record;
   begin
      Rose.System_Calls.Initialize_Send (Params, Item.Interface_Cap);
      Rose.System_Calls.Receive_Caps (Params, Subprogram_Count);
      Rose.System_Calls.Invoke_Capability (Params);
      if Params.Control.Flags (Rose.Invocation.Error) then
         raise Rose.Interfaces.Objects.Invocation_Error with "Directory.Open";
      end if;
      Item.Directory_Entry_Count := Params.Caps (Directory_Entry_Count_Index);
      Item.Directory_Entry_Name := Params.Caps (Directory_Entry_Name_Index);
      Item.Directory_Entry_Kind := Params.Caps (Directory_Entry_Kind_Index);
      Item.Directory_Entry_Size := Params.Caps (Directory_Entry_Size_Index);
      Item.Find_Entry := Params.Caps (Find_Entry_Index);
      Item.Get_Ordinary_File := Params.Caps (Get_Ordinary_File_Index);
      Item.Get_Directory := Params.Caps (Get_Directory_Index);
      Item.Is_Open := True;
   end Load;

   ----------
   -- Open --
   ----------

   procedure Open
     (Client        : out Directory_Client;
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
