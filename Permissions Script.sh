#!/bin/bash

###############################################
# ABOUT: Permissions Granting
# DESCRIPTION: Gives Network Permissions
#              and Printer Permissions to
#              everyone
# NOTES: Created by Bryan Feuling
###############################################

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

# Grant Date/Time permissions
/usr/bin/security authorizationdb write system.preferences allow
/usr/bin/security authorizationdb write system.preferences.datetime allow

# Grant Energy Saver permissions
/usr/bin/security authorizationdb write system.preferences allow
/usr/bin/security authorizationdb write system.preferences.energysaver allow

exit 0
