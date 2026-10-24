with Rose.Objects;

package Rose.Interfaces.Heap is

   Heap_Interface             : constant Rose.Objects.Endpoint_Id :=
     16#6635_173D_F87C#;

   Current_Bound_Endpoint     : constant Rose.Objects.Endpoint_Id :=
     16#6650_2508_7B88#;

   Request_New_Bound_Endpoint : constant Rose.Objects.Endpoint_Id :=
     16#22D2_9EEE_A6A1#;

   Current_Bound_Index        : constant := 0;

   Request_New_Bound_Index    : constant := 1;

   Subprogram_Count           : constant := 2;

end Rose.Interfaces.Heap;
