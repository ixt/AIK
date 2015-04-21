#!/bin/bash
# Run d2j-dex2jar.sh over every .dex in $1.
# Giles R. Greenway 04/2015
for f in $1/*.dex
do
        out=$(echo $f | grep -P -o ".*(?=dex)")"jar"
        d2j-dex2jar.sh $f -o $out
done
