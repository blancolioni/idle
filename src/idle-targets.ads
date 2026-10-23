package Idle.Targets is

   --  The code generators. Each child package generates the Ada packages
   --  for one target from the syntax tree.

   type Target is
     (Kernel_Target);
   --  Kernel_Target : "kernel", the subset of Ada available to Rose's
   --                  kernel-level code, with no tagged types or
   --                  interfaces (Idle.Targets.Kernel).

   Default_Target : constant Target := Kernel_Target;

   function Name (Item : Target) return String;
   --  The target's name on the command line: "kernel".

   function Find (Text : String; Item : out Target) return Boolean;
   --  Set Item to the target named Text, ignoring case. False if there
   --  is none.

   function Names return String;
   --  The names of every target, separated by ", ", for messages.

end Idle.Targets;
