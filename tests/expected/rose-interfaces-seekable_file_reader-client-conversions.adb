with Rose.Invocation;
with Rose.System_Calls;

package body Rose.Interfaces.Seekable_File_Reader.Client.Conversions is

   --------------------
   -- To_File_Reader --
   --------------------

   function To_File_Reader
     (Item : Seekable_File_Reader_Client)
      return Rose.Interfaces.File_Reader.Client.File_Reader_Client
   is
      use type Rose.Capabilities.Capability;
      Params : aliased Rose.Invocation.Invocation_Record;
      Result : Rose.Interfaces.File_Reader.Client.File_Reader_Client;
   begin
      if Item.Interface_Cap = Rose.Capabilities.Null_Capability then
         Rose.Interfaces.File_Reader.Client.Open_Cap_Set
           (Result,
            Item.Read,
            Item.Release);
      else
         Rose.System_Calls.Initialize_Send (Params, Item.Interface_Cap);
         Rose.System_Calls.Send_Word (Params, Natural (3));
         Rose.System_Calls.Receive_Caps (Params, 1);
         Rose.System_Calls.Invoke_Capability (Params);
         Rose.Interfaces.File_Reader.Client.Open (Result, Params.Caps (0));
      end if;
      return Result;
   end To_File_Reader;

   -----------------
   -- To_Resource --
   -----------------

   function To_Resource
     (Item : Seekable_File_Reader_Client)
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
         Rose.System_Calls.Send_Word (Params, Natural (2));
         Rose.System_Calls.Receive_Caps (Params, 1);
         Rose.System_Calls.Invoke_Capability (Params);
         Rose.Interfaces.Resource.Client.Open (Result, Params.Caps (0));
      end if;
      return Result;
   end To_Resource;

   -----------------
   -- To_Seekable --
   -----------------

   function To_Seekable
     (Item : Seekable_File_Reader_Client)
      return Rose.Interfaces.Seekable.Client.Seekable_Client
   is
      use type Rose.Capabilities.Capability;
      Params : aliased Rose.Invocation.Invocation_Record;
      Result : Rose.Interfaces.Seekable.Client.Seekable_Client;
   begin
      if Item.Interface_Cap = Rose.Capabilities.Null_Capability then
         Rose.Interfaces.Seekable.Client.Open_Cap_Set (Result, Item.Seek);
      else
         Rose.System_Calls.Initialize_Send (Params, Item.Interface_Cap);
         Rose.System_Calls.Send_Word (Params, Natural (4));
         Rose.System_Calls.Receive_Caps (Params, 1);
         Rose.System_Calls.Invoke_Capability (Params);
         Rose.Interfaces.Seekable.Client.Open (Result, Params.Caps (0));
      end if;
      return Result;
   end To_Seekable;

   ----------------------
   -- To_Stream_Reader --
   ----------------------

   function To_Stream_Reader
     (Item : Seekable_File_Reader_Client)
      return Rose.Interfaces.Stream_Reader.Client.Stream_Reader_Client
   is
      use type Rose.Capabilities.Capability;
      Params : aliased Rose.Invocation.Invocation_Record;
      Result : Rose.Interfaces.Stream_Reader.Client.Stream_Reader_Client;
   begin
      if Item.Interface_Cap = Rose.Capabilities.Null_Capability then
         Rose.Interfaces.Stream_Reader.Client.Open_Cap_Set (Result, Item.Read);
      else
         Rose.System_Calls.Initialize_Send (Params, Item.Interface_Cap);
         Rose.System_Calls.Send_Word (Params, Natural (1));
         Rose.System_Calls.Receive_Caps (Params, 1);
         Rose.System_Calls.Invoke_Capability (Params);
         Rose.Interfaces.Stream_Reader.Client.Open (Result, Params.Caps (0));
      end if;
      return Result;
   end To_Stream_Reader;

end Rose.Interfaces.Seekable_File_Reader.Client.Conversions;
