with Rose.Capabilities;
with Rose.Objects;
with Rose.Strings;
with Rose.Words;
limited with Rose.Interfaces.Exchange.Client;

package Rose.Interfaces.Exchange is

   Exchange_Interface       : constant Rose.Objects.Endpoint_Id :=
     16#930B_6D6B_463C_5A3D#;

   Create_Endpoint_Endpoint : constant Rose.Objects.Endpoint_Id :=
     16#7434_0B0E_7CAF_645A#;

   Split_Endpoint           : constant Rose.Objects.Endpoint_Id :=
     16#92A_77B5_5699_F1C6#;

   Rename_Endpoint          : constant Rose.Objects.Endpoint_Id :=
     16#D3BB_D15A_CEF9_E102#;

   Partner_Endpoint         : constant Rose.Objects.Endpoint_Id :=
     16#7C39_929A_8C5D_E6CF#;

   Gather_Endpoint          : constant Rose.Objects.Endpoint_Id :=
     16#8A1A_E55F_4C75_9986#;

   Create_Endpoint_Index    : constant := 0;

   Split_Index              : constant := 1;

   Rename_Index             : constant := 2;

   Partner_Index            : constant := 3;

   Gather_Index             : constant := 4;

   Subprogram_Count         : constant := 5;

   type Exchange_Object is limited interface;

   function Exchange_Cap
     (Item : in out Exchange_Object)
      return Rose.Capabilities.Capability is abstract;

   procedure Create_Endpoint
     (Item    : in out Exchange_Object;
      Id      : Rose.Words.Word_64;
      Receive : out Rose.Capabilities.Capability;
      Send    : out Rose.Capabilities.Capability) is abstract;

   function Split
     (Item  : in out Exchange_Object;
      Whole : Rose.Capabilities.Capability;
      Part  : out Rose.Capabilities.Capability)
      return Rose.Capabilities.Capability is abstract;

   procedure Rename
     (Item : in out Exchange_Object;
      Cap  : in out Rose.Capabilities.Capability;
      Name : in out Rose.Strings.Text) is abstract;

   procedure Partner
     (Item  : in out Exchange_Object;
      Other : in out Rose.Interfaces.Exchange.Client.Exchange_Client;
      Label : out Rose.Strings.Text) is abstract;

   procedure Gather
     (Item  : in out Exchange_Object;
      Caps  : Rose.Capabilities.Capability_Array;
      First : out Rose.Capabilities.Capability) is abstract;

end Rose.Interfaces.Exchange;
