#!/bin/bash

#create file

#read
head -c 1G /dev/urandom > 1g.bin
echo "read"
pv 1g.bin > /dev/null
rm -rf 1g.bin

#copy
head -c 1G /dev/urandom > 1g.bin
echo "copy"
pv 1g.bin > 1g.bin.1
rm -rf 1g.bin 1g.bin.1

#read/write
head -c 1G /dev/urandom > 1g.bin
echo "r/w"
pv < 1g.bin > 1g.bin.1
rm -rf 1g.bin 1g.bin.1
