::
:: Description
:: Windows batch file to run awk scripts
::   to process 'execute sp_help' (schema information) output
::
:: Notes
:: Requires GNU AWK (GAWK)
:: Install this in folder C:\Program Files (x86)\GnuWin32
:: (download the binaries ZIP file from http://gnuwin32.sourceforge.net/packages/gawk.htm)
:: Add C:\Program Files (x86)\GnuWin32\bin to the PATH environment variable
::
:: History
:: 11/01/2013  TW  New
:: 15/01/2013  TW  Added proc4.awk
::

gawk -f proc1.awk table.txt > proc1.txt
gawk -f proc2.awk table.txt > proc2.txt
gawk -f proc3.awk table.txt > proc3.txt
gawk -f proc4.awk table.txt > proc4.txt