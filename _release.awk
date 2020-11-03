##############################################################
#
# 24/12/2012  TW  Create release SQL script
# 15/03/2013  TW  Read filelist from an external file
#
# Usage:
#
# gawk -f _release.awk _build.txt
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
}

   scriptfilename = $1;

{  while(( getline line < scriptfilename ) > 0 ) {
      print line > outputfile
   }
   close(scriptfilename)
}

{
   print "" > outputfile;
}

END {}