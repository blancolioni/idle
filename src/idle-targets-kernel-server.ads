with Idle.Syntax;

private package Idle.Targets.Kernel.Server is

   procedure Generate
     (Item             : Idle.Syntax.Interface_Declaration;
      Output_Directory : String);
   --  Write the package Rose.Interfaces.<Name>.Server to Output_Directory.
   --  A server supplies a handler for each subprogram of the interface;
   --  the package creates the endpoints, and decodes each invocation and
   --  passes it to its handler.
   --
   --  Item must have been checked by Idle.Targets.Kernel.Generate.

end Idle.Targets.Kernel.Server;
