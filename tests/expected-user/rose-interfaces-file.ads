with Rose.Capabilities;
with Rose.Objects;
with System.Storage_Elements;
limited with Rose.Interfaces.File_Reader;
limited with Rose.Interfaces.Seekable_File_Reader;

package Rose.Interfaces.File is

   File_Interface                : constant Rose.Objects.Endpoint_Id :=
     16#7D9D_DE97_9C08_C7C9#;

   Size_Endpoint                 : constant Rose.Objects.Endpoint_Id :=
     16#F6D0_973E_DEDA_8E48#;

   Open_Reader_Endpoint          : constant Rose.Objects.Endpoint_Id :=
     16#CDF7_65AA_4E7F_CF7F#;

   Open_Seekable_Reader_Endpoint : constant Rose.Objects.Endpoint_Id :=
     16#E29C_C755_27E1_0E80#;

   Size_Index                    : constant := 0;

   Open_Reader_Index             : constant := 1;

   Open_Seekable_Reader_Index    : constant := 2;

   Subprogram_Count              : constant := 3;

   type File_Object is limited interface;

   function File_Cap
     (Item : in out File_Object)
      return Rose.Capabilities.Capability is abstract;

   function Size
     (Item : in out File_Object)
      return System.Storage_Elements.Storage_Count is abstract;

   function Open_Reader
     (Item : in out File_Object)
      return Rose.Interfaces.File_Reader.File_Reader_Object'Class is abstract;

   function Open_Seekable_Reader
     (Item : in out File_Object)
      return
        Rose.Interfaces.Seekable_File_Reader.Seekable_File_Reader_Object'Class
   is abstract;

end Rose.Interfaces.File;
