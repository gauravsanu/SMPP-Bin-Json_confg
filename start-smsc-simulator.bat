@echo off
cd /d "%~dp0"
if not exist simulator\smsc-simulator.jar (
 echo Simulator JAR is missing. Compile with Java 17+: javac -d simulator\build\classes src\main\java\com\example\smsc\SmscSimulator.java
 pause
 exit /b 1
)
java -jar simulator\smsc-simulator.jar 2775 test test
pause
