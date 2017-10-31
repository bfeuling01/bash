#!/bin/bash

##################################################
# ABOUT: Provisioning Script
# DESCRIPTION: Provisions Computer through JAMF
# NOTES: Created by Bryan Feuling
##################################################

# Wait for dock befor executing the rest of the script
# This prevents the script from executing before the
# setup assistant is finished
while true;	do
	myUser=`whoami`
	dockcheck=`ps -ef | grep [/]System/Library/CoreServices/Dock.app/Contents/MacOS/Dock`
	echo "Waiting for file as: ${myUser}"
	sudo echo "Waiting for file as: ${myUser}" >> /var/log/jamf.log
	echo "regenerating dockcheck as ${dockcheck}."

	if [ ! -z "${dockcheck}" ]; then
		echo "Dockcheck is ${dockcheck}, breaking."
		break
	fi
	sleep 1
done

# Global variables
LoggedInUser=$(/usr/libexec/PlistBuddy -c "print :dsAttrTypeStandard\:RealName:0" /dev/stdin <<< "$(dscl -plist . -read /Users/$(stat -f%Su /dev/console) RealName)")
HelpDesk=""
CompanyName=""
ProvisioningNetwork=""

# Generic JAMFHelper screen with Screen Lock to prevent users from
# quitting out of JAMFHelper
function LockScreen() {
	"/Library/Application Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfhelper" \
	-windowType "fs" \
	-heading "Congratulations ${LoggedInUser}" \
	-description "Your Mac is being customized.
	This may take up to 30 minutes, depending on your network speed.
	Please call Central Help Desk at ${HelpDesk} if you need assistance." \
	-icon /System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/com.apple.macbook-retina-space-gray.icns \
	-iconSize "256" \
	-alignDescription "center" \
	-alignHeading "center" &

	sudo /System/Library/CoreServices/RemoteManagement/AppleVNCServer.bundle/Contents/Support/LockScreen.app/Contents/MacOS/LockScreen -session 256
}

# Makes a Plist that allows for a local copy of information for
# later querying
function ProvisionEA() {
	sudo mkdir /usr/local/
	sudo chmod 777 /usr/local/
	sudo /usr/libexec/PlistBuddy -c "add :Status string Not Provisioned" -c "add :ProvisioningScript string 0.0.0" /usr/local/com.${CompanyName}.provisioned.plist &&

	$(LockScreen)

	# Grant System Pane Preferences permissions
	sudo /usr/bin/security authorizationdb write system.preferences allow

	# Grant Printing Pane permissions
	sudo /usr/bin/security authorizationdb write system.preferences.printing allow
	sudo /usr/bin/security authorizationdb write system.print.operator allow
	sudo /usr/sbin/dseditgroup -o edit -n /Local/Default -a everyone -t group lpadmin
	sudo /usr/sbin/dseditgroup -o edit -n /Local/Default -a everyone -t group _lpadmin

	# Grant Network Pane permissions
	sudo /usr/bin/security authorizationdb write system.preferences.network allow
	sudo /usr/bin/security authorizationdb write system.services.systemconfiguration.network allow
}

# Adds to Plist for queriable information
function SetProvision() {
	sudo /usr/libexec/PlistBuddy -c "Set :ProvisioningScript 2.0.0" -c "Set :Status Provisioned" /usr/local/com.${CompanyName}.provisioned.plist
}

# Changes computer name for device
function CompName() {
	CompType=$(/usr/sbin/system_profiler SPHardwareDataType | grep "Model Name")
	SerialNumber=$(/usr/sbin/system_profiler SPHardwareDataType | awk '/Serial/ {print $4}')
	if [[ "${CompType}" == *"MacBook"* ]]; then
		ComputerName="L${SerialNumber}"
	else
		ComputerName="D${SerialNumber}"
	fi
	/usr/sbin/scutil --set ComputerName  "${ComputerName}"
	/usr/sbin/scutil --set LocalHostName "${ComputerName}"
	/usr/sbin/scutil --set HostName "${ComputerName}"
	/usr/bin/defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server NetBIOSName "${ComputerName}"

}

# JAMF API Password can be passed from JAMF Policy execution
JSSAPIpass="${4}"

# Update JAMF EA if needed
function APICall() {
	jssURL=""
	serial=$(/usr/sbin/system_profiler SPHardwareDataType | awk '/Serial/ {print $4}')
	jssAPIUser=""
	jssAPIPass=""

	curl -X PUT -H "Accept: application/xml" -H "Content-type: application/xml" -k -u "${jssAPIUser}:${jssAPIPass}" -d "<computer><extension_attributes><attribute><name>${1}</name><value>${2}</value></attribute></extension_attributes></computer>" "${jssURL}"/computers/serialnumber/"${serial}"
}

function Recon() {
	sudo /usr/local/bin/jamf recon
}

# JAMFHelper function allows for repeated use of JAMFHelper
# for provisioning process
function JAMFHelper() {
	windowType="fs"
	windowPostion="ul"
	alignDescription="center"
	alignHeading="center"

	jhHeading="${2}"
	jhDescription="Your Mac is being customized.
	This may take up to 30 minutes, depending on your network speed.
	Please call Central Help Desk at <number> if you need assistance."

	"/Library/Application Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfhelper" \
	-windowType "$windowType" \
	-heading "$jhHeading" \
	-description "$jhDescription" \
	-icon "${3}" \
	-iconSize "${4}" \
	-alignDescription "$alignDescription" \
	-alignHeading "$alignHeading" &
	jamf policy -trigger "${1}"
}

echo "Running ProvisionEA Function"
ProvisionEA &
echo "ProvisionEA function ran"
echo "Computer Name changing"
CompName &&
echo "Computer name changed"

# Running recon here allows JAMF to register computer name change
echo "Running Recon"
Recon &&
echo "Recon ran"

# Copy the following command for each provisioning policy needed
echo <Logging of following command>
JAMFHelper <Policy Call> <Desired JAMF Helper Message> <Desired Picture/Icon> <Icon Size> &&
echo <Logging of previous command>

# Local record of provision completion and version of provisioning script run
echo "Setting Provision plist"
SetProvision &&
echo "Provision Plist set"

# If EA upadte needed, use the following API Call
echo "Running API Calls"
APICall <EA Name> <EA Information> &&
echo "API calls ran"

# Remove provisioning network, if different than production network
echo "Removing <network>"
sudo networksetup -removepreferredwirelessnetwork ${ProvisioningNetwork}
echo "<network> removed"

# Final Recon policy
echo "Running recon Policy"
Recon
echo "Recon policy ran"

# Kill all JAMFHelper and the LockScreen
sudo /usr/bin/killall jamfhelper
sudo /usr/bin/killall LockScreen

# Final Policy 
JAMFHelper <Policy Call> <Desired JAMF Helper Message> <Desired Picture/Icon> <Icon Size>

exit 0
