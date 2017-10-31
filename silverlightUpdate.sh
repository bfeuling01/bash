#!/bin/bash
#################################################
# NAME: SilverlightUpdate
# DESCRIPTION: Updates Silverlight Player
# ABOUT: Modified version of Ken Aponte's Script
#################################################

# Silverlight Lastest Version URL
LatestVer="http://www.microsoft.com/getsilverlight/locale/en-us/html/Microsoft%20Silverlight%20Release%20History.htm"

# Determine OS version
OS=`sw_vers -productVersion | awk -F. '{print $2}'`

# Current Microsoft Silverlight Version
curr_Vers=`curl -sf "${LatestVer}" 2>/dev/null | grep -m1 "Silverlight 5 Build" | awk -F'[>|<]' '{print $2}' | tr ' ' '\n' | awk '/Build/{getline; print}'`

# Download URL Microsoft Silverlight Version
URL=`curl  -sfA "$UGENT" "http://go.microsoft.com/fwlink/?LinkID=229322" | awk -F'"' '{print $2}' | sed '/^$/d'`
sl_dmg="silverlight.dmg"

if [[ "${OS}" -ge 6 ]]; then
    # Download the latest Microsoft Silverlight software disk image
    /usr/bin/curl --output "${sl_dmg}" "${URL}"

    # Specify a /tmp/silverlight.XXXX mountpoint for the disk image
    TMPMOUNT=`/usr/bin/mktemp -d /tmp/silverlight.XXXX`

    # Mount the latest Silverlight disk image to /tmp/silverlight.XXXX mountpoint
    hdiutil attach "$sl_dmg" -mountpoint "$TMPMOUNT" -nobrowse -noverify -noautoopen

    PKG="`/usr/bin/find $TMPMOUNT -maxdepth 1 \( -iname \*Silverlight*\.pkg -o -iname \*Silverlight*\.mpkg \)`"

    # Check Certificate
    if [[ "${PKG}" != "" ]]; then
       if [[ "${OS}" -ge 7 ]]; then
         signature_check=`/usr/sbin/pkgutil --check-signature "$PKG" | awk /'Developer ID Installer/{ print $5 }'`
         if [[ "${signature_check}" = "Microsoft" ]]; then
           /usr/sbin/installer -dumplog -verbose -pkg "${PKG}" -target "/"
         fi
       fi
       if [[ "${OS}" -eq 6 ]]; then
           /usr/sbin/installer -dumplog -verbose -pkg "${PKG}" -target "/"
       fi
    fi

    # Clean-up
    # Unmount the Microsoft Silverlight disk image from /tmp/silverlight.XXXX
    /usr/bin/hdiutil detach "$TMPMOUNT"

    # Remove the /tmp/silverlight.XXXX mountpoint
    /bin/rm -rf "$TMPMOUNT"

    # Remove the downloaded disk image
    /bin/rm -rf "$SilverlightDMG"
fi

exit 0
