with Ada.Streams;
with Rose.Capabilities;
with Rose.Objects;

package Rose.Interfaces.Reader is

   Reader_Interface : constant Rose.Objects.Endpoint_Id :=
     16#C52D_213D_B844_4345#;

   Read_Endpoint    : constant Rose.Objects.Endpoint_Id :=
     16#CA9_5C46_2427_9D3A#;

   Read_Index       : constant := 0;

   Subprogram_Count : constant := 1;

   type Reader_Object is limited interface;

   function Reader_Cap
     (Item : in out Reader_Object)
      return Rose.Capabilities.Capability is abstract;

   procedure Read
     (Item   : in out Reader_Object;
      Buffer : out Ada.Streams.Stream_Element_Array;
      Last   : out Ada.Streams.Stream_Element_Offset) is abstract;

end Rose.Interfaces.Reader;
