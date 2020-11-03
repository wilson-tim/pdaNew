grep "errortext varchar(100)" *.sql -l > filelist.tmp
for /f %%i in (filelist.tmp) do (
  sed "s/errortext\ varchar(100)/errortext\ varchar(500)/g" %%i > %%i.sed
  copy /y %%i.sed %%i
)
del *.sed
del filelist.tmp

pause