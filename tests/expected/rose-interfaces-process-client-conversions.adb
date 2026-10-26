with Rose.Invocation;
with Rose.System_Calls;

package body Rose.Interfaces.Process.Client.Conversions is

   ------------
   -- To_Cap --
   ------------

   function To_Cap
     (Item : Process_Client)
      return Rose.Interfaces.Cap.Client.Cap_Client
   is
      use type Rose.Capabilities.Capability;
      Params : aliased Rose.Invocation.Invocation_Record;
      Result : Rose.Interfaces.Cap.Client.Cap_Client;
   begin
      if Item.Interface_Cap = Rose.Capabilities.Null_Capability then
         Rose.Interfaces.Cap.Client.Open_Cap_Set
           (Result,
            Item.Destroy,
            Item.Get_Object_Id);
      else
         Rose.System_Calls.Initialize_Send (Params, Item.Interface_Cap);
         Rose.System_Calls.Send_Word (Params, Natural (3));
         Rose.System_Calls.Receive_Caps (Params, 1);
         Rose.System_Calls.Invoke_Capability (Params);
         Rose.Interfaces.Cap.Client.Open (Result, Params.Caps (0));
      end if;
      return Result;
   end To_Cap;

   ----------------
   -- To_Segment --
   ----------------

   function To_Segment
     (Item : Process_Client)
      return Rose.Interfaces.Segment.Client.Segment_Client
   is
      use type Rose.Capabilities.Capability;
      Params : aliased Rose.Invocation.Invocation_Record;
      Result : Rose.Interfaces.Segment.Client.Segment_Client;
   begin
      if Item.Interface_Cap = Rose.Capabilities.Null_Capability then
         Rose.Interfaces.Segment.Client.Open_Cap_Set
           (Result,
            Item.Add_Segment,
            Item.Add_Nonpersistent_Segment);
      else
         Rose.System_Calls.Initialize_Send (Params, Item.Interface_Cap);
         Rose.System_Calls.Send_Word (Params, Natural (1));
         Rose.System_Calls.Receive_Caps (Params, 1);
         Rose.System_Calls.Invoke_Capability (Params);
         Rose.Interfaces.Segment.Client.Open (Result, Params.Caps (0));
      end if;
      return Result;
   end To_Segment;

   ---------------
   -- To_Server --
   ---------------

   function To_Server
     (Item : Process_Client)
      return Rose.Interfaces.Server.Client.Server_Client
   is
      use type Rose.Capabilities.Capability;
      Params : aliased Rose.Invocation.Invocation_Record;
      Result : Rose.Interfaces.Server.Client.Server_Client;
   begin
      if Item.Interface_Cap = Rose.Capabilities.Null_Capability then
         Rose.Interfaces.Server.Client.Open_Cap_Set
           (Result,
            Item.Published_Interface);
      else
         Rose.System_Calls.Initialize_Send (Params, Item.Interface_Cap);
         Rose.System_Calls.Send_Word (Params, Natural (2));
         Rose.System_Calls.Receive_Caps (Params, 1);
         Rose.System_Calls.Invoke_Capability (Params);
         Rose.Interfaces.Server.Client.Open (Result, Params.Caps (0));
      end if;
      return Result;
   end To_Server;

end Rose.Interfaces.Process.Client.Conversions;
