with Rose.Invocation;
with Rose.System_Calls;

package body Rose.Interfaces.Writable_File.Client.Conversions is

   -------------
   -- To_File --
   -------------

   function To_File
     (Item : Writable_File_Client)
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

   ----------------------
   -- To_Stream_Writer --
   ----------------------

   function To_Stream_Writer
     (Item : Writable_File_Client)
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

end Rose.Interfaces.Writable_File.Client.Conversions;
