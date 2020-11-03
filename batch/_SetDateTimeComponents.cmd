::
:: Description
:: Windows batch file to parse date and time information for use by calling batch file
::
:: Notes
:: Copied from http://stackoverflow.com/questions/1064557/creating-a-file-name-as-a-timestamp-in-a-batch-job
::
:: History
:: 11/01/2013  TW  New
::

:: ------------------ Date and Time Modifier ------------------------

@echo off

:: THIS CODE WILL DISPLAY A 2-DIGIT TIMESTAMP FOR USE IN APPENDING FILENAMES

:: CREATE VARIABLE %TIMESTAMP%

for /f "tokens=1-7 delims=.:/-, " %%i in ('echo exit^|cmd /q /k"prompt $d $t"') do (
   for /f "tokens=2-4 delims=/-,() skip=1" %%a in ('echo.^|date') do (
set dow=%%i
set mm=%%j
set dd=%%i
set yy=%%k
set hh=%%l
set min=%%m
set sec=%%n
set hsec=%%o
)
)

:: ensure that hour is always 2 digits

if %hh%==0 set hh=00
if %hh%==1 set hh=01
if %hh%==2 set hh=02
if %hh%==3 set hh=03
if %hh%==4 set hh=04
if %hh%==5 set hh=05
if %hh%==6 set hh=06
if %hh%==7 set hh=07
if %hh%==8 set hh=08
if %hh%==9 set hh=09


:: assign timeStamp:
:: Add the date and time parameters as necessary - " yy-mm-dd-dow-min-sec-hsec "

:: set timeStamp=%yy%%mm%%dd%%hh%%min%%sec%%hsec%

:: echo %timeStamp%


:: --------- TIME STAMP DIAGNOSTICS -------------------------

:: Un-comment these lines to test output

:: echo dayOfWeek = %dow%
:: echo year = %yy%
:: echo month = %mm%
:: echo day = %dd%
:: echo hour = %hh%
:: echo minute = %min%
:: echo second = %sec%
:: echo hundredthsSecond = %hsec%
:: echo.
:: echo Hello! 
:: echo Today is %dow%, %mm%/%dd%. 
:: echo.
:: echo Your timestamp will look like this: %timeStamp%
:: echo. 
:: echo.
:: echo.
:: pause

:: --------- END TIME STAMP DIAGNOSTICS ----------------------