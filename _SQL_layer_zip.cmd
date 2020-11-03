::
:: Description
:: Windows batch file to create a 7-Zip archive of the SQL_layer folder
::
:: Notes
:: Requires 7-Zip, in particular the 7z.exe command line executable
:: Make sure that the PATH environment variable includes the folder containing the 7z.exe command line executable
::
:: Alternative batch code short year %yy:~2,2%
::
:: History
:: 11/01/2013  TW  New
::

@ECHO OFF

:: Save to _SQL_layer.7z file

REM del _SQL_layer.7z
REM "C:\Program Files\7-Zip\7z.exe" a -t7z -x!.svn _SQL_layer.7z *.*

:: Save to datestamped filename (1)

REM Alternative character substitutions in contents of SAVEFILE variable

REM set SAVEFILE=%DATE:/=-%@%TIME:.:=-%

REM set SAVEFILE=%DATE%@%TIME%
REM set SAVEFILE=%SAVEFILE:/=-%
REM set SAVEFILE=%SAVEFILE::=-%
REM set SAVEFILE=%SAVEFILE:.=-%

REM set SAVEFILE=archive\%SAVEFILE: =%_SQL_layer.7z
REM echo %SAVEFILE%
REM "C:\Program Files\7-Zip\7z.exe" a -r -t7z -x!.svn %SAVEFILE% *.*

:: Save to datestamped filename (2)

call "batch\_SetDateTimeComponents.cmd" > nul
set SAVEFILE=archive\%yy%%mm%%dd%%hh%%min%%sec%%hsec%_SQL_layer.7z
"C:\Program Files\7-Zip\7z.exe" a -r -t7z -x@_SQL_layer_zip_exclude.txt %SAVEFILE% *.*

pause