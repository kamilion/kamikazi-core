#!/bin/bash

TIME=0  # Call timerbailout with the number of seconds to bailout after.
abortafter() { sleep 1; let TIME++; if [ ${TIME} -gt ${1} ]; then 
    echo "Kamikazi-boot: Failed to perform action after ${TIME} seconds, moving on...";
    break; fi }

# Stick a singleton in the filesystem to notate we're inside of a boot process.
touch /tmp/kamikazi-boot.stamp

# Get into our main directory for it to be the CWD for the rest.
cd /home/git/


echo "Kamikazi-boot: Attempting to initialize IPMI Board Management Controllers..."

# IPMI: Requirements: None
# Deal with starting up the management controller.
supervisorctl start kamikazi-ipmi

# Check for the oneshot process to complete.
while ! supervisorctl status kamikazi-ipmi | grep -q 'EXITED'; do abortafter 120; done
# Wait for the while loop to break out signalling success.
TIME=0; # Set the timeout to zero

echo "Kamikazi-boot: IPMI initialized, attempting to start the network..."


# NETWORK: Requirements: None, config restored by kamikazi-restore.
# Deal with starting up the network.
supervisorctl start kamikazi-vswitch

# Check for the oneshot process to complete.
while ! supervisorctl status kamikazi-vswitch | grep -q 'EXITED'; do abortafter 120; done
# Wait for the while loop to break out signalling success.
TIME=0; # Set the timeout to zero

echo "Kamikazi-boot: Network start complete, attempting to update from git..."


# GIT: Requirements: Internet access over network
# Deal with updating our repositories.
supervisorctl start kamikazi-deploy

# Check for the oneshot process to complete.
while ! supervisorctl status kamikazi-deploy | grep -q 'EXITED'; do abortafter 120; done
# Wait for the while loop to break out signalling success.
TIME=0; # Set the timeout to zero

echo "Kamikazi-boot: Git update complete, attempting to initialize disk arrays..."


# DISKARRAY: Requirements: SAS HBA.
# Deal with initializing our disk arrays.
supervisorctl start kamikazi-diskarray

# Check for the oneshot process to complete.
while ! supervisorctl status kamikazi-diskarray | grep -q 'EXITED'; do abortafter 120; done
# Wait for the while loop to break out signalling success.
TIME=0; # Set the timeout to zero

echo "Kamikazi-boot: Disk Array initialized, attempting to mount disks..."


# DISKMOUNT: Requirements: BTRFS partitions on disk, with labels set.
# Deal with mounting our disks.
supervisorctl start kamikazi-diskmount

# Check for the oneshot process to complete.
while ! supervisorctl status kamikazi-diskmount | grep -q 'EXITED'; do abortafter 120; done
# Wait for the while loop to break out signalling success.
TIME=0; # Set the timeout to zero


# CEPH: Requirements: network & mounted disks
# Check if ceph has configuration around, and fire it up if we find any.
if [ -f /isodevice/boot/config/ceph/ceph.conf ]; then # ceph configuration exists.
    echo "Kamikazi-boot: Found ceph config, attempting to start ceph-all..."
    /usr/sbin/service ceph-all start;  # So we should start ceph.
fi

echo "Kamikazi-boot: Disks mounted, attempting to start boot-late..."


# LATE: Requirements: All networks should be up & all disks mounted.
# Start the late boot process, now that the deployment is complete.
supervisorctl start kamikazi-boot-late

# Check for the oneshot process to complete.
while ! supervisorctl status kamikazi-boot-late | grep -q 'EXITED'; do sleep 1; done
# And now we should become EXITED to supervisord and any other tasks relying on the above.
