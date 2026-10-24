with Idle.Syntax;

package Idle.Targets.Kernel is

   procedure Generate
     (Item             : Idle.Syntax.Interface_Declaration;
      Output_Directory : String);
   --  Write the units for Item to Output_Directory. For a command or an
   --  IDL package, see Idle.Targets.Kernel.Commands; a role has none. For
   --  an interface, they are the packages that implement it:
   --
   --    Rose.Interfaces.<Name>         the endpoint ids of the interface
   --                                   and of each of its subprograms
   --    Rose.Interfaces.<Name>.Client  calls through the interface
   --    Rose.Interfaces.<Name>.Server  handles calls through it
   --
   --  The packages use the encoding of the original IDL compiler (see
   --  Idle.Targets.Kernel.Types), and interoperate with code it generated
   --  and with the kernel. Not yet supported: out and in out parameters
   --  that are caps, interfaces, capability arrays or strings; results
   --  that are capability arrays or storage arrays; and more than one
   --  string or array in a subprogram. These, and unknown types, are
   --  reported as errors through Idle.Diagnostics, and nothing is written.

end Idle.Targets.Kernel;
