#!/bin/sh
./remove.sh
./packages.sh

dpkg-scanpackages -m . /dev/null >Packages
