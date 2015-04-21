#!/bin/bash
# Rename smali output.
# Giles R. Greenway 04/2015
in=$(pwd)"/$1"
out=$(echo $in | grep -P -o ".*(?=smali)")"dex"
smali $in -output $out
