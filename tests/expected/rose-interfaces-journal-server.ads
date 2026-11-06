with Rose.Capabilities;
with Rose.Objects;
with Rose.Server;
with System.Storage_Elements;

package Rose.Interfaces.Journal.Server is

   type Size_Handler is access function
     (Id : Rose.Objects.Capability_Identifier)
      return System.Storage_Elements.Storage_Count;

   type Open_Reader_Handler is access function
     (Id : Rose.Objects.Capability_Identifier)
      return Rose.Capabilities.Capability;

   type Open_Seekable_Reader_Handler is access function
     (Id : Rose.Objects.Capability_Identifier)
      return Rose.Capabilities.Capability;

   type Write_Handler is access procedure
     (Id     : Rose.Objects.Capability_Identifier;
      Buffer : System.Storage_Elements.Storage_Array);

   type Truncate_Handler is access procedure
     (Id   : Rose.Objects.Capability_Identifier;
      Size : System.Storage_Elements.Storage_Count);

   type New_Version_Handler is access function
     (Id : Rose.Objects.Capability_Identifier)
      return Rose.Capabilities.Capability;

   type Commit_Handler is access procedure
     (Id : Rose.Objects.Capability_Identifier);

   type Rollback_Handler is access procedure
     (Id : Rose.Objects.Capability_Identifier);

   type Release_Handler is access procedure
     (Id : Rose.Objects.Capability_Identifier);

   procedure Create_Server
     (Server_Context       : in out Rose.Server.Server_Context;
      Size                 : Size_Handler;
      Open_Reader          : Open_Reader_Handler;
      Open_Seekable_Reader : Open_Seekable_Reader_Handler;
      Write                : Write_Handler;
      Truncate             : Truncate_Handler;
      New_Version          : New_Version_Handler;
      Commit               : Commit_Handler;
      Rollback             : Rollback_Handler;
      Release              : Release_Handler;
      Instanced            : Boolean := False);

   procedure Attach_Interface
     (Server_Context       : in out Rose.Server.Server_Context;
      Size                 : Size_Handler;
      Open_Reader          : Open_Reader_Handler;
      Open_Seekable_Reader : Open_Seekable_Reader_Handler;
      Write                : Write_Handler;
      Truncate             : Truncate_Handler;
      New_Version          : New_Version_Handler;
      Commit               : Commit_Handler;
      Rollback             : Rollback_Handler;
      Release              : Release_Handler;
      Instanced            : Boolean := False);

   procedure Publish_Interface
     (Server_Context       : in out Rose.Server.Server_Context;
      Size                 : Size_Handler;
      Open_Reader          : Open_Reader_Handler;
      Open_Seekable_Reader : Open_Seekable_Reader_Handler;
      Write                : Write_Handler;
      Truncate             : Truncate_Handler;
      New_Version          : New_Version_Handler;
      Commit               : Commit_Handler;
      Rollback             : Rollback_Handler;
      Release              : Release_Handler);

   function Get_Size_Cap return Rose.Capabilities.Capability;

   function Get_Open_Reader_Cap return Rose.Capabilities.Capability;

   function Get_Open_Seekable_Reader_Cap return Rose.Capabilities.Capability;

   function Get_Write_Cap return Rose.Capabilities.Capability;

   function Get_Truncate_Cap return Rose.Capabilities.Capability;

   function Get_New_Version_Cap return Rose.Capabilities.Capability;

   function Get_Commit_Cap return Rose.Capabilities.Capability;

   function Get_Rollback_Cap return Rose.Capabilities.Capability;

   function Get_Release_Cap return Rose.Capabilities.Capability;

   procedure Remove_Instance (Identifier : Rose.Objects.Capability_Identifier);

end Rose.Interfaces.Journal.Server;
