with Rose.Capabilities;
with Rose.Invocation;
with Rose.Words;

package Rose.Interfaces.Exchange.Client is

   type Exchange_Client is private;

   procedure Open_Cap_Set
     (Client          : out Exchange_Client;
      Create_Endpoint : Rose.Capabilities.Capability;
      Split           : Rose.Capabilities.Capability;
      Rename          : Rose.Capabilities.Capability;
      Partner         : Rose.Capabilities.Capability;
      Gather          : Rose.Capabilities.Capability);

   procedure Open
     (Client        : out Exchange_Client;
      Interface_Cap : Rose.Capabilities.Capability);

   procedure Close (Client : in out Exchange_Client);

   procedure Create_Endpoint
     (Item    : Exchange_Client;
      Id      : Rose.Words.Word_64;
      Receive : out Rose.Capabilities.Capability;
      Send    : out Rose.Capabilities.Capability);

   function Split
     (Item  : Exchange_Client;
      Whole : Rose.Capabilities.Capability;
      Part  : out Rose.Capabilities.Capability)
      return Rose.Capabilities.Capability;

   procedure Rename
     (Item      : Exchange_Client;
      Cap       : in out Rose.Capabilities.Capability;
      Name      : in out String;
      Name_Last : out Natural);

   procedure Partner
     (Item       : Exchange_Client;
      Other      : out Exchange_Client;
      Label      : out String;
      Label_Last : out Natural);

   procedure Gather
     (Item  : Exchange_Client;
      Caps  : Rose.Capabilities.Capability_Array;
      First : out Rose.Capabilities.Capability);

   function Get_Interface_Cap
     (Item : Exchange_Client)
      return Rose.Capabilities.Capability;

   function Get_Create_Endpoint_Cap
     (Item : Exchange_Client)
      return Rose.Capabilities.Capability;

   function Get_Split_Cap
     (Item : Exchange_Client)
      return Rose.Capabilities.Capability;

   function Get_Rename_Cap
     (Item : Exchange_Client)
      return Rose.Capabilities.Capability;

   function Get_Partner_Cap
     (Item : Exchange_Client)
      return Rose.Capabilities.Capability;

   function Get_Gather_Cap
     (Item : Exchange_Client)
      return Rose.Capabilities.Capability;

   function Has_Error return Boolean;

   function Get_Last_Error return Rose.Invocation.Invocation_Error;

private

   type Exchange_Client is record
      Is_Open         : Boolean := False;
      Interface_Cap   : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
      Create_Endpoint : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
      Split           : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
      Rename          : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
      Partner         : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
      Gather          : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
   end record;

end Rose.Interfaces.Exchange.Client;
