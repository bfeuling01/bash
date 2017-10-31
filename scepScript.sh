#!/bin/bash

###########################################################
# TITLE: Computer SCEP mobileconfig
#
# DESCRIPTION: Script to create a SCEP mobileconfig
#              for any company that uses SCEP for Macs
#
# AUTHOR: Created by Bryan Feuling and Sean Boult
###########################################################

# Gets current User ID and Computer Name
CURRUSER=`/bin/ls -l /dev/console | /usr/bin/awk '{ print $3 }'`
COMPNAME=`hostname`

# Profile Information
## Profile mobileconfig requires two different UUIDs
## for the profile to be setup properly. This is
## separate from the SCEP profile below.
PROFNAME="SCEP Computer TEST"
PROFUUID="C35DB5FE-61A2-4448-8D10-2E6E6EA31846"
PROFID="558B54DB-5FF5-4C8F-A7AB-E64A3693C263"
PAYLOADVER=1

# Company/Organization Information
PROFORG=""
PROFDESC="Used for 802.1X WiFi access"

# SCEP Information
## SCEP URL Endpoint
SCEPURL=""

# SCEP Payload Name
SCEPDISPNAME="SCEP Profile"

## SCEP Name
SCEPCANAME="CA-SCEP"

## SCEP Security Type
SCEPKEYTYPE="RSA"
SCEPKEYSIZE="2048"
SCEPSUBJECT="CN"

## SCEP Cert Renewal Time (Number in Days)
CERTRENEWALTIME=14

# SCEP Profile Identifiers
## SCEP profile mobile config requires two different UUIDs
## for the profile to be setup properly.
SCEPPROFUUID="GG69CE46-8AAF-4D74-A8BD-5A13933A1547"
SCEPPROFID="9B95A568-6936-4D48-8C89-4909A5D584B7"

# WiFi Information
# This is to link SCEP with WiFi connection
## Desired SSID
WIFISSID=""

## Desired TLS Trusted Server Name
TLSTRUSTEDSERVERNAME=""

## WiFi Profile Identifiers
### WiFi profile mobile config requires two different
### UUIDs for the profile to be setup properly.
WIFIPROFUUID="F04E7E9D-3B46-422E-B36E-DF79787CD9DC8"
WIFIPROFID="6FC860B4-2166-48C8-8558-A6EFECDC24F7"

### Profile Name
WIFIPROFNAME=""

### WiFi Proxy PAC URL
WIFIPROXY=""

### WiFi TTLS Inner Authorization Type
WIFITTLSINNERAUTH="MSCHAPv2"

### Preferred WiFi Encryption Type
### WPA is WPA2
WIFIENCRYPTIONTYPE="WPA"

### If a computer is using a provisioning network
### that is different than the production network,
### insert the provisioning network in this variable
### and it will be removed from the computer network
### list at the end of the script.
NONDESIREDSSID=""

# FQDN of current computer
FQDN=""

# SCEP service account username and password
USER=""
PASS=""

# cURL request for SCEP
HTTP=`curl -s --ntlm -u $USER:$PASS $SCEPURL`

# Console Log to ensure that the response is received
# properly from the SCEP server
MSSCEPCERT=`echo $HTTP | awk -v FS="(<B> | </B>)" '{print $2}'`
MSSCEPCHALLENGE=`echo $HTTP | awk -v FS="(password is: <B> | </B>)" '{print $3}'`

## Console Log the above returns
echo "SCEP: $MSSCEPCHALLENGE"
echo "SCEPKEY: $MSSCEPCERT"

# SCEP XML mobileconfig payload
# which has the dynamic variables listed above
template="<?xml version='1.0' encoding='UTF-8'?>
<!DOCTYPE plist PUBLIC '-//Apple//DTD PLIST 1.0//EN' 'http://www.apple.com/DTDs/PropertyList-1.0.dtd'>
<plist version='1'>
    <dict>
        <key>PayloadUUID</key>
        <string>$PROFUUID</string>
        <key>PayloadType</key>
        <string>Configuration</string>
        <key>PayloadOrganization</key>
        <string>$PROFORG</string>
        <key>PayloadIdentifier</key>
        <string>$PROFID</string>
        <key>PayloadDisplayName</key>
        <string>$PROFNAME</string>
        <key>PayloadDescription</key>
        <string/>
        <key>PayloadVersion</key>
        <integer>$PAYLOADVER</integer>
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
                <string>$SCEPPROFUUID</string>
                <key>PayloadType</key>
                <string>com.apple.security.scep</string>
                <key>PayloadOrganization</key>
                <string>$PROFORG</string>
                <key>PayloadIdentifier</key>
                <string>$SCEPPROFID</string>
                <key>PayloadDisplayName</key>
                <string>$SCEPDISPNAME</string>
                <key>PayloadDescription</key>
                <string/>
                <key>PayloadVersion</key>
                <integer>$PAYLOADVER</integer>
                <key>PayloadEnabled</key>
                <true/>
                <key>PayloadContent</key>
                <dict>
                    <key>Name</key>
                    <string>$SCEPCANAME</string>
                    <key>URL</key>
                    <string>$SCEPURL</string>
                    <key>Challenge</key>
                    <string>$MSSCEPCHALLENGE</string>
                    <key>Key Type</key>
                    <string>$SCEPKEYTYPE</string>
                    <key>Keysize</key>
                    <integer>$SCEPKEYSIZE</integer>
                    <key>SubjectAltName</key>
                    <dict/>
                    <key>Subject</key>
                    <array>
                        <array>
                            <array>
                                <string>$SCEPSUBJECT</string>
                                <string>$FQDN</string>
                            </array>
                        </array>
                    </array>
                    <key>CertificateRenewalTimeInterval</key>
                    <integer>$CERTRENEWALTIME</integer>
                </dict>
            </dict>
            <dict>
                <key>PayloadUUID</key>
                <string>$WIFIPROFUUID</string>
                <key>PayloadType</key>
                <string>com.apple.wifi.managed</string>
                <key>PayloadOrganization</key>
                <string>$PROFORG</string>
                <key>PayloadIdentifier</key>
                <string>$WIFIPROFID</string>
                <key>PayloadDisplayName</key>
                <string>$WIFIPROFNAME</string>
                <key>PayloadDescription</key>
                <string/>
                <key>PayloadVersion</key>
                <integer>$PAYLOADVER</integer>
                <key>PayloadEnabled</key>
                <true/>
                <key>HIDDEN_NETWORK</key>
                <false/>
                <key>SSID_STR</key>
                <string>$WIFISSID</string>
                <key>EncryptionType</key>
                <string>$WIFIENCRYPTIONTYPE</string>
                <key>PayloadCertificateUUID</key>
                <string>$SCEPPROFUUID</string>
                <key>AutoJoin</key>
                <true/>
                <key>AuthenticationMethod</key>
                <string/>
                <key>Interface</key>
                <string>BuiltInWireless</string>
                <key>ProxyType</key>
                <string>Auto</string>
                <key>ProxyPACURL</key>
                <string>$WIFIPROXY</string>
                <key>EAPClientConfiguration</key>
                <dict>
                    <key>AcceptEAPTypes</key>
                    <array>
                        <integer>13</integer>
                    </array>
                    <key>TTLSInnerAuthentication</key>
                    <string>$WIFITTLSINNERAUTH</string>
                    <key>UserName</key>
                    <string>$FQDN</string>
                    <key>TLSTrustedServerNames</key>
                    <array>
                        <string>$TLSTRUSTEDSERVERNAME</string>
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

# Create the mobile config from the template above
echo $TEMPLATE > /tmp/scep_computer.mobileconfig

# Import the above created template
/usr/bin/profiles -I -F /tmp/scep_computer.mobileconfig

# Check if the mobile config is found in the Profile list
isFound=`profiles -P | grep $PROFID`
if [[ ! -z $isFound ]]; then 
    echo "Profile Successfully Added"
fi

# Remove provisioning network from computer network list
if [ -z $NONDESIREDSSID ]; then
    sudo /usr/sbin/networksetup -removepreferredwirelessnetwork "en0" $NONDESIREDSSID
fi

# exiting script
exit 0
