with Rose.Capabilities;
with Rose.Objects;
with System.Storage_Elements;

package Rose.Interfaces.Stream_Writer is

   Stream_Writer_Interface : constant Rose.Objects.Endpoint_Id :=
     16#346F_D760_8A40_95B7#;

   Write_Endpoint          : constant Rose.Objects.Endpoint_Id :=
     16#C5CD_0953_4A8B_BC37#;

   Write_Index             : constant := 0;

   Subprogram_Count        : constant := 1;

   type Stream_Writer_Object is limited interface;

   function Stream_Writer_Cap
     (Item : in out Stream_Writer_Object)
      return Rose.Capabilities.Capability is abstract;

   procedure Write
     (Item   : in out Stream_Writer_Object;
      Buffer : System.Storage_Elements.Storage_Array) is abstract;

end Rose.Interfaces.Stream_Writer;
