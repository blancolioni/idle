with Rose.Capabilities;
with Rose.Texts;
with Rose.Words;

package Rose.Interfaces.Exchange.Client is

   type Exchange_Client is
     limited new Rose.Interfaces.Exchange.Exchange_Object
     with private;

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

   function From_Cap
     (Cap : Rose.Capabilities.Capability)
      return Exchange_Client;

   procedure Close (Client : in out Exchange_Client);

   overriding procedure Create_Endpoint
     (Item    : in out Exchange_Client;
      Id      : Rose.Words.Word_64;
      Receive : out Rose.Capabilities.Capability;
      Send    : out Rose.Capabilities.Capability);

   overriding function Split
     (Item  : in out Exchange_Client;
      Whole : Rose.Capabilities.Capability;
      Part  : out Rose.Capabilities.Capability)
      return Rose.Capabilities.Capability;

   overriding procedure Rename
     (Item : in out Exchange_Client;
      Cap  : in out Rose.Capabilities.Capability;
      Name : in out Rose.Texts.Text);

   overriding procedure Partner
     (Item  : in out Exchange_Client;
      Other : in out Exchange_Client;
      Label : out Rose.Texts.Text);

   overriding procedure Gather
     (Item  : in out Exchange_Client;
      Caps  : Rose.Capabilities.Capability_Array;
      First : out Rose.Capabilities.Capability);

   overriding function Exchange_Cap
     (Item : in out Exchange_Client)
      return Rose.Capabilities.Capability;

   function Get_Interface_Cap
     (Item : Exchange_Client)
      return Rose.Capabilities.Capability;

   function Get_Create_Endpoint_Cap
     (Item : in out Exchange_Client)
      return Rose.Capabilities.Capability;

   function Get_Split_Cap
     (Item : in out Exchange_Client)
      return Rose.Capabilities.Capability;

   function Get_Rename_Cap
     (Item : in out Exchange_Client)
      return Rose.Capabilities.Capability;

   function Get_Partner_Cap
     (Item : in out Exchange_Client)
      return Rose.Capabilities.Capability;

   function Get_Gather_Cap
     (Item : in out Exchange_Client)
      return Rose.Capabilities.Capability;

private

   type Exchange_Client is
     limited new Rose.Interfaces.Exchange.Exchange_Object
   with record
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
