#!/bin/sh

###################################################
# ABOUT: Remove DS Store
# DESCRIPTION: Removes DS Store from Finder
# NOTES: Optimized version of Ken Aponte's Script
###################################################

sudo /usr/bin/find / -name ".DS_Store" -depth -exec rm {} \;

exit 0
