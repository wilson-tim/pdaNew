##############################################################
#
# 24/12/2012  TW  Create release SQL script
#
# Usage:
#
# gawk -f _release.awk schema\cs_*.sql cs_*.sql
#
# Notes:
#
# strftime("%Y-%m-%d %H:%M:%S")
#
#############################################################


BEGIN {
   outputfile = ("release\\"strftime("%Y%m%d%H%M%S")"_release.sql");
   now = "-- Generated " strftime("%d/%m/%y %T");
   print now > outputfile;
   name = "";
}

{
   if ( name != FILENAME )
      {
         name = FILENAME;
         print "" > outputfile;
         print "" > outputfile;
      }
}

{ print $0 > outputfile; }

END {}