with Rose.Capabilities;
with Rose.Words;

package Rose.Interfaces.Counter.Client is

   type Counter_Client is
     limited new Rose.Interfaces.Counter.Counter_Object
     with private;

   procedure Open_Cap_Set
     (Client    : out Counter_Client;
      Badge     : Rose.Capabilities.Capability;
      Increment : Rose.Capabilities.Capability;
      Value     : Rose.Capabilities.Capability);

   procedure Open
     (Client        : out Counter_Client;
      Interface_Cap : Rose.Capabilities.Capability);

   procedure Close (Client : in out Counter_Client);

   overriding function Badge
     (Item : Counter_Client)
      return Rose.Capabilities.Capability;

   overriding procedure Increment
     (Item : in out Counter_Client;
      By   : Rose.Words.Word);

   overriding function Value (Item : Counter_Client) return Rose.Words.Word;

   function Get_Interface_Cap
     (Item : Counter_Client)
      return Rose.Capabilities.Capability;

   function Get_Badge_Cap
     (Item : Counter_Client)
      return Rose.Capabilities.Capability;

   function Get_Increment_Cap
     (Item : Counter_Client)
      return Rose.Capabilities.Capability;

   function Get_Value_Cap
     (Item : Counter_Client)
      return Rose.Capabilities.Capability;

private

   type Counter_Client is
     limited new Rose.Interfaces.Counter.Counter_Object
   with record
      Is_Open       : Boolean := False;
      Interface_Cap : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
      Badge         : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
      Increment     : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
      Value         : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
   end record;

end Rose.Interfaces.Counter.Client;
