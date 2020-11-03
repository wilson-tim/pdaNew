::
:: Description
:: Windows batch file to run xmldoc.awk script
::
:: Notes
:: Requires GNU AWK (GAWK)
:: Install this in folder C:\Program Files (x86)\GnuWin32
:: (download the binaries ZIP file from http://gnuwin32.sourceforge.net/packages/gawk.htm)
:: Add C:\Program Files (x86)\GnuWin32\bin to the PATH environment variable
::
:: History
:: 09/10/2013  TW  New
::

@ECHO OFF

gawk -f xmldoc.awk cs_comp_createRecordHway.sql > cs_comp_createRecordHway.xml

pause