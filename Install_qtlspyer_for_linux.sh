#!/bin/sh

# Author : Blaz Vrhovsek
# Copyright 2021 MIT License
# Script follows here:

if command [ -x "$(command -v docker)" ]; then
  echo "Docker detected"
else
  echo "First you need to install Docker"
  exit 0
fi

echo "Creating root folder"
mkdir -p QTLspyer

docker pull hudogriz/qtl_spyer:latest

docker run -d --rm -p 3838:3838 --name qtl_spy -v $(pwd)/QTLspyer/:/QTLspyer hudogriz/qtl_spyer:latest

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

echo "Can not locate a browser. Please direct your browser of choise manualy to localhost:3838."
exit 0
