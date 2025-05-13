@echo off
REM Creating directory structure

mkdir fortifyscan\LoanIqDataIngestion\src
mkdir fortifyscan\LoanIqDataIngestion\lib

xcopy /E /I .\src\main .\fortifyscan\LoanIqDataIngestion\src\main
xcopy /E /I .\target\dependency\*.jar .\fortifyscan\LoanIqDataIngestion\lib

pushd fortifyscan\LoanIqDataIngestion
REM Delete any existing rmw-common-fortify package
if exist LoanIqDataIngestion.zip del /F /Q LoanIqDataIngestion.zip


