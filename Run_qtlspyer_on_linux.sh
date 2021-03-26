#!/bin/sh

# Author : Blaz Vrhovsek
# Script follows here:

if command [ -x "$(command -v docker)" ]; then
  echo "Docker detected"
else
  echo "First you need to install Docker"
  exit 0
fi

docker pull hudogriz/qtl_spyer:latest

echo "Stop existing container"
docker stop qtl_spyer || true 

echo "Creating root folder"
docker run -d --rm --name qtl_lamb hudogriz/qtl_spyer:latest
docker cp qtl_lamb:/QTLspyer/ .
docker kill qtl_lamb

echo "Starting QTLspyer"
docker run -d --rm --init -p 3838:3838 --name qtl_spyer -v $(pwd)/QTLspyer/:/QTLspyer hudogriz/qtl_spyer:latest

if command [ -x "$(command -v google-chrome)" ]; then
  echo "Opening local host in Google Chrome"
  google-chrome http://localhost:3838
  exit 0
fi

if command [ -x "$(command -v firefox)" ]; then
  echo "Opening local host in Firefox"
  firefox http://localhost:3838
  exit 0
fi

echo "Can not locate a browser. Please direct your browser of choice manually to localhost:3838."
exit 0
