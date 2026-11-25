with Rose.Capabilities;

package Rose.Core.Edit_Client is

   procedure Call
     (Endpoint       : Rose.Capabilities.Capability;
      Standard_Error : Rose.Capabilities.Capability;
      Doc            : Rose.Capabilities.Capability;
      Doc_Selector   : Natural := 0;
      Lines          : Natural := 0;
      Input          : Rose.Capabilities.Capability;
      Input_Selector : Natural := 0);

end Rose.Core.Edit_Client;
