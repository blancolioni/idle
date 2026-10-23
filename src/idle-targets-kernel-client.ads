with Idle.Syntax;

private package Idle.Targets.Kernel.Client is

   procedure Generate
     (Item             : Idle.Syntax.Interface_Declaration;
      Output_Directory : String);
   --  Write the package Rose.Interfaces.<Name>.Client to Output_Directory.
   --  Its private type <Name>_Client holds a cap for each subprogram of
   --  the interface, and each subprogram is a call through its cap.
   --
   --  Item must have been checked by Idle.Targets.Kernel.Generate.

end Idle.Targets.Kernel.Client;
