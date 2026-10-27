with Idle.Syntax;

private package Idle.Targets.Kernel.Commands is

   procedure Generate_Command
     (Item             : Idle.Syntax.Interface_Declaration;
      Output_Directory : String;
      Target           : Idle.Targets.Target);
   --  Write the units for the command Item, Pkg.Name, to Output_Directory:
   --
   --    Pkg.Name           the procedure spec the author implements
   --    Pkg.Name_Main      the main, which receives the shell's launch
   --                       invocation, gives the standard streams to the
   --                       run-time system, decodes the arguments, calls
   --                       Pkg.Name, and completes the invocation
   --    Pkg.Name_Metadata  the command's metadata, in the .rose_command
   --                       section of the executable
   --
   --  For the user target, the command takes each interface argument,
   --  and each role member that is not a standard stream or system cap,
   --  as an in out object of the interface; the main passes it a client.
   --
   --  Item must have been checked by Idle.Commands.Check.

   procedure Generate_Package
     (Item             : Idle.Syntax.Interface_Declaration;
      Output_Directory : String);
   --  Write the Ada package for the package Item, which holds its
   --  details, inherited ones included, as constants.

end Idle.Targets.Kernel.Commands;
