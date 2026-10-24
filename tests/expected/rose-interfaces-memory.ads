with Rose.Objects;

package Rose.Interfaces.Memory is

   type Page_Access_Type is (Read, Write, Execute);

   Memory_Interface              : constant Rose.Objects.Endpoint_Id :=
     16#FEDF_783E_C50B_9397#;

   New_Process_Endpoint          : constant Rose.Objects.Endpoint_Id :=
     16#9C0F_B258_5D0D_57AC#;

   Register_Process_Endpoint     : constant Rose.Objects.Endpoint_Id :=
     16#EE60_F508_F9CE_2C17#;

   Page_Fault_Endpoint           : constant Rose.Objects.Endpoint_Id :=
     16#DFE0_E916_1CA7_CA5A#;

   Take_Physical_Memory_Endpoint : constant Rose.Objects.Endpoint_Id :=
     16#FB32_D564_D01F_6E0C#;

   Checkpoint_Endpoint           : constant Rose.Objects.Endpoint_Id :=
     16#77E6_970E_9F4B_AFD2#;

   New_Process_Index             : constant := 0;

   Register_Process_Index        : constant := 1;

   Page_Fault_Index              : constant := 2;

   Take_Physical_Memory_Index    : constant := 3;

   Checkpoint_Index              : constant := 4;

   Subprogram_Count              : constant := 5;

end Rose.Interfaces.Memory;
