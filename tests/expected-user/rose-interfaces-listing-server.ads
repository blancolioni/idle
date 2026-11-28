with Rose.Capabilities;
with Rose.Objects;
with Rose.Server;

package Rose.Interfaces.Listing.Server is

   type Listing_Interface is limited interface
     and Rose.Interfaces.Listing.Listing_Object;

   procedure Attach
     (Server_Context : in out Rose.Server.Server_Context;
      Object         : not null access Listing_Interface'Class;
      Identifier     : Rose.Objects.Capability_Identifier := 0);

   procedure Publish
     (Server_Context : in out Rose.Server.Server_Context;
      Object         : not null access Listing_Interface'Class);

   function Interface_Cap
     (Server_Context : Rose.Server.Server_Context;
      Object         : not null access Listing_Interface'Class)
      return Rose.Capabilities.Capability;

   function Identifier_Of
     (Server_Context : Rose.Server.Server_Context;
      Object         : not null access Listing_Interface'Class)
      return Rose.Objects.Capability_Identifier;

   function Cap_Of
     (Server_Context : Rose.Server.Server_Context;
      Object         : Listing_Interface'Class;
      Interface_Id   : Rose.Objects.Endpoint_Id :=
        Rose.Interfaces.Listing.Listing_Interface)
      return Rose.Capabilities.Capability;

end Rose.Interfaces.Listing.Server;
