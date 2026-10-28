with Rose.Invocation;
with Rose.System_Calls;

package body Rose.Interfaces.File_Reader.Client.Conversions is

   -----------------
   -- To_Resource --
   -----------------

   function To_Resource
     (Item : File_Reader_Client)
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

   ----------------------
   -- To_Stream_Reader --
   ----------------------

   function To_Stream_Reader
     (Item : File_Reader_Client)
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

end Rose.Interfaces.File_Reader.Client.Conversions;
