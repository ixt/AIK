DEVIP="$(/tools/droidscripts/getip.sh)"
if [ -n $DEVIP ]; then
  drozer console connect --server $DEVIP
else
  DEVIP="$(zenity --entry --entry-text='0.0.0.0' --title='Drozer' --text='Enter the IP address of your device.')"
  drozer console connect --server $DEVIP
fi

