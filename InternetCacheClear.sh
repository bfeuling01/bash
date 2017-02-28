#!/bin/sh

#####################################################
# ABOUT: Erase Cache
# DESCRIPTION: Erases Cache
# NOTES: Optimized version of Ken Aponte's script
#####################################################

USER=$(/usr/bin/who | grep console | awk '{print $1}')

/Library/Application\ Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper \
-windowType utility \
-title "Internet Browser Web Cache" \
-heading "Please exit all web pages before continuing" \
-alignHeading center \
-description "You web browser cache will be cleared when you click the button below.  This may take several minutes and you will be notified when the process completes. Thank you for your patience!" \
-icon /System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/ToolbarInfo.icns \
-button1 "Erase Cache" \
-button2 "Cancel" \
-defaultButton 1 \
-cancelButton 2

# If the user clicks Erase Cache
if [ "$?" == "0" ]; then
  echo "Clearing Cache"
  sleep 2
  rm -R /Users/"${USER}"/Library/Caches/Google
# rm -R /Users/"${USER}"/Library/Caches/Firefox
  rm -R /Users/"${USER}"/Library/Caches/com.apple.Safari
  /Library/Application\ Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper \
  -windowType utility \
  -title "Internet Browser Web Cache" \
  -heading "Process Complete" \
  -alignHeading center \
  -description "Your web browser caches have been cleared for Safari, and Google Chrome." \
  -icon /System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/ToolbarSitesFolderIcon.icns \
  -button1 " Exit " \
  -defaultButton 1
  exit 1

# if the user clicks cancel
elif [ "$?" == "2" ]; then
  echo "User canceled cache clear";
  exit 1
fi
