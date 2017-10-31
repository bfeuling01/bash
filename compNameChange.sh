#!/bin/bash

##################################################
# ABOUT: Computer Name Update
# DESCRIPTION: Updates Computer Name with Serial
# NOTES: Created by Bryan Feuling
##################################################


function CompName() {
	CompType=$(/usr/sbin/system_profiler SPHardwareDataType | grep "Model Name")
	SerialNumber=$(/usr/sbin/system_profiler SPHardwareDataType | awk '/Serial/ {print $4}')
	if [ "${CompType}" == *"MacBook"* ]; then
		CompName="L${SerialNumber}"
	else
		CompName="D${SerialNumber}"
	fi
	/usr/sbin/scutil --set ComputerName  "${CompName}"
	/usr/sbin/scutil --set LocalHostName "${CompName}"
	/usr/sbin/scutil --set HostName "${CompName}"
	/usr/bin/defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server NetBIOSName "${CompName}"
}

CompName
