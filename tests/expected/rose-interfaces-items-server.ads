with Rose.Capabilities;
with Rose.Objects;
with Rose.Server;
with Rose.Words;
with System.Storage_Elements;

package Rose.Interfaces.Items.Server is

   type Pair_Handler is access function
     (Id       : Rose.Objects.Capability_Identifier;
      Name     : String;
      Password : String)
      return Rose.Capabilities.Capability;

   type Store_Handler is access procedure
     (Id    : Rose.Objects.Capability_Identifier;
      Index : Rose.Words.Word;
      Key   : String;
      Data  : System.Storage_Elements.Storage_Array;
      Owner : Rose.Capabilities.Capability);

   type Single_Handler is access procedure
     (Id   : Rose.Objects.Capability_Identifier;
      Name : String);

   procedure Create_Server
     (Server_Context : in out Rose.Server.Server_Context;
      Pair           : Pair_Handler;
      Store          : Store_Handler;
      Single         : Single_Handler;
      Instanced      : Boolean := False);

   procedure Attach_Interface
     (Server_Context : in out Rose.Server.Server_Context;
      Pair           : Pair_Handler;
      Store          : Store_Handler;
      Single         : Single_Handler;
      Instanced      : Boolean := False);

   procedure Publish_Interface
     (Server_Context : in out Rose.Server.Server_Context;
      Pair           : Pair_Handler;
      Store          : Store_Handler;
      Single         : Single_Handler);

   function Get_Pair_Cap return Rose.Capabilities.Capability;

   function Get_Store_Cap return Rose.Capabilities.Capability;

   function Get_Single_Cap return Rose.Capabilities.Capability;

   procedure Remove_Instance (Identifier : Rose.Objects.Capability_Identifier);

end Rose.Interfaces.Items.Server;
