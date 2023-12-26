@echo off
setlocal

del squadMortarServer.exe
del squadMortarServerSilent.exe
call npm run build
cd .. 

cd frontend
call npm run buildOnce 
cd ..
if exist release rmdir /s /q release

:: Create the 'release' folder
mkdir release

git clone --no-checkout  -b release https://github.com/Devil4ngle/squadmortar.git release

:: Copy squadmortar.exe to the 'release' folder
copy squadmortar.exe release

:: Create the 'release\scripts' folder if it doesn't exist
mkdir release\scripts

:: Copy only the specified files to the 'release\scripts' folder
copy /y scripts\squadMortarServerSilent.exe release\scripts
copy /y scripts\imageLayeringSilent.exe release\scripts
copy /y scripts\syncMap.exe release\scripts
xcopy /I /s /y scripts\git release\scripts\git
copy /y scripts\update.bat release\scripts

if exist release\scripts\node_modules rmdir /s /q release\scripts\node_modules

mkdir release\autoit_libraries
copy autoit_libraries\mp.x64.dll release\autoit_libraries
copy autoit_libraries\mp.dll release\autoit_libraries

:: Create the 'frontend' folder inside 'release'
mkdir release\frontend\public

:: Copy 'frontend/public' to 'release\frontend'
xcopy /s /e frontend\public release\frontend\public

if exist release\frontend\public\merged rmdir /s /q release\frontend\public\merged

:: powershell Compress-Archive -Path "release\*" -DestinationPath "release\squadmortar.zip"

:: Initialize a new Git repository in the 'release' folder
cd release
:: Add all your changes

echo runtime/ > .gitignore
echo frontend/public/merged/ >> .gitignore

git add .

git commit -m "Update Release"

git push origin release

echo Task completed successfully.

pause