#!/bin/bash

##################################################
# ABOUT: Screen Sharing
# DESCRIPTION: Give Permissions for Screen Sharing
# NOTES: Created by Bryan Feuling
##################################################

sudo defaults write /var/db/launchd.db/com.apple.launchd/overrides.plist com.apple.screensharing -dict Disabled -bool false
sudo launchctl load /System/Library/LaunchDaemons/com.apple.screensharing.plist

MacUser=$(/bin/ls -l /dev/console | /usr/bin/awk '{ print $3 }')

/System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart \
-activate -configure -access -off -restart -agent -privs -all -allowAccessFor -users "${MacUser}",macsupport
