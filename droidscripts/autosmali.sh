#!/bin/bash
# Convert each .smali file in $1 to .dex, renaming the output.
# Giles R. Greenway 04/2015
#out=$(echo $1 | grep -P -o ".*(?=smali)")"dex"
#smali $1 --output $out
for f in $1/*.smali
do
        out=$(echo $f | grep -P -o ".*(?=smali)")"dex"
        smali $f -o $out
done
