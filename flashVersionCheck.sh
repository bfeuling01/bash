#!/bin/bash

#######################################################
# NAME: Flash Version check
# DESCRIPTION: Checks flash version on machine vs site
# ABOUT: Created by Bryan Feuling
########################################################

#Get Latest Version
LatestFlashVer=`/usr/bin/curl -s http://www.adobe.com/software/flash/about/ | sed -n '/Safari/,/<\/tr/s/[^>]*>\([0-9].*\)<.*/\1/p' | head -1`
echo "Latest Flash Version is ${LatestFlashVer}"

CurrFlashVer=`/usr/bin/defaults read "/Library/Internet Plug-Ins/Flash Player.plugin/Contents/version.plist" CFBundleVersion`
echo "Current Flash Version is ${CurrFlashVer}"

if [ "${LatestFlashVer}" != "${CurrFlashVer}" ]; then
    echo "<result>UpdateRequired</result>"
else
    echo "<result>UpToDate</result>"
fi
