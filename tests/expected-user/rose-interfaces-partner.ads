with Rose.Capabilities;
with Rose.Objects;
limited with Rose.Interfaces.Partner.Client;

package Rose.Interfaces.Partner is

   Partner_Interface : constant Rose.Objects.Endpoint_Id :=
     16#FCAE_B066_4F74_C332#;

   Pair_Endpoint     : constant Rose.Objects.Endpoint_Id :=
     16#2FF_78C7_AD3D_0DC4#;

   Next_Endpoint     : constant Rose.Objects.Endpoint_Id :=
     16#BA83_8467_8071_7B02#;

   Pair_Index        : constant := 0;

   Next_Index        : constant := 1;

   Subprogram_Count  : constant := 2;

   type Partner_Object is limited interface;

   function Partner_Cap
     (Item : in out Partner_Object)
      return Rose.Capabilities.Capability is abstract;

   procedure Pair
     (Item  : in out Partner_Object;
      Other : in out Rose.Interfaces.Partner.Client.Partner_Client;
      Peer  : in out Rose.Interfaces.Partner.Partner_Object'Class) is abstract;

   function Next
     (Item : in out Partner_Object)
      return Rose.Interfaces.Partner.Partner_Object'Class is abstract;

end Rose.Interfaces.Partner;
