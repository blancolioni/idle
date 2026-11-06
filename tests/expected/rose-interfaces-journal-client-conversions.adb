with Rose.Invocation;
with Rose.System_Calls;

package body Rose.Interfaces.Journal.Client.Conversions is

   -------------
   -- To_File --
   -------------

   function To_File
     (Item : Journal_Client)
      return Rose.Interfaces.File.Client.File_Client
   is
      use type Rose.Capabilities.Capability;
      Params : aliased Rose.Invocation.Invocation_Record;
      Result : Rose.Interfaces.File.Client.File_Client;
   begin
      if Item.Interface_Cap = Rose.Capabilities.Null_Capability then
         Rose.Interfaces.File.Client.Open_Cap_Set
           (Result,
            Item.Size,
            Item.Open_Reader,
            Item.Open_Seekable_Reader);
      else
         Rose.System_Calls.Initialize_Send (Params, Item.Interface_Cap);
         Rose.System_Calls.Send_Word (Params, Natural (1));
         Rose.System_Calls.Receive_Caps (Params, 1);
         Rose.System_Calls.Invoke_Capability (Params);
         Rose.Interfaces.File.Client.Open (Result, Params.Caps (0));
      end if;
      return Result;
   end To_File;

   -----------------
   -- To_Resource --
   -----------------

   function To_Resource
     (Item : Journal_Client)
      return Rose.Interfaces.Resource.Client.Resource_Client
   is
      use type Rose.Capabilities.Capability;
      Params : aliased Rose.Invocation.Invocation_Record;
      Result : Rose.Interfaces.Resource.Client.Resource_Client;
   begin
      if Item.Interface_Cap = Rose.Capabilities.Null_Capability then
         Rose.Interfaces.Resource.Client.Open_Cap_Set (Result, Item.Release);
      else
         Rose.System_Calls.Initialize_Send (Params, Item.Interface_Cap);
         Rose.System_Calls.Send_Word (Params, Natural (5));
         Rose.System_Calls.Receive_Caps (Params, 1);
         Rose.System_Calls.Invoke_Capability (Params);
         Rose.Interfaces.Resource.Client.Open (Result, Params.Caps (0));
      end if;
      return Result;
   end To_Resource;

   ----------------------
   -- To_Stream_Writer --
   ----------------------

   function To_Stream_Writer
     (Item : Journal_Client)
      return Rose.Interfaces.Stream_Writer.Client.Stream_Writer_Client
   is
      use type Rose.Capabilities.Capability;
      Params : aliased Rose.Invocation.Invocation_Record;
      Result : Rose.Interfaces.Stream_Writer.Client.Stream_Writer_Client;
   begin
      if Item.Interface_Cap = Rose.Capabilities.Null_Capability then
         Rose.Interfaces.Stream_Writer.Client.Open_Cap_Set
           (Result,
            Item.Write);
      else
         Rose.System_Calls.Initialize_Send (Params, Item.Interface_Cap);
         Rose.System_Calls.Send_Word (Params, Natural (2));
         Rose.System_Calls.Receive_Caps (Params, 1);
         Rose.System_Calls.Invoke_Capability (Params);
         Rose.Interfaces.Stream_Writer.Client.Open (Result, Params.Caps (0));
      end if;
      return Result;
   end To_Stream_Writer;

   ----------------------
   -- To_Transactional --
   ----------------------

   function To_Transactional
     (Item : Journal_Client)
      return Rose.Interfaces.Transactional.Client.Transactional_Client
   is
      use type Rose.Capabilities.Capability;
      Params : aliased Rose.Invocation.Invocation_Record;
      Result : Rose.Interfaces.Transactional.Client.Transactional_Client;
   begin
      if Item.Interface_Cap = Rose.Capabilities.Null_Capability then
         Rose.Interfaces.Transactional.Client.Open_Cap_Set
           (Result,
            Item.Commit,
            Item.Rollback);
      else
         Rose.System_Calls.Initialize_Send (Params, Item.Interface_Cap);
         Rose.System_Calls.Send_Word (Params, Natural (4));
         Rose.System_Calls.Receive_Caps (Params, 1);
         Rose.System_Calls.Invoke_Capability (Params);
         Rose.Interfaces.Transactional.Client.Open (Result, Params.Caps (0));
      end if;
      return Result;
   end To_Transactional;

   ------------------------------------
   -- To_Transactional_Writable_File --
   ------------------------------------

   function To_Transactional_Writable_File
     (Item : Journal_Client)
      return
        Rose.Interfaces.Transactional_Writable_File.Client
          .Transactional_Writable_File_Client
   is
      use type Rose.Capabilities.Capability;
      Params : aliased Rose.Invocation.Invocation_Record;
      Result : Rose.Interfaces.Transactional_Writable_File.Client
        .Transactional_Writable_File_Client;
   begin
      if Item.Interface_Cap = Rose.Capabilities.Null_Capability then
         Rose.Interfaces.Transactional_Writable_File.Client.Open_Cap_Set
           (Result,
            Item.Size,
            Item.Open_Reader,
            Item.Open_Seekable_Reader,
            Item.Write,
            Item.Truncate,
            Item.New_Version,
            Item.Commit,
            Item.Rollback,
            Item.Release);
      else
         Rose.System_Calls.Initialize_Send (Params, Item.Interface_Cap);
         Rose.System_Calls.Send_Word (Params, Natural (6));
         Rose.System_Calls.Receive_Caps (Params, 1);
         Rose.System_Calls.Invoke_Capability (Params);
         Rose.Interfaces.Transactional_Writable_File.Client.Open
           (Result,
            Params.Caps (0));
      end if;
      return Result;
   end To_Transactional_Writable_File;

   ----------------------
   -- To_Writable_File --
   ----------------------

   function To_Writable_File
     (Item : Journal_Client)
      return Rose.Interfaces.Writable_File.Client.Writable_File_Client
   is
      use type Rose.Capabilities.Capability;
      Params : aliased Rose.Invocation.Invocation_Record;
      Result : Rose.Interfaces.Writable_File.Client.Writable_File_Client;
   begin
      if Item.Interface_Cap = Rose.Capabilities.Null_Capability then
         Rose.Interfaces.Writable_File.Client.Open_Cap_Set
           (Result,
            Item.Size,
            Item.Open_Reader,
            Item.Open_Seekable_Reader,
            Item.Write,
            Item.Truncate,
            Item.New_Version);
      else
         Rose.System_Calls.Initialize_Send (Params, Item.Interface_Cap);
         Rose.System_Calls.Send_Word (Params, Natural (3));
         Rose.System_Calls.Receive_Caps (Params, 1);
         Rose.System_Calls.Invoke_Capability (Params);
         Rose.Interfaces.Writable_File.Client.Open (Result, Params.Caps (0));
      end if;
      return Result;
   end To_Writable_File;

end Rose.Interfaces.Journal.Client.Conversions;
