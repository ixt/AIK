
# Reading Android Java Code

Usually, code written in the Java language is compiled from plain-text .java files into bytecode in .class files. These can be packaged together
with other resources into .jar files ready to be run by a Java Virtual Machine (JVM). For Android, the .class files are converted into .dex files
for running on its own virtual machine, once called Dalvik on Android Kit-Kat and earlier, now the ART or Android Runtime. This process is mostly
reverseable, with the correct tools we can recover something close to the original java code from an .apk file. The first stage is to use a tool
called dex2jar under the "Android Package Tools" menu. Choose an .apk file from the "apk_storage" folder, and a corresponding .jar file will be
created inside the "jarfiles" folder. You can explore the contents of this by opening it with [JD-GUI](http://jd.benow.ca/) also under "Android Package Tools".
In the case of "TheLine", we also see that some of the classes were provided by the firm "Tencent". Attempts have been made to obfuscate the source-code,
sometimes we are left with non-descript single-character names for classes and variables. If you're not used to reading Java, it can be hard to know
where to begin.

![JD GUI](https://raw.githubusercontent.com/kingsBSD/DroidDestructionKit/master/ddkdocs/img/jdgui.png)

A simple solution has been provided. First, use the "save all sources" option to save all the decompiled code in a .zip file. Next, extract this
with the Xarchiver utility under the "Accessories" menu. Give a new directory name to extract into to keep things tidy.

![Using Xarchiver](https://raw.githubusercontent.com/kingsBSD/DroidDestructionKit/master/ddkdocs/img/linextract.png)

We can search the source-code for some "usual suspect" objects provided by the Android API that tell us where an app might be doing something we're interested in. These are:

* [PhoneStateListener](https://developer.android.com/reference/android/telephony/PhoneStateListener.html)
* [TelephonyManager](https://developer.android.com/reference/android/telephony/TelephonyManager.html)
* [WifiManager](https://developer.android.com/reference/android/net/wifi/WifiManager.html)
* [ConnectivityManager](https://developer.android.com/reference/android/net/ConnectivityManager.html)
* [LocationListener](https://developer.android.com/reference/android/location/LocationListener.html)
* [LocationManager](https://developer.android.com/reference/android/location/LocationManager.html)
* [getLatitude](https://developer.android.com/reference/android/location/Location.html)
* [getLongitude](https://developer.android.com/reference/android/location/Location.html)
* [BluetoothAdapter](https://developer.android.com/reference/android/bluetooth/BluetoothAdapter.html)
* [BluetoothDevice](https://developer.android.com/reference/android/bluetooth/BluetoothDevice.html)
* [BluetoothServerSocket](https://developer.android.com/reference/android/bluetooth/BluetoothServerSocket.html)
* [SmsManager](https://developer.android.com/reference/android/telephony/SmsManager.html)
* [HttpURLConnection](https://developer.android.com/reference/java/net/HttpURLConnection.html)
* [ContactsContract](https://developer.android.com/reference/android/provider/ContactsContract.html)
* [AudioRecord](https://developer.android.com/reference/android/media/AudioRecord.html)

(If you feel that this list is missing something, feel free to edit the file [/tools/droidscripts/badstuff](https://github.com/kingsBSD/DroidDestructionKit/blob/master/droidscripts/badstuff), and consult some of the books
that haven't been written about [regular](https://twitter.com/thepracticaldev/status/774309983467016193?lang=en) [expressions](https://twitter.com/thepracticaldev/status/755879385622843396).
Maybe [this](http://www.regexpal.com/) is of more use.
Select [Scan .java source](https://github.com/kingsBSD/DroidDestructionKit/blob/master/droidscripts/scan_source.sh)
and choose the folder you extracted the .zip to. You will see a list of .java files, sorted in order of the most occurances of the "usual suspects".
What does "GetAdRequest.java" do?

![GetAdRequest](https://raw.githubusercontent.com/kingsBSD/DroidDestructionKit/master/ddkdocs/img/linescan.png)

```
  public void fillAdPreferences(Context paramContext, AdPreferences paramAdPreferences, AdPreferences.Placement paramPlacement, String paramString)
  {
    this.placement = paramPlacement;
    if ((MetaData.getInstance().getAdInformationConfig().e().a(paramContext)) && (paramAdPreferences.isSimpleToken())) {}
    for (this.simpleToken = paramString;; this.simpleToken = "")
    {
      this.longitude = paramAdPreferences.getLongitude();
      this.latitude = paramAdPreferences.getLatitude();
      this.age = paramAdPreferences.getAge(paramContext);
      this.gender = paramAdPreferences.getGender(paramContext);
      this.keywords = paramAdPreferences.getKeywords();
      this.adTag = paramAdPreferences.getAdTag();
      this.testMode = paramAdPreferences.isTestMode();
      this.categories = paramAdPreferences.getCategories();
      this.categoriesExclude = paramAdPreferences.getCategoriesExclude();
      setCountry(paramAdPreferences.country);
      setAdvertiser(paramAdPreferences.advertiserId);
      setTemplate(paramAdPreferences.template);
      setType(paramAdPreferences.type);
      return;
    }
  }
```

We haven't proved that this code gets called, or how the app tries to find this information, but it looks like ads are targetted based on age, gender
and location. To catch apps "in the act", we have to become Android developers.