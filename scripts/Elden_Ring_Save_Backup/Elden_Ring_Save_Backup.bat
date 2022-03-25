::==============================================================================
:: Back up your Elden Ring Save File to a .7z file with today's date
:: Takes this folder
::   C:\Users\USER\AppData\Roaming\EldenRing\12345678901234567\
:: Create this backup
::   C:\Users\USER\AppData\Roaming\EldenRing\YYYY-MM-DD-HH-MM-SS - 12345678901234567.7z
::==============================================================================
:: echo off
if exist "C:\Program Files\7-Zip\7z.exe" (
    set zip="C:\Program Files\7-Zip\7z.exe"
) else (
    if exist "C:\Program Files (x86)\7-Zip\7z.exe" (
        set zip="C:\Program Files (x86)\7-Zip\7z.exe"
    ) else (
        msg "%username%" "7-Zip not found, please install 7-Zip from www.7-zip.org"
        exit /b
    )
)
set "MyDate="
for /f "skip=1" %%x in ('wmic os get localdatetime') do if not defined MyDate set MyDate=%%x
set today=%MyDate:~0,4%-%MyDate:~4,2%-%MyDate:~6,2%-%MyDate:~8,2%-%MyDate:~10,2%-%MyDate:~12,2%
for /d /r "%APPDATA%\EldenRing\" %%a in (*) do set ProfileID=%%a
for %%a in (%ProfileID:\= %) do set lastDir=%%a
%zip% a "%APPDATA%\EldenRing\%today% - %lastDir%.7z" "%APPDATA%\EldenRing\%lastDir%"
