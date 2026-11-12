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
   --  The user target also writes Pkg.Name_Client (Generate_Client).
   --
   --  Item must have been checked by Idle.Commands.Check.

   procedure Generate_Client
     (Item             : Idle.Syntax.Interface_Declaration;
      Output_Directory : String);
   --  Write Pkg.Name_Client, for the user target, to Output_Directory: the
   --  launch call of the command Item, as the program that launched it
   --  makes it (idle#103). Its procedure Call takes the command endpoint,
   --  which Launch.Launch_Command returned, then the command's role
   --  members and arguments, in the order of the main's signature, and,
   --  for a replaceable server, Previous and Saved, which default to the
   --  null cap. Role members and interface arguments are caps, and an out
   --  interface is an out cap. It is made of the calls of
   --  Rose.Command_Line.Launch_Client, and raises
   --  Rose.Interfaces.Objects.Invocation_Error, with the command's
   --  message, if the call or the command fails.
   --
   --  Item must have been checked by Idle.Commands.Check.

   procedure Generate_Package
     (Item             : Idle.Syntax.Interface_Declaration;
      Output_Directory : String);
   --  Write the Ada package for the package Item, which holds its
   --  details, inherited ones included, as constants.

end Idle.Targets.Kernel.Commands;
