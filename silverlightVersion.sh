#!/bin/bash

#############################################################
# NAME: Silverlight Version check
# DESCRIPTION: Checks silverlight version on machine vs site
# ABOUT: Created by Bryan Feuling
#############################################################

URL="http://www.microsoft.com/getsilverlight/locale/en-us/html/Microsoft%20Silverlight%20Release%20History.htm"

LatestSilverVer=`curl -sf "${URL}" 2>/dev/null | grep -m1 "Silverlight 5 Build" | awk -F'[>|<]' '{print $2}' | tr ' ' '\n' | awk '/Build/{getline; print}'`
echo "Latest Silverlight Version is ${LatestSilverVer}"

CurrSilverVer=`/usr/bin/defaults read "/Library/Internet Plug-Ins/Silverlight.plugin/Contents/Info.plist" CFBundleVersion`
echo "Current Silverlight Version is ${CurrSilverVer}"

if [ "${LatestSilverVer}" != "${CurrSilverVer}" ]; then
    echo "<result>UpdateRequired</result>"
else
    echo "<result>UpToDate</result>"
fi
