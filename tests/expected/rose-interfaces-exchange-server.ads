with Rose.Capabilities;
with Rose.Objects;
with Rose.Server;
with Rose.Words;

package Rose.Interfaces.Exchange.Server is

   type Create_Endpoint_Handler is access procedure
     (Id      : Rose.Objects.Capability_Identifier;
      Id      : Rose.Words.Word_64;
      Receive : out Rose.Capabilities.Capability;
      Send    : out Rose.Capabilities.Capability);

   type Split_Handler is access function
     (Id    : Rose.Objects.Capability_Identifier;
      Whole : Rose.Capabilities.Capability;
      Part  : out Rose.Capabilities.Capability)
      return Rose.Capabilities.Capability;

   type Rename_Handler is access procedure
     (Id        : Rose.Objects.Capability_Identifier;
      Cap       : in out Rose.Capabilities.Capability;
      Name      : in out String;
      Name_Last : out Natural);

   type Partner_Handler is access procedure
     (Id         : Rose.Objects.Capability_Identifier;
      Other      : out Rose.Capabilities.Capability;
      Label      : out String;
      Label_Last : out Natural);

   type Gather_Handler is access procedure
     (Id    : Rose.Objects.Capability_Identifier;
      Caps  : Rose.Capabilities.Capability_Array;
      First : out Rose.Capabilities.Capability);

   procedure Create_Server
     (Server_Context  : in out Rose.Server.Server_Context;
      Create_Endpoint : Create_Endpoint_Handler;
      Split           : Split_Handler;
      Rename          : Rename_Handler;
      Partner         : Partner_Handler;
      Gather          : Gather_Handler;
      Instanced       : Boolean := False);

   procedure Attach_Interface
     (Server_Context  : in out Rose.Server.Server_Context;
      Create_Endpoint : Create_Endpoint_Handler;
      Split           : Split_Handler;
      Rename          : Rename_Handler;
      Partner         : Partner_Handler;
      Gather          : Gather_Handler;
      Instanced       : Boolean := False);

   procedure Publish_Interface
     (Server_Context  : in out Rose.Server.Server_Context;
      Create_Endpoint : Create_Endpoint_Handler;
      Split           : Split_Handler;
      Rename          : Rename_Handler;
      Partner         : Partner_Handler;
      Gather          : Gather_Handler);

   function Get_Create_Endpoint_Cap return Rose.Capabilities.Capability;

   function Get_Split_Cap return Rose.Capabilities.Capability;

   function Get_Rename_Cap return Rose.Capabilities.Capability;

   function Get_Partner_Cap return Rose.Capabilities.Capability;

   function Get_Gather_Cap return Rose.Capabilities.Capability;

   procedure Remove_Instance (Identifier : Rose.Objects.Capability_Identifier);

end Rose.Interfaces.Exchange.Server;
