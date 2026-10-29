with Rose.Invocation;
with Rose.System_Calls;

package body Rose.Interfaces.Items.Server is

   Server_Instance : Rose.Server.Server_Instance;

   Local_Pair      : Pair_Handler;

   Pair_Cap        : Rose.Capabilities.Capability :=
     Rose.Capabilities.Null_Capability;

   Local_Store     : Store_Handler;

   Store_Cap       : Rose.Capabilities.Capability :=
     Rose.Capabilities.Null_Capability;

   Local_Single    : Single_Handler;

   Single_Cap      : Rose.Capabilities.Capability :=
     Rose.Capabilities.Null_Capability;

   Published_Cap   : Rose.Capabilities.Capability :=
     Rose.Capabilities.Null_Capability;

   procedure Handle_Get_Items_Interface
     (Parameters : in out Rose.Invocation.Invocation_Record);

   procedure Handle_Pair
     (Parameters : in out Rose.Invocation.Invocation_Record);

   procedure Handle_Store
     (Parameters : in out Rose.Invocation.Invocation_Record);

   procedure Handle_Single
     (Parameters : in out Rose.Invocation.Invocation_Record);

   ----------------------
   -- Attach_Interface --
   ----------------------

   procedure Attach_Interface
     (Server_Context : in out Rose.Server.Server_Context;
      Pair           : Pair_Handler;
      Store          : Store_Handler;
      Single         : Single_Handler;
      Instanced      : Boolean := False)
   is
   begin
      Local_Pair := Pair;
      Local_Store := Store;
      Local_Single := Single;
      Rose.Server.Register_Handler
        (Server_Context,
         Items_Interface,
         Handle_Get_Items_Interface'Access);
      if not Instanced then
         Pair_Cap := Rose.Server.Create_Endpoint (Pair_Endpoint);
         Store_Cap := Rose.Server.Create_Endpoint (Store_Endpoint);
         Single_Cap := Rose.Server.Create_Endpoint (Single_Endpoint);
         Rose.Server.Create_Anonymous_Endpoint (Items_Interface);
      end if;
      Rose.Server.Register_Handler
        (Server_Context,
         Pair_Endpoint,
         Handle_Pair'Access);
      Rose.Server.Register_Handler
        (Server_Context,
         Store_Endpoint,
         Handle_Store'Access);
      Rose.Server.Register_Handler
        (Server_Context,
         Single_Endpoint,
         Handle_Single'Access);
   end Attach_Interface;

   -------------------
   -- Create_Server --
   -------------------

   procedure Create_Server
     (Server_Context : in out Rose.Server.Server_Context;
      Pair           : Pair_Handler;
      Store          : Store_Handler;
      Single         : Single_Handler;
      Instanced      : Boolean := False)
   is
   begin
      Attach_Interface (Server_Context, Pair, Store, Single, Instanced);
   end Create_Server;

   ------------------
   -- Get_Pair_Cap --
   ------------------

   function Get_Pair_Cap return Rose.Capabilities.Capability is (Pair_Cap);

   --------------------
   -- Get_Single_Cap --
   --------------------

   function Get_Single_Cap return Rose.Capabilities.Capability is (Single_Cap);

   -------------------
   -- Get_Store_Cap --
   -------------------

   function Get_Store_Cap return Rose.Capabilities.Capability is (Store_Cap);

   --------------------------------
   -- Handle_Get_Items_Interface --
   --------------------------------

   procedure Handle_Get_Items_Interface
     (Parameters : in out Rose.Invocation.Invocation_Record)
   is
      use type Rose.Capabilities.Capability;
      Cap        : Rose.Capabilities.Capability;
      Identifier : constant Rose.Objects.Capability_Identifier :=
        Parameters.Identifier;
   begin
      Rose.System_Calls.Initialize_Reply (Parameters, Parameters.Reply_Cap);
      if Pair_Cap = Rose.Capabilities.Null_Capability then
         if not Rose.Server.Has_Instance
           (Server_Instance,
            Pair_Endpoint,
            Identifier)
         then
            Rose.Server.Set_Instance_Cap
              (Server_Instance,
               Pair_Endpoint,
               Identifier,
               Rose.Server.Create_Endpoint (Pair_Endpoint, Identifier));
         end if;
         Cap :=
           Rose.Server.Get_Instance_Cap
             (Server_Instance,
              Pair_Endpoint,
              Identifier);
      else
         Cap := Pair_Cap;
      end if;
      Rose.System_Calls.Send_Cap (Parameters, Cap);
      if Store_Cap = Rose.Capabilities.Null_Capability then
         if not Rose.Server.Has_Instance
           (Server_Instance,
            Store_Endpoint,
            Identifier)
         then
            Rose.Server.Set_Instance_Cap
              (Server_Instance,
               Store_Endpoint,
               Identifier,
               Rose.Server.Create_Endpoint (Store_Endpoint, Identifier));
         end if;
         Cap :=
           Rose.Server.Get_Instance_Cap
             (Server_Instance,
              Store_Endpoint,
              Identifier);
      else
         Cap := Store_Cap;
      end if;
      Rose.System_Calls.Send_Cap (Parameters, Cap);
      if Single_Cap = Rose.Capabilities.Null_Capability then
         if not Rose.Server.Has_Instance
           (Server_Instance,
            Single_Endpoint,
            Identifier)
         then
            Rose.Server.Set_Instance_Cap
              (Server_Instance,
               Single_Endpoint,
               Identifier,
               Rose.Server.Create_Endpoint (Single_Endpoint, Identifier));
         end if;
         Cap :=
           Rose.Server.Get_Instance_Cap
             (Server_Instance,
              Single_Endpoint,
              Identifier);
      else
         Cap := Single_Cap;
      end if;
      Rose.System_Calls.Send_Cap (Parameters, Cap);
   end Handle_Get_Items_Interface;

   -----------------
   -- Handle_Pair --
   -----------------

   procedure Handle_Pair
     (Parameters : in out Rose.Invocation.Invocation_Record)
   is
      Name_Item     : constant Rose.System_Calls.Buffer_Item :=
        Rose.System_Calls.Get_Buffer_Item (Parameters, 1);
      Name          : String (1 .. Natural (Name_Item.Length))
        with Import, Address => Name_Item.Address;
      Password_Item : constant Rose.System_Calls.Buffer_Item :=
        Rose.System_Calls.Get_Buffer_Item (Parameters, 2);
      Password      : String (1 .. Natural (Password_Item.Length))
        with Import, Address => Password_Item.Address;
      Result        : constant Rose.Capabilities.Capability :=
        Local_Pair (Parameters.Identifier, Name, Password);
   begin
      Rose.System_Calls.Initialize_Reply (Parameters, Parameters.Reply_Cap);
      Rose.System_Calls.Send_Cap (Parameters, Result);
   end Handle_Pair;

   -------------------
   -- Handle_Single --
   -------------------

   procedure Handle_Single
     (Parameters : in out Rose.Invocation.Invocation_Record)
   is
      Name : String (1 .. Natural (Parameters.Buffer_Length))
        with Import, Address => Parameters.Buffer_Address;
   begin
      Local_Single (Parameters.Identifier, Name);
      Rose.System_Calls.Initialize_Reply (Parameters, Parameters.Reply_Cap);
   end Handle_Single;

   ------------------
   -- Handle_Store --
   ------------------

   procedure Handle_Store
     (Parameters : in out Rose.Invocation.Invocation_Record)
   is
      Index     : constant Rose.Words.Word :=
        Rose.System_Calls.Get_Word_32 (Parameters, 0);
      Key_Item  : constant Rose.System_Calls.Buffer_Item :=
        Rose.System_Calls.Get_Buffer_Item (Parameters, 1);
      Key       : String (1 .. Natural (Key_Item.Length))
        with Import, Address => Key_Item.Address;
      Data_Item : constant Rose.System_Calls.Buffer_Item :=
        Rose.System_Calls.Get_Buffer_Item (Parameters, 2);
      Data      : System.Storage_Elements.Storage_Array (1 .. Data_Item.Length)
        with Import, Address => Data_Item.Address;
      Owner     : constant Rose.Capabilities.Capability := Parameters.Caps (0);
   begin
      Local_Store (Parameters.Identifier, Index, Key, Data, Owner);
      Rose.System_Calls.Initialize_Reply (Parameters, Parameters.Reply_Cap);
   end Handle_Store;

   -----------------------
   -- Publish_Interface --
   -----------------------

   procedure Publish_Interface
     (Server_Context : in out Rose.Server.Server_Context;
      Pair           : Pair_Handler;
      Store          : Store_Handler;
      Single         : Single_Handler)
   is
   begin
      Local_Pair := Pair;
      Local_Store := Store;
      Local_Single := Single;
      Pair_Cap := Rose.Server.Create_Endpoint (Pair_Endpoint);
      Store_Cap := Rose.Server.Create_Endpoint (Store_Endpoint);
      Single_Cap := Rose.Server.Create_Endpoint (Single_Endpoint);
      Published_Cap := Rose.Server.Create_Endpoint (Items_Interface);
      Rose.Server.Register_Handler
        (Server_Context,
         Items_Interface,
         Handle_Get_Items_Interface'Access);
      Rose.Server.Register_Handler
        (Server_Context,
         Pair_Endpoint,
         Handle_Pair'Access);
      Rose.Server.Register_Handler
        (Server_Context,
         Store_Endpoint,
         Handle_Store'Access);
      Rose.Server.Register_Handler
        (Server_Context,
         Single_Endpoint,
         Handle_Single'Access);
      Rose.Server.Publish_Interface (Published_Cap);
   end Publish_Interface;

   ---------------------
   -- Remove_Instance --
   ---------------------

   procedure Remove_Instance
     (Identifier : Rose.Objects.Capability_Identifier)
   is
   begin
      Rose.Server.Remove_Instance (Server_Instance, Identifier);
   end Remove_Instance;

end Rose.Interfaces.Items.Server;
