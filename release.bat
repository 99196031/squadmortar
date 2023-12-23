@echo off
setlocal

if exist release rmdir /s /q release

:: Create the 'release' folder
mkdir release

:: Copy squadmortar.exe to the 'release' folder
copy squadmortar.exe release

:: Copy the '/scripts' folder to the 'release' folder
xcopy /s /e /i scripts release\scripts

:: Delete all files in 'release\scripts' except for specified ones
for %%f in (release\scripts\*) do (
    if /I "%%~nxf" neq "squadMortarServerSilent.exe" (
        if /I "%%~nxf" neq "imageLayeringSilent.exe" (
            if /I "%%~nxf" neq "syncMap.exe" (
                del "%%f"
            )
        )
    )
)

if exist release\scripts\node_modules rmdir /s /q release\scripts\node_modules

mkdir release\autoit_libraries
copy autoit_libraries\mp.x64.dll release\autoit_libraries
copy autoit_libraries\mp.dll release\autoit_libraries

:: Create the 'frontend' folder inside 'release'
mkdir release\frontend\public

:: Copy 'frontend/public' to 'release\frontend'
xcopy /s /e frontend\public release\frontend\public

if exist release\frontend\public\merged rmdir /s /q release\frontend\public\merged

powershell Compress-Archive -Path "release\*" -DestinationPath "release\squadmortar.zip"

echo Task completed successfully.