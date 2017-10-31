#!/bin/bash
#####################################################################################################
# NAME: FlashUpdate
# DESCRIPTION: Updates Flash Player
# ABOUT: Modified version of Peter Loobuyck's script
####################################################################################################

dmgfile="flash.dmg"
volname="Flash"

latestver=`/usr/bin/curl -s http://www.adobe.com/software/flash/about/ | sed -n '/Safari/,/<\/tr/s/[^>]*>\([0-9].*\)<.*/\1/p' | head -1`
shortver="${latestver:0:2}"
url=https://fpdownload.adobe.com/get/flashplayer/pdc/"${latestver}"/install_flash_player_osx.dmg
currentinstalledver=`/usr/bin/defaults read "/Library/Internet Plug-Ins/Flash Player.plugin/Contents/version" CFBundleShortVersionString`
if [ "${currentinstalledver}" != "${latestver}" ]; then
  /usr/bin/curl -s -o `/usr/bin/dirname ${0}`/flash.dmg "${url}"
  /usr/bin/hdiutil attach `dirname ${0}`/flash.dmg -nobrowse -quiet
  /usr/sbin/installer -pkg /Volumes/Flash\ Player/Install\ Adobe\ Flash\ Player.app/Contents/Resources/Adobe\ Flash\ Player.pkg -target / > /dev/null
  /bin/sleep 10\
  /usr/bin/hdiutil detach $(/bin/df | /usr/bin/grep ${volname} | awk '{print $1}') -quiet
  /bin/sleep 10
  /bin/rm `/usr/bin/dirname $0`/"${dmgfile}"
  newlyinstalledver=`/usr/bin/defaults read "/Library/Internet Plug-Ins/Flash Player.plugin/Contents/version" CFBundleShortVersionString`
fi

exit 0
