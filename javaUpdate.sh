#!/bin/bash
#####################################################################################################
# NAME: JavaUpdate
# DESCRIPTION: Updates Java Applet
# ABOUT: Modified version of Peter Loobuyck's script
####################################################################################################

# Determine OS version
osvers=$(sw_vers -productVersion | awk -F. '{print $2}')

# Find Download URL
fileURL=`curl -L http://download.oracle.com/otn-pub/java/jdk/7u51-b15/jre-7u51-macosx-x64.dmg`

# Specify name of downloaded disk image
JavaDMG="/tmp/JavaDMG.dmg"

if [[ "${osvers}" -lt 7 ]]; then
  exit 0
fi

installjava=1

if [ "${installjava}" = 1 ]
then
    echo "Start installing Java"
    if [[ "${osvers}" -ge 7 ]]; then
        # Download the latest Oracle Java 8 software disk image
        /usr/bin/curl --retry 3 -Lo "${JavaDMG}" "${fileURL}"

        # Specify a /tmp/java_eight.XXXX mountpoint for the disk image
        TMPMOUNT=`/usr/bin/mktemp -d /Volumes/java_eight.XXXX`

        # Mount the latest Oracle Java disk image to /tmp/java_eight.XXXX mountpoint
        hdiutil attach "${JavaDMG}" -mountpoint "${TMPMOUNT}" -nobrowse -noverify -noautoopen

        # Install Oracle Java 8 from the installer package.
        if [[ -e "$(/usr/bin/find ${TMPMOUNT} -name *Java*.pkg)" ]]; then
          pkg_path=`/usr/bin/find ${TMPMOUNT} -name *Java*.pkg`
        elif [[ -e "$(/usr/bin/find ${TMPMOUNT} -name *Java*.mpkg)" ]]; then
          pkg_path=`/usr/bin/find ${TMPMOUNT} -name *Java*.mpkg`
        fi

        # Before installation, the installer's developer certificate is checked
        if [[ "${pkg_path}" != "" ]]; then
          /usr/sbin/installer -dumplog -verbose -pkg "${pkg_path}" -target "/" > /dev/null 2>&1
        fi

        # Clean-up
        # Unmount the disk image from /tmp/java_eight.XXXX
        /usr/bin/hdiutil detach -force "${TMPMOUNT}"

        # Remove the /tmp/java_eight.XXXX mountpoint
        /bin/rm -rf "${TMPMOUNT}"

        # Remove the downloaded disk image
        /bin/rm -rf "${JavaDMG}"

        # Remove xml file
        /bin/rm -rf /tmp/au*.xml
    fi
fi

exit 0
