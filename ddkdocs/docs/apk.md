# All About Android Packages

You should see a link inviting you to "play with the tools" at [http://localhost:8080](http://localhost:8080). Click it. You now have a web-based desktop to launch the tools from.
Find the "Android Package Tools" option in the menu in the bottom-left corner. Start the program called [Racoon](http://www.onyxbits.de/raccoon).

![VNC desktop](https://raw.githubusercontent.com/kingsBSD/DroidDestructionKit/master/ddkdocs/img/ddk_menu.png)

![Raccoon](https://raw.githubusercontent.com/kingsBSD/DroidDestructionKit/master/ddkdocs/img/raccoon.png)

Android apps are downloaded from the Google PlayStore in the form of .apk package files.[Racoon](http://www.onyxbits.de/raccoon) allows us to download them
to play with, without having a real Android device. Give it the credentials of your Google account. All that will happen is
that you will get emails saying that the fake Android devices have been linked to it. It's best to have a "burner"
account just for doing this. Our "favourite" (most infamous) app from the [Our Data, Ourselves](https://big-social-data.net/) project is a game called
"TheLineKeepIn". We can search for it and download it.

You will see that the PlayStore refers to the game by it's package name, "com.onetouchgame.TheLine". If you search for it
in your browser, you can find it on the [PlayStore site](https://play.google.com/store/apps/details?id=com.onetouchgame.TheLine&hl=en).
[Racoon](http://www.onyxbits.de/raccoon) also gives us other information, such as the permissions the app requests from the user. For now, just download it.

![Download TheLineKeepin](https://raw.githubusercontent.com/kingsBSD/DroidDestructionKit/master/ddkdocs/img/downloadline.png)

Android .apk packages are really just .zip archives. You could extract them using the command line, or using the "Xarchiver" program
from the "Accessories" menu. However, you won't be able to read the contents properly. There's an easier way. Select "Extract .apk file"
from the "Android Package Tools" menu. Find the .apk file for "TheLine" in the "apk_storage" folder to extract it. This runs a script
that wraps a program called [Apktool](https://ibotpeaches.github.io/Apktool/). A folder called "com_onetouchgame_TheLine-12" is created,
which contains the extracted contents of the package file.

![Apktool Wrapper](https://raw.githubusercontent.com/kingsBSD/DroidDestructionKit/master/ddkdocs/img/apktool.png)

All Android packages contain a manifest file, called [AndroidManifest.xml](https://developer.android.com/guide/topics/manifest/manifest-intro.html).
You can look at this using the "Gedit" editor under the "Accessories" menu. A web-based file browser has also been provided at [http://localhost:8080/files.html](http://localhost:8080/files.html).
If you navigate to the file, you can right-click on it do download it, and open it with whatever editor you have on your computer.

There is a lot to take in all at once, the manifest provides a lot of information about an app that is not normally disclosed to casual users.
For a start, search for all occurrences of the "uses-permission" tag. Each permission the app requests of the user is listed.
Compare the permissions listed in the PlayStore ("approximate location (network-based)") to those in the manifest
("android.permission.ACCESS_COARSE_LOCATION"). You can look these permissions up on the [Android developer site](https://developer.android.com/reference/android/Manifest.permission.html)
Notice how the permissions are labelled either "normal" or "dangerous", a distinction not made in the PlayStore. Later versions
of Android require users to explicity authorize "dangerous" permissions while an app is running.

The package name "com.onetouchgame.TheLine" is mentioned at the top of the file, but you will notice that many entities from
3rd parties are present, in this case the notification service "jpush.cn" and the analytics service "umeng". The main
"application" tag is divided up between "activities", which run in the foreground and interact with the user, and "services",
which run in the background. Intra and inter-app messages passed between activities and services are called "intents". "receiver"
tags which correspond to [Android BroadcastReciever objects](https://developer.android.com/reference/android/content/BroadcastReceiver.html)
define "intent-filters" that specify what types of message they respond to. (Not all receivers need to be defined in the manifest.)
Looking at the actions covered by the filters can give some idea of what an app is doing, but we can do better by delving into its source-code.
