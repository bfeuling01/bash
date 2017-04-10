#!/bin/bash

##################################################
# ABOUT: Adding Printer
# DESCRIPTION: Uses LPADMIN to add printers
# NOTES: Optimized version of Will Evans's script
##################################################

className="FollowMe(US)"

defaults="-o printer-is-shared=false -o XRHolePunch=23Unit -o XRFinisher=SBFinisher -o XROutputColor=PrintAsGrayscale"

lpadmin -p FollowMe1 -E -v lpd://ysoft1.itg.ti.com/FollowMe -i /tmp/ysoft.ppd -c "${className}" "${defaults}"
lpadmin -p FollowMe2 -E -v lpd://ysoft2.itg.ti.com/FollowMe -i /tmp/ysoft.ppd -c "${className}" "${defaults}"
lpadmin -p FollowMe3 -E -v lpd://ysoft3.itg.ti.com/FollowMe -i /tmp/ysoft.ppd -c "${className}" "${defaults}"
lpadmin -p FollowMe4 -E -v lpd://ysoft4.itg.ti.com/FollowMe -i /tmp/ysoft.ppd -c "${className}" "${defaults}"

cupsenable -E "${className}"
cupsaccept -E "${className}"

lpadmin -d "${className}"

exit 0
