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
:: To create the build file list in MSSQL run:
::
::    execute dbo.cs_utils_createBuildFileList 'C:\csl\trunk\SQL_layer\_build.txt'
::
:: History
:: 22/02/2013  TW  New
::

@ECHO OFF

gawk -f _build.awk -v outputfile="SQLlayer.sql" _build.txt