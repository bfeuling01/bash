#!/bin/bash

###################################################
# ABOUT: Download Brew
# DESCRIPTION: Gets Brew from URL
# NOTES: Optimized version of Ken Aponte's script
###################################################

expect <<- DONE
  spawn /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
  expect "*?RETURN*"
  send -- "\r"
DONE

exit 0
