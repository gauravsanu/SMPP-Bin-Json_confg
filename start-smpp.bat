@echo off
cd /d "%~dp0"
if not exist target\smpp-json-gateway.jar (
 echo Building SMPP JSON gateway...
 call mvnd -q clean package
 if errorlevel 1 (echo Build failed. Check Java 17 and Maven.& pause& exit /b 1)
)
java -jar target\smpp-json-gateway.jar
pause
