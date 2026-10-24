package Idle.Literals is

   function Value
     (Text   : String;
      Result : out Long_Long_Long_Integer;
      Last   : Long_Long_Long_Integer)
      return Boolean;
   --  The value of the integer literal Text, written as in Ada: decimal,
   --  or based (16#0C71_18A7#), with underscores between digits. False if
   --  Text is not such a literal, or its value is greater than Last.

end Idle.Literals;
