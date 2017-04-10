#!/bin/bash

################################################################
# ABOUT: XCode permissions
# DESCRIPTION: Accepts EULA and downloads apps for Non-Admins
# NOTES: Created by Bryan Feuling
################################################################

sudo dscl . append /Groups/_developer GroupMembership everyone

sudo /usr/sbin/dseditgroup -o edit -a everyone -t group _developer

sudo /usr/sbin/DevToolsSecurity -enable

sudo xattr -dr com.apple.quarantine /Applications/Xcode.app

sudo /Applications/Xcode.app/Contents/Developer/usr/bin/xcodebuild -license accept

sudo installer -dumplog -verbose -pkg /Applications/Xcode.app/Contents/Resources/Packages/XcodeSystemResources.pkg -target /

sudo installer -dumplog -verbose -pkg /Applications/Xcode.app/Contents/Resources/Packages/MobileDevice.pkg -target /

sudo installer -dumplog -verbose -pkg /Applications/Xcode.app/Contents/Resources/Packages/MobileDeviceDevelopment.pkg -target /

sudo /usr/bin/defaults write /Library/Preferences/com.apple.dt.Xcode DVTSkipMobileDeviceFrameworkVersionChecking -bool true
