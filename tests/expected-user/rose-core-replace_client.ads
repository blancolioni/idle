with Rose.Capabilities;

package Rose.Core.Replace_Client is

   procedure Call
     (Endpoint        : Rose.Capabilities.Capability;
      Create_Endpoint : Rose.Capabilities.Capability;
      Cap_Set_Service : Rose.Capabilities.Capability;
      Result          : out Rose.Capabilities.Capability;
      Previous        : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability;
      Saved           : Rose.Capabilities.Capability :=
        Rose.Capabilities.Null_Capability);

end Rose.Core.Replace_Client;
