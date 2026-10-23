with Idle.Endpoints;
with Idle.Syntax;

package Idle.Targets.Kernel is

   procedure Generate
     (Item             : Idle.Syntax.Interface_Declaration;
      Endpoints        : Idle.Endpoints.Endpoint_Table;
      Output_Directory : String);
   --  Write the packages that implement the interface Item to
   --  Output_Directory:
   --
   --    Rose.Interfaces.<Name>         the endpoint ids of the interface
   --                                   and of each of its subprograms
   --    Rose.Interfaces.<Name>.Client  calls through the interface
   --    Rose.Interfaces.<Name>.Server  handles calls through it
   --
   --  Not yet supported: interfaces with parents, types or constants;
   --  parameters that are not in mode, or whose type is not Word or
   --  Capability; and results that are not Word, Capability or an
   --  interface. These are reported as errors through Idle.Diagnostics,
   --  and nothing is written.

end Idle.Targets.Kernel;
