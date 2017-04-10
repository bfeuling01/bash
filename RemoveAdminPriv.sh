#!/bin/sh

####################################################
# ABOUT: Remove User from Admin Group
# DESCRIPTION: Removes local users from Admin group
# NOTES: Script from etippett on JAMF Nation
####################################################

adminUsers=$(dscl . -read Groups/admin GroupMembership | cut -c 18-)

for user in $adminUsers
do
    if [ "$user" != "root" ]  && [ "$user" != "macsupport" ]
    then
        dseditgroup -o edit -d $user -t user admin
        if [ $? = 0 ]; then echo "Removed user $user from admin group"; fi
    else
        echo "Admin user $user left alone"
    fi
done
