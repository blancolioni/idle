with Rose.Capabilities;
with Rose.Interfaces.Common.Named;
with Rose.Words;

package Rose.Interfaces.Measures.Counter.Client is

   type Counter_Client is
     limited new Rose.Interfaces.Measures.Counter.Counter_Object
     with private;

   procedure Open_Cap_Set
     (Client    : out Counter_Client;
      Badge     : Rose.Capabilities.Capability;
      Increment : Rose.Capabilities.Capability;
      Value     : Rose.Capabilities.Capability;
      Label     : Rose.Capabilities.Capability;
      Twin      : Rose.Capabilities.Capability);

   procedure Open
     (Client        : out Counter_Client;
      Interface_Cap : Rose.Capabilities.Capability);

   function From_Cap
     (Cap : Rose.Capabilities.Capability)
      return Counter_Client;

   procedure Close (Client : in out Counter_Client);

   overriding function Badge
     (Item : in out Counter_Client)
      return Rose.Capabilities.Capability;

   overriding procedure Increment
     (Item : in out Counter_Client;
      By   : Rose.Words.Word);

   overriding function Value
     (Item : in out Counter_Client)
      return Rose.Words.Word;

   overriding function Label
     (Item : in out Counter_Client)
      return Rose.Interfaces.Common.Named.Named_Object'Class;

   overriding function Twin
     (Item : in out Counter_Client)
      return Rose.Interfaces.Measures.Counter.Counter_Object'Class;

   overriding function Counter_Cap
     (Item : in out Counter_Client)
      return Rose.Capabilities.Capability;

   overriding function Named_Cap
     (Item : in out Counter_Client)
      return Rose.Capabilities.Capability;

   function Get_Interface_Cap
     (Item : Counter_Client)
      return Rose.Capabilities.Capability;

   function Get_Badge_Cap
     (Item : in out Counter_Client)
      return Rose.Capabilities.Capability;

   function Get_Increment_Cap
     (Item : in out Counter_Client)
      return Rose.Capabilities.Capability;

   function Get_Value_Cap
     (Item : in out Counter_Client)
      return Rose.Capabilities.Capability;

   function Get_Label_Cap
     (Item : in out Counter_Client)
      return Rose.Capabilities.Capability;

   function Get_Twin_Cap
     (Item : in out Counter_Client)
      return Rose.Capabilities.Capability;

private

   type Counter_Client is
     limited new Rose.Interfaces.Measures.Counter.Counter_Object
   with record
      Is_Open             : Boolean := False;
      Interface_Cap       : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
      Named_Interface_Cap : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
      Badge               : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
      Increment           : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
      Value               : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
      Label               : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
      Twin                : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
   end record;

end Rose.Interfaces.Measures.Counter.Client;
