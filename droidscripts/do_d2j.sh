#!/bin/bash
# Run d2j-dex2jar.sh on the .apk pointed to by $1.
# Giles R. Greenway 04/2015
JAR=$HOME/jarfiles/"$(echo $1 | grep -P -o [^/]*\(?=\\.apk\))".jar
d2j-dex2jar.sh -f -o $JAR $1
