with Idle.Hierarchy;

package Idle.Check is

   procedure Check_All (Items : Idle.Hierarchy.Interface_Vectors.Vector);
   --  Check Items together, as the interfaces that a build compiles, and
   --  report through Idle.Diagnostics what checking one file at a time
   --  cannot see:
   --
   --    - an interface whose file is not named after it;
   --    - a parent, or an interface type, that cannot be found;
   --    - a subprogram name that an interface and its ancestors declare
   --      more than once;
   --    - two different interfaces or subprograms with the same endpoint
   --      id, which only a pinned id can cause in practice;
   --    - as warnings, a pinned id that is the same as the hash it
   --      replaces, and the other .idl files in the same directories,
   --      which the build does not compile.

end Idle.Check;
