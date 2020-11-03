##############################################################
#
# 22/02/2013  TW  Create release SQL script ordered using a file list in a text file
#
# Usage:
#
# gawk -f _build.awk -v outputfile="\\hades\share\Build\SQLlayer.sql" _build.txt
#
# Notes:
#
##############################################################


BEGIN {
   outputfile1 = ("release\\_SQLlayer.sql");
#  outputfile2 = ("\\\\hades\\share\\Build\\SQLlayer.sql");
   outputfile2 = outputfile;
   now = "-- Generated " strftime("%d/%m/%y %T");
   print now > outputfile1;
   print now > outputfile2;
}

   scriptfilename = $1;

{  while(( getline line < scriptfilename ) > 0 ) {
      print line > outputfile1
      print line > outputfile2
   }
   close(scriptfilename)
}

{
   print "" > outputfile1;
   print "" > outputfile2;
}

END {}