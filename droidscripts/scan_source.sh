#!/bin/bash
# Grep Android source for moderately interesting stuff...
# Giles R. Greenway 01/2017
cd $1
cat /tools/droidscripts/badstuff | xargs -I NASTY grep -rl NASTY $1 | sort | uniq --count | sort -r | grep -o '/.*.java' | zenity --list --column="Potentially interesting .java files:" | xargs leafpad 
