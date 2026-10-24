with Rose.Objects;

package Rose.Interfaces.Heap is

   Heap_Interface             : constant Rose.Objects.Endpoint_Id :=
     16#C07B_A29D_620B_0DDF#;

   Current_Bound_Endpoint     : constant Rose.Objects.Endpoint_Id :=
     16#2E09_4D28_8787_2F07#;

   Request_New_Bound_Endpoint : constant Rose.Objects.Endpoint_Id :=
     16#EC61_210F_3FD7_A110#;

   Current_Bound_Index        : constant := 0;

   Request_New_Bound_Index    : constant := 1;

   Subprogram_Count           : constant := 2;

end Rose.Interfaces.Heap;
