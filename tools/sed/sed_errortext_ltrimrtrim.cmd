grep "RTRIM(LTRIM(" *.sql -l > filelist.tmp
for /f %%i in (filelist.tmp) do (
  sed "s/RTRIM(LTRIM(/LTRIM(RTRIM(/g" %%i > %%i.sed
  copy /y %%i.sed %%i
)
del *.sed
del filelist.tmp

pause