#!/bin/bash

wifiOrAirport=$(/usr/sbin/networksetup -listallnetworkservices | grep -Ei '(Wi-Fi|AirPort)')
wirelessDevice=$(networksetup -listallhardwareports | awk "/${wifiOrAirport}/,/Device/" | awk 'NR==2' | cut -d " " -f 2)
productionSSID="halekoa75"
provisioningSSID="cpn84"
prefferedNetworks=$(/usr/sbin/networksetup -listpreferredwirelessnetworks "${wirelessDevice}")
updatedSSID=$(/usr/sbin/networksetup -listpreferredwirelessnetworks "${wirelessDevice}")

echo "Available Wireless Device:" "${wifiOrAirport}"
echo "${prefferedNetworks}"

networksetup -removepreferredwirelessnetwork "${wirelessDevice}" "${provisioningSSID}"
echo "Removed SSID: ${provisioningSSID}"
