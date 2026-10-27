with Idle.Syntax;

package Idle.Targets.Kernel is

   procedure Generate
     (Item             : Idle.Syntax.Interface_Declaration;
      Output_Directory : String;
      Target           : Idle.Targets.Target := Kernel_Target);
   --  Write the units for Item, for Target, to Output_Directory. For a
   --  command or an IDL package, see Idle.Targets.Kernel.Commands; a role
   --  has none. For an interface, they are the packages that implement
   --  it:
   --
   --    Rose.Interfaces.<Name>         the endpoint ids of the interface
   --                                   and of each of its subprograms
   --    Rose.Interfaces.<Name>.Client  calls through the interface
   --    Rose.Interfaces.<Name>.Server  handles calls through it
   --
   --  The packages use the encoding of the original IDL compiler (see
   --  Idle.Targets.Kernel.Types), and interoperate with code it generated
   --  and with the kernel. Not yet supported: out and in out capability
   --  arrays; results that are capability arrays or storage arrays; and
   --  more than one string or array in a subprogram. These, and unknown
   --  types, are reported as errors through Idle.Diagnostics, and nothing
   --  is written.
   --
   --  For the user target, the packages have the same names and the same
   --  encoding, from the same code, but:
   --
   --    Rose.Interfaces.<Name>  also declares <Name>_Object, a limited
   --                            interface with an abstract primitive for
   --                            each subprogram it declares, and
   --                            <Name>_Cap, which gives an object's cap
   --                            for the interface; its parents are those
   --                            of its IDL parents
   --    ...Client               <Name>_Client implements <Name>_Object,
   --                            and gets its caps on its first call; a
   --                            call that fails raises
   --                            Rose.Interfaces.Objects.Invocation_Error
   --    ...Server               <Name>_Interface, an interface for an
   --                            object that the program serves; Attach,
   --                            Publish and Interface_Cap; and Cap_Of,
   --                            for a served object's cap functions
   --
   --  An interface argument is an in out object of the interface, and an
   --  interface result is one too, built in place as a client. An out
   --  interface is a client that the subprogram opens. A string result is
   --  a String, and an out or in out string a Rose.Strings.Text. The
   --  interface package names other interfaces through limited with
   --  clauses.
   --
   --  The user target's units for a command are those of the kernel
   --  target, but that the command takes each interface argument, and
   --  each role member that is an interface, as an in out object of the
   --  interface, and an out or in out string as a Rose.Command_Line.Text.

end Idle.Targets.Kernel;
