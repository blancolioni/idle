with Idle.Endpoints;
with Idle.Hierarchy;

package Idle.Check is

   procedure Check_All
     (Items     : Idle.Hierarchy.Interface_Vectors.Vector;
      Endpoints : Idle.Endpoints.Endpoint_Table);
   --  Check Items together, as the interfaces that a build compiles, and
   --  report through Idle.Diagnostics what checking one file at a time
   --  cannot see:
   --
   --    - an interface whose file is not named after it;
   --    - a parent, or an interface type, that cannot be found;
   --    - a subprogram name that an interface and its ancestors declare
   --      more than once;
   --    - an interface or subprogram with no endpoint id, and two
   --      different ones with the same id;
   --    - as warnings, the other .idl files in the same directories,
   --      which the build does not compile.

end Idle.Check;
