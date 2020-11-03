##############################################################
#
# 11/01/2013  TW  Process 'execute sp_help' (schema information) output
#
# Usage:
#
# gawk -f proc1.awk table.txt > proc1.txt
#
# Notes:
#
#############################################################


BEGIN {
   first = "";
}

NR == 1 { first = "DECLARE " }
NR != 1 { first = "," }


{ $1 = $1 }
{
   if ($2 == "varchar" || $2 == "char" )
   {
      print first"@"$1" varchar("$4")";
   }
   else if ( $2 == "int" || $2 == "smallint" || $2 == "integer" )
   {
      print first"@"$1" integer";
   }
   else if ( $2 == "decimal")
   {
      print first"@"$1" decimal("$5","$6")";
   }
   else if ( $2 == "datetime")
   {
      print first"@"$1" datetime";
   }
   else
   {
      print "*** NOT PROCESSED ***"$0;
   }
}

END { }