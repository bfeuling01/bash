#!/bin/bash
## postinstall

LoggedInUser=$(/bin/ls -l /dev/console | /usr/bin/awk '{ print $3 }')
AgentDir="/Users/$LoggedInUser/Library/LaunchAgents"

touch /usr/local/ti/logs/outlook_setup.log
mkdir -m 777 /usr/local/ti/outlook

mkdir $AgentDir
chown -R $LoggedInUser:wheel $AgentDir

cp /tmp/outlook_setup_v2/com.ti.outlook.plist $AgentDir/com.ti.outlook.plist
cp /tmp/outlook_setup_v2/outlook_setup.scpt /usr/local/ti/outlook/outlook_setup.scpt

/bin/chmod 777 /usr/local/ti/logs/outlook_setup.log
/usr/sbin/chown -R $LoggedInUser:wheel /usr/local/ti/outlook
/bin/chmod -R 777 /usr/local/ti/outlook/
/bin/chmod 777 /usr/local/ti/outlook/outlook_setup.scpt
sudo -u $LoggedInUser /bin/launchctl load $AgentDir/com.ti.outlook.plist

exit 0
