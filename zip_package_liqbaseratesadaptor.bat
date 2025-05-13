@echo off
REM Creating directory structure

mkdir fortifyscan\LiqBaseRatesAdaptor\src

xcopy /E /I .\LiqBaseRatesAdaptor\src\main .\fortifyscan\LiqBaseRatesAdaptor\src\main
xcopy /E /I .\LiqBaseRatesAdaptor\src\test .\fortifyscan\LiqBaseRatesAdaptor\src\test
xcopy /E /I .\LiqBaseRatesAdaptor\pom.xml .\fortifyscan\LiqBaseRatesAdaptor\src
pushd fortifyscan\LiqBaseRatesAdaptor
REM Delete any existing LiqBaseRatesAdaptor package
if exist LiqBaseRatesAdaptor.zip del /F /Q LiqBaseRatesAdaptor.zip
