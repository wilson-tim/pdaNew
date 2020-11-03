::
:: Description
:: Windows batch file to run _release.awk script
::
:: Notes
:: Requires GNU AWK (GAWK)
:: Install this in folder C:\Program Files (x86)\GnuWin32
:: (download the binaries ZIP file from http://gnuwin32.sourceforge.net/packages/gawk.htm)
:: Add C:\Program Files (x86)\GnuWin32\bin to the PATH environment variable
::
:: History
:: 24/12/2012  TW  New
:: 15/03/2013  TW  Read filelist from an external file
::

@ECHO OFF

gawk -f _release.awk _build.txt