#!/bin/bash
# Moderately user-friendly wrapper around apktool, smali, d2j-dex2jar.sh...
# Giles R. Greenway 01/2017
case $1 in
         "apktool")
               line="/tools/apktool d "; title="Choose an .apk file:" ; dir="" ;;
         "smali")
                line="/tools/droidscripts/autosmali.sh "; title="Choose a directory of .smali files:" ; dir="--directory" ;;
        "dex2jar")
                line="/tools/droidscripts/do_d2j.sh "; title="Choose an .apk file:" ; dir="" ;;
        "scan")
                line="/tools/droidscripts/scan_source.sh "; title="Choose a directory of .java source files:" ; dir="--directory" ;;               
esac

f=$(zenity --file-selection "$dir" --filename="$HOME/" --title="$title")
case $? in
         1)
                echo "No file selected."; exit 0;;
        -1)
                echo "An unexpected error has occurred."; exit 0;;
esac
$line "$f"
