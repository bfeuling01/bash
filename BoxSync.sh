#!/bin/bash

################################################################
# ABOUT: Box Sync Download
# DESCRIPTION: Get Box Sync Download from Download URL
# NOTES: Optimized version of Ken Aponte's script
################################################################

policy="Box Sync 4"
downloadurl="https://e3.boxcdn.net/box-installers/sync/Sync+4+External/Box%20Sync%20Installer.dmg"

function Log() {
  echo "${1}"
  /usr/bin/logger -t "system-log-tag: ${policy}" "${1}"
}

function Mountcheck() {
  if [ -d /tmp/boxsyncdmg ]; then
    if [[ $(mount | awk '/boxsyncdmg/ {print $3, $4}') == "/tmp/boxsyncdmg" ]]; then
      Log "Cleanup: /tmp/boxsyncdmg/ is a mounted volume: unmounting"
      /usr/bin/hdiutil detach /tmp/boxsyncdmg
      if [ $? -eq 0 ]; then
          Log "Cleanup: /tmp/boxsyncdmg successfully unmounted"
      else
          Log "Cleanup: hdiutil error code $?: /tmp/boxsyncdmg failed to unmount"
      fi
    fi
  fi
}

function Cleanup() {
  Log "Cleanup: Starting cleanup items"
  Mountcheck
  if [ -f /tmp/boxsync.dmg ]; then
    Log "Cleanup: Deleting /tmp/boxsync.dmg"
    /bin/rm /tmp/boxsync.dmg
    Log "Cleanup complete."
  fi
}

trap Cleanup exit

Log "Beginning installation of ${policy}"

# Check for the expected size of the downloaded DMG
webfilesize=$(/usr/bin/curl --proxy http://webproxy.ext.ti.com:80 -sf ${downloadurl} -ILs | awk '/Content-Length:/ {print $2}' | tail -n 1 | tr -d '\r')
Log "The expected size of the downloaded file is ${webfilesize}"

/usr/bin/curl --proxy http://webproxy.ext.ti.com:80 -sf "${downloadurl}" -o /tmp/boxsync.dmg
if [ $? -eq 0 ]; then
  Log "The Box Sync Installer DMG successfully downloaded"
else
  Log "curl error code $?: The Box Sync Installer DMG did not successfully download"
  exit 1
fi

# Check the size of the downloaded DMG
dlfilesize=$(/usr/bin/cksum /tmp/boxsync.dmg | awk '{print $2}')
Log "The size of the downloaded file is ${dlfilesize}"

# Compare the expected size against the downloaded size
if [[ "${webfilesize}" -ne "${dlfilesize}" ]]; then
  echo "The file did not download properly"
  exit 1
fi

# Check if the /tmp/boxsyncdmg directory exists and is a mounted volume
Mountcheck

# Mount the /tmp/Box\ Sync\Installer.dmg file
/usr/bin/hdiutil attach /tmp/boxsync.dmg -mountpoint /tmp/boxsyncdmg -nobrowse -noverify
if [ $? -eq 0 ]; then
  Log "/tmp/boxsync.dmg successfully mounted"
else
  Log "hdiutil error code $?: /tmp/boxsync.dmg failed to mount"
  exit 1
fi

# Check for and kill any Box Sync processes
pids=$(/usr/bin/pgrep "Box Sync")
if [ -n "${pids}" ]; then
  for pid in ${pids[@]};
  do
    Log "Found Box Sync process ${pid}: killing"
    /bin/kill "${pid}"
  done
fi

if [ -e /Applications/Box\ Sync.app ]; then
  /bin/rm -rf /Applications/Box\ Sync.app
  Log "Deleted an existing copy of Box Sync.app"
fi

Log "Copying Box Sync.app to /Applications"
/bin/cp -a /tmp/boxsyncdmg/Box\ Sync.app /Applications/
if [ "$?" -eq 0 ]; then
  Log "The file copied successfully"
  /usr/sbin/chown -R root:admin /Applications/Box\ Sync.app
else
  Log "cp error code $?: The file did not copy successfully"
  exit 1
fi

Log "Copying com.box.sync.bootstrapper to /Library/PrivilegedHelperTools"
if [ ! -e /Library/PrivilegedHelperTools ]; then
  /bin/mkdir /Library/PrivilegedHelperTools
fi

/bin/cp -a /Applications/Box\ Sync.app/Contents/Resources/com.box.sync.bootstrapper /Library/PrivilegedHelperTools/

Log "Running com.box.sync.bootstrapper"
/Applications/Box\ Sync.app/Contents/Resources/com.box.sync.bootstrapper --install

sleep 1

Log "Opening Box Sync.app"
/usr/bin/open /Applications/Box\ Sync.app &

Log "Postinstall for ${policy} complete. Running Recon."
/usr/local/bin/jamf recon || Log "jamf error code $?: There was an error running Recon."

exit 0
