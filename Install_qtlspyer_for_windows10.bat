@echo off

WHERE docker
if %ERRORLEVEL% NEQ 0 (echo "First you need to install Docker") else (echo "Docker detected")

"C:\Program Files\Docker\Docker\DockerCli.exe" -SwitchDaemon -SwitchLinuxEngine

echo "Creating root folder"
if not exist "QTLspyer" mkdir QTLspyer

docker pull hudogriz/qtl_spyer:latest
docker run -d --rm -p 3838:3838 --name qtl_spy -v %~dp0\QTLspyer\:\QTLspyer hudogriz/qtl_spyer:latest

start "" http://localhost:3838

exit
