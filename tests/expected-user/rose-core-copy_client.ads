with Rose.Capabilities;
with Rose.Command_Line;

package Rose.Core.Copy_Client is

   procedure Call
     (Endpoint        : Rose.Capabilities.Capability;
      Standard_Error  : Rose.Capabilities.Capability;
      Logging         : Rose.Capabilities.Capability;
      Create_Endpoint : Rose.Capabilities.Capability;
      Delete_Cap      : Rose.Capabilities.Capability;
      Source          : Rose.Capabilities.Capability;
      Target          : Rose.Capabilities.Capability;
      Root            : Rose.Capabilities.Capability;
      Batch           : Rose.Capabilities.Capability;
      Draft           : Rose.Capabilities.Capability;
      Ledger          : Rose.Capabilities.Capability;
      Copied          : out Rose.Capabilities.Capability;
      Count           : out Natural;
      Verbose         : Boolean := False;
      Report          : out Rose.Command_Line.Text;
      Note            : String := "none");

end Rose.Core.Copy_Client;
