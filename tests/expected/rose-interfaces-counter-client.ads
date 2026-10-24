with Rose.Capabilities;
with Rose.Invocation;
with Rose.Words;

package Rose.Interfaces.Counter.Client is

   type Counter_Client is private;

   procedure Open_Cap_Set
     (Client    : out Counter_Client;
      Badge     : Rose.Capabilities.Capability;
      Increment : Rose.Capabilities.Capability;
      Value     : Rose.Capabilities.Capability);

   procedure Open
     (Client        : out Counter_Client;
      Interface_Cap : Rose.Capabilities.Capability);

   procedure Close (Client : in out Counter_Client);

   function Badge (Item : Counter_Client) return Rose.Capabilities.Capability;

   procedure Increment (Item : Counter_Client; By : Rose.Words.Word);

   function Value (Item : Counter_Client) return Rose.Words.Word;

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

   function Has_Error return Boolean;

   function Get_Last_Error return Rose.Invocation.Invocation_Error;

private

   type Counter_Client is record
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
