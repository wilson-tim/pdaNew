##############################################################
#
# 11/01/2013  TW  Process 'execute sp_help' (schema information) output
#
# Usage:
#
# gawk -f proc2.awk table.txt > proc2.txt
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
{ print first"@"$1" = "$1 }

END {
   print "FROM #tempXML;"
}