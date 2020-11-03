##############################################################
#
# 11/01/2013  TW  Process 'execute sp_help' (schema information) output
#
# Usage:
#
# gawk -f proc3.awk table.txt > proc3.txt
#
# Notes:
#
#############################################################


BEGIN {
   first = "";
}

NR == 1 { first = "SELECT " }
NR != 1 { first = "," }

{ $1 = $1 }
{
   if ($2 == "varchar" || $2 == "char" )
   {
      print first"woh.value('"$1"[1]','varchar("$4")') AS '"$1"'";
   }
   else if ( $2 == "int" || $2 == "smallint" || $2 == "integer" )
   {
      print first"woh.value('"$1"[1]','integer') AS '"$1"'";
   }
   else if ( $2 == "decimal")
   {
      print first"woh.value('"$1"[1]','decimal("$5","$6")') AS '"$1"'";
   }
   else if ( $2 == "datetime")
   {
      print first"woh.value('"$1"[1]','datetime') AS '"$1"'";
   }
   else
   {
      print "*** NOT PROCESSED ***"$0;
   }
}

END {
   print "INTO #tempXML";
   print "FROM @xmlwoh.nodes('/woh') AS xdoc(woh);";
}