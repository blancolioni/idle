package Idle.Host_Backings is

   --  The host implementations of interfaces, for the host target
   --  (idle#133, Rose #1101): the type that implements an interface's
   --  object type in a command built for the host's own Ada run-time.
   --  They are read from a file of lines
   --
   --     Interface_Name  Package.Type
   --
   --  in which # starts a comment, such as Rose's
   --  interfaces/host-backings.txt. The host main declares an object of
   --  the type for each interface argument and role member of a command,
   --  and opens it with Package.Open (Object, Text), where Text is what
   --  the user gave for the argument, or "" for a role member or an
   --  argument that wasn't given.

   procedure Load (File_Name : String);
   --  Read the backings in File_Name, as well as any already read. A
   --  line that can't be read, or that names an interface a second time,
   --  is reported through Idle.Diagnostics, and so is a file that can't
   --  be opened.

   function Is_Loaded return Boolean;
   --  True if Load has been called.

   function Find (Interface_Name : String) return String;
   --  The type that implements Interface_Name, as Package.Type, or "" if
   --  there is none. Case doesn't matter.

   function Unit_Of (Backing : String) return String;
   --  The package of Backing, a name that Find returned: all of it
   --  before the last dot.

end Idle.Host_Backings;
