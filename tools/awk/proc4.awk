##############################################################
#
# 15/01/2013  TW  Process 'execute sp_help' (schema information) output
#
# Usage:
#
# gawk -f proc4.awk table.txt > proc4.txt
#
# Notes:
#
#############################################################


BEGIN {
   first = "";
   print "UPDATE #tempXML ";
}

NR == 1 { first = "SET " }
NR != 1 { first = "," }

{ $1 = $1 }
{ print "\t"first$1" = @"$1 }

END {
   print "\tFROM #tempXML;"
}