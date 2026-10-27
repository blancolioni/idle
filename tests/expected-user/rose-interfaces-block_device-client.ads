with Rose.Capabilities;
with System.Storage_Elements;

package Rose.Interfaces.Block_Device.Client is

   type Block_Device_Client is
     limited new Rose.Interfaces.Block_Device.Block_Device_Object
     with private;

   procedure Open_Cap_Set
     (Client         : out Block_Device_Client;
      Get_Parameters : Rose.Capabilities.Capability;
      Read_Blocks    : Rose.Capabilities.Capability;
      Write_Blocks   : Rose.Capabilities.Capability);

   procedure Open
     (Client        : out Block_Device_Client;
      Interface_Cap : Rose.Capabilities.Capability);

   function From_Cap
     (Cap : Rose.Capabilities.Capability)
      return Block_Device_Client;

   procedure Close (Client : in out Block_Device_Client);

   overriding procedure Get_Parameters
     (Item        : in out Block_Device_Client;
      Block_Count : out Rose.Interfaces.Block_Device.Block_Address_Type;
      Block_Size  : out Rose.Interfaces.Block_Device.Block_Size_Type);

   overriding procedure Read_Blocks
     (Item   : in out Block_Device_Client;
      Start  : Rose.Interfaces.Block_Device.Block_Address_Type;
      Count  : Natural;
      Blocks : out System.Storage_Elements.Storage_Array);

   overriding procedure Write_Blocks
     (Item   : in out Block_Device_Client;
      Start  : Rose.Interfaces.Block_Device.Block_Address_Type;
      Count  : Natural;
      Blocks : System.Storage_Elements.Storage_Array);

   overriding function Block_Device_Cap
     (Item : in out Block_Device_Client)
      return Rose.Capabilities.Capability;

   function Get_Interface_Cap
     (Item : Block_Device_Client)
      return Rose.Capabilities.Capability;

   function Get_Get_Parameters_Cap
     (Item : in out Block_Device_Client)
      return Rose.Capabilities.Capability;

   function Get_Read_Blocks_Cap
     (Item : in out Block_Device_Client)
      return Rose.Capabilities.Capability;

   function Get_Write_Blocks_Cap
     (Item : in out Block_Device_Client)
      return Rose.Capabilities.Capability;

private

   type Block_Device_Client is
     limited new Rose.Interfaces.Block_Device.Block_Device_Object
   with record
      Is_Open        : Boolean := False;
      Interface_Cap  : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
      Get_Parameters : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
      Read_Blocks    : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
      Write_Blocks   : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
   end record;

end Rose.Interfaces.Block_Device.Client;
