with Idle.Endpoints;
with Idle.Syntax;

package Idle.Targets.Kernel is

   procedure Generate_Interface_Package
     (Item             : Idle.Syntax.Interface_Declaration;
      Endpoints        : Idle.Endpoints.Endpoint_Table;
      Output_Directory : String);
   --  Write the package Rose.Interfaces.<Name>, which holds the endpoint
   --  ids of the interface and of each of its subprograms, to
   --  Output_Directory.
   --
   --  Not yet supported: interfaces with parents, types or constants.
   --  These are reported as errors through Idle.Diagnostics, and nothing
   --  is written.

end Idle.Targets.Kernel;
