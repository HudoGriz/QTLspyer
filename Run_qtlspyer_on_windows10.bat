@echo off

WHERE docker
if %ERRORLEVEL% NEQ 0 (echo "First you need to install Docker") else (echo "Docker detected")

"C:\Program Files\Docker\Docker\DockerCli.exe" -SwitchDaemon -SwitchLinuxEngine

echo "Stop existing container"
docker stop qtl_spyer

docker pull hudogriz/qtl_spyer:latest

echo "Creating root folder"
docker run -d --rm --name qtl_lamb hudogriz/qtl_spyer:latest
docker cp qtl_lamb:/QTLspyer/ .
docker kill qtl_lamb

echo "Starting QTLspyer"
docker run -d --rm --init -p 3838:3838 --name qtl_spyer -v %~dp0/QTLspyer/:/QTLspyer hudogriz/qtl_spyer:latest

start "" http://localhost:3838

exit
