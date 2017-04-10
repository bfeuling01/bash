#!/bin/bash

# Grant System Preferences permissions
/usr/bin/security authorizationdb write system.preferences allow

# Grant Printing Pane permissions
/usr/bin/security authorizationdb write system.preferences.printing allow
/usr/bin/security authorizationdb write system.print.operator allow
/usr/sbin/dseditgroup -o edit -n /Local/Default -a everyone -t group lpadmin
/usr/sbin/dseditgroup -o edit -n /Local/Default -a everyone -t group _lpadmin

# Grant Energy Saver permissions
/usr/bin/security authorizationdb write system.preferences.energysaver allow

# Grant Date Time permissions
/usr/bin/security authorizationdb write system.preferences.datetime allow

# Grant Network Pane permissions
/usr/bin/security authorizationdb write system.preferences.network allow
/usr/bin/security authorizationdb write system.services.systemconfiguration.network allow
