#!/bin/bash

###########################################################
# TITLE: Computer SCEP mobileconfig
#
# DESCRIPTION: Script to create a SCEP mobileconfig
#              for any company that uses SCEP for Macs
#
# AUTHOR: Created by Bryan Feuling and Sean Boult
###########################################################

currentUser=`/bin/ls -l /dev/console | /usr/bin/awk '{ print $3 }'`
computerName=`hostname`
profileName="SCEP Computer TEST"
profileUUID="C35DB5FE-61A2-4448-8D10-2E6E6EA31846"
profileID="558B54DB-5FF5-4C8F-A7AB-E64A3693C263"

profileOrg=""
profileDesc="Used for 802.1X WIFI access"

#scep stuffz
SCEPurl=""
SCEPCAname="CA-SCEP"
SCEPKeyType="RSA"
SCEPKeySize="2048"
SCEPSubject="CN"
SCEPProfileUUID="GG69CE46-8AAF-4D74-A8BD-5A13933A1547"
SCEPProfileID="9B95A568-6936-4D48-8C89-4909A5D584B7"

#wifi stuffz
WIFISSID=""
WIFITrustedServerName=""
WIFIProfileUUID="F04E7E9D-3B46-422E-B36E-DF79787CD9DC8"
WIFIProfileID="6FC860B4-2166-48C8-8558-A6EFECDC24F7"
WIFIProfileName=""
WIFIProxyPac=""
WIFITTLSInnerAuth="MSCHAPv2"
WIFIEncryptionType="WPA"

FQDN=""

user=""
pass=""

http=`curl -s --ntlm -u $user:$pass <SCEP URL>`

MSSCEPCERT=`echo $http | awk -v FS="(<B> | </B>)" '{print $2}'`
MSSCEPCHALLENGE=`echo $http | awk -v FS="(password is: <B> | </B>)" '{print $3}'`

echo "SCEP: $MSSCEPCHALLENGE"
echo "SCEPKEY: $MSSCEPCERT"

#this is the xml payload that we insert two vars into and make a mobileconfig out of it
template="<?xml version='1.0' encoding='UTF-8'?>
<!DOCTYPE plist PUBLIC '-//Apple//DTD PLIST 1.0//EN' 'http://www.apple.com/DTDs/PropertyList-1.0.dtd'>
<plist version='1'>
	<dict>
		<key>PayloadUUID</key>
		<string>$profileUUID</string>
		<key>PayloadType</key>
		<string>Configuration</string>
		<key>PayloadOrganization</key>
		<string>$profileOrg</string>
		<key>PayloadIdentifier</key>
		<string>$profileID</string>
		<key>PayloadDisplayName</key>
		<string>$profileName</string>
		<key>PayloadDescription</key>
		<string/>
		<key>PayloadVersion</key>
		<integer>1</integer>
		<key>PayloadEnabled</key>
		<true/>
		<key>PayloadRemovalDisallowed</key>
		<true/>
		<key>PayloadScope</key>
		<string>System</string>
		<key>PayloadContent</key>
		<array>
			<dict>
				<key>PayloadUUID</key>
				<string>$SCEPProfileUUID</string>
				<key>PayloadType</key>
				<string>com.apple.security.scep</string>
				<key>PayloadOrganization</key>
				<string>$profileOrg</string>
				<key>PayloadIdentifier</key>
				<string>$SCEPProfileID</string>
				<key>PayloadDisplayName</key>
				<string>TEST</string>
				<key>PayloadDescription</key>
				<string/>
				<key>PayloadVersion</key>
				<integer>1</integer>
				<key>PayloadEnabled</key>
				<true/>
				<key>PayloadContent</key>
				<dict>
					<key>Name</key>
					<string>$SCEPCAname</string>
					<key>URL</key>
					<string>$SCEPurl</string>
					<key>Challenge</key>
					<string>$MSSCEPCHALLENGE</string>
					<key>Key Type</key>
					<string>$SCEPKeyType</string>
					<key>Keysize</key>
					<integer>$SCEPKeySize</integer>
					<key>SubjectAltName</key>
					<dict/>
					<key>Subject</key>
					<array>
						<array>
							<array>
								<string>$SCEPSubject</string>
								<string>$FQDN</string>
							</array>
						</array>
					</array>
					<key>CertificateRenewalTimeInterval</key>
					<integer>14</integer>
				</dict>
			</dict>
			<dict>
				<key>PayloadUUID</key>
				<string>$WIFIProfileUUID</string>
				<key>PayloadType</key>
				<string>com.apple.wifi.managed</string>
				<key>PayloadOrganization</key>
				<string>$profileOrg</string>
				<key>PayloadIdentifier</key>
				<string>$WIFIProfileID</string>
				<key>PayloadDisplayName</key>
				<string>$WIFIProfileName</string>
				<key>PayloadDescription</key>
				<string/>
				<key>PayloadVersion</key>
				<integer>1</integer>
				<key>PayloadEnabled</key>
				<true/>
				<key>HIDDEN_NETWORK</key>
				<false/>
				<key>SSID_STR</key>
				<string>$WIFISSID</string>
				<key>EncryptionType</key>
				<string>$WIFIEncryptionType</string>
				<key>PayloadCertificateUUID</key>
				<string>$SCEPProfileUUID</string>
				<key>AutoJoin</key>
				<true/>
				<key>AuthenticationMethod</key>
				<string/>
				<key>Interface</key>
				<string>BuiltInWireless</string>
				<key>ProxyType</key>
				<string>Auto</string>
				<key>ProxyPACURL</key>
				<string>$WIFIProxyPac</string>
				<key>EAPClientConfiguration</key>
				<dict>
					<key>AcceptEAPTypes</key>
					<array>
						<integer>13</integer>
					</array>
					<key>TTLSInnerAuthentication</key>
					<string>$WIFITTLSInnerAuth</string>
					<key>UserName</key>
					<string>$FQDN</string>
					<key>TLSTrustedServerNames</key>
					<array>
						<string>$WIFITrustedServerName</string>
					</array>
				</dict>
				<key>SetupModes</key>
				<array>
					<string>System</string>
					<string>Loginwindow</string>
				</array>
			</dict>
		</array>
	</dict>
</plist>"

echo $template > /tmp/scep_computer.mobileconfig
/usr/bin/profiles -I -F /tmp/scep_computer.mobileconfig

isFound=`profiles -P | grep $profileID`
if [[ ! -z $isFound ]]; then 
	echo "I found the profile in the list!"
fi

sudo /usr/sbin/networksetup -removepreferredwirelessnetwork "en0" cpn84

exit 0
