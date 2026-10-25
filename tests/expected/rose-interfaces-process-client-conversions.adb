package body Rose.Interfaces.Process.Client.Conversions is

   ------------
   -- To_Cap --
   ------------

   function To_Cap
     (Item : Process_Client)
      return Rose.Interfaces.Cap.Client.Cap_Client
   is
      Result : Rose.Interfaces.Cap.Client.Cap_Client;
   begin
      Rose.Interfaces.Cap.Client.Open_Cap_Set
        (Result,
         Item.Destroy,
         Item.Get_Object_Id);
      return Result;
   end To_Cap;

   ----------------
   -- To_Segment --
   ----------------

   function To_Segment
     (Item : Process_Client)
      return Rose.Interfaces.Segment.Client.Segment_Client
   is
      Result : Rose.Interfaces.Segment.Client.Segment_Client;
   begin
      Rose.Interfaces.Segment.Client.Open_Cap_Set
        (Result,
         Item.Add_Segment,
         Item.Add_Nonpersistent_Segment);
      return Result;
   end To_Segment;

   ---------------
   -- To_Server --
   ---------------

   function To_Server
     (Item : Process_Client)
      return Rose.Interfaces.Server.Client.Server_Client
   is
      Result : Rose.Interfaces.Server.Client.Server_Client;
   begin
      Rose.Interfaces.Server.Client.Open_Cap_Set
        (Result,
         Item.Published_Interface);
      return Result;
   end To_Server;

end Rose.Interfaces.Process.Client.Conversions;
