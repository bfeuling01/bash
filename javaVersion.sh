#!/bin/bash

#######################################################
# NAME: Java Version check
# DESCRIPTION: Checks java version on machine vs site
# ABOUT: Created by Bryan Feuling
########################################################

#Get Latest Version
onlineversionmain=`curl -L http://www.java.com/en/download/manual.jsp | grep "Recommended Version" | awk '{ print $4}'`
onlineversionmin1=`curl -L http://www.java.com/en/download/manual.jsp | grep "Recommended Version" | awk '{ print $6}' | awk -F "<" '{ print $1}'`
onlineversionmin="${onlineversionmin1:0:3}"
LatestJavaVer="${onlineversionmain}.${onlineversionmin}"
echo "Latest Java Version is ${LatestJavaVer}"

RESULT=$( /usr/bin/defaults read "/Library/Internet Plug-Ins/JavaAppletPlugin.plugin/Contents/Enabled.plist" CFBundleVersion )
REPORTED_MAJOR_VERSION=`echo "${RESULT}" | awk -F'.' '{print $2}'`
REPORTED_MINOR_VERSION=`echo "${RESULT}" | awk -F'.' '{print $3}'`
echo "Current Java Version is ${REPORTED_MAJOR_VERSION}"."${REPORTED_MINOR_VERSION}"

CurrJavaVer="${REPORTED_MAJOR_VERSION}"."${REPORTED_MINOR_VERSION}"

if [ "${LatestJavaVer}" != "${CurrJavaVer}" ]; then
    echo "<result>UpdateRequired</result>"
else
    echo "<result>UpToDate</result>"
fi
