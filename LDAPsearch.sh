#!/bin/bash

LoggedInUser=$(/bin/ls -l /dev/console | /usr/bin/awk '{ print $3 }')

usrInfo=$(ldapsearch -LLL -x -h ldap.directory.ti.com -b "ou=person,o=ti,c=us" idnumber=${LoggedInUser})

usrPhone=$(ldapsearch -LLL -x -h ldap.directory.ti.com -b "ou=person,o=ti,c=us" idnumber=${LoggedInUser} | grep 'telephoneNumber: ' | sed 's/telephoneNumber: //')
usrName=$(ldapsearch -LLL -x -h ldap.directory.ti.com -b "ou=person,o=ti,c=us" idnumber=${LoggedInUser} | grep 'cn: ' | sed 's/cn: //')
usrMail="${LoggedInUser}@ti.com"

echo ${usrPhone}
echo ${usrName}
echo ${usrMail}

dscl . -read /Groups/admin
id -u macsupport
