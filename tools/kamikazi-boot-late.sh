#!/bin/bash

# V0.5.0 runs this a minute after kamikazi-boot.sh to specialize a system for a task.

# First, make sure our bridges are up.
service openvswitch-switch start-bridges

# Second, make sure sshd is okay.
dpkg-reconfigure openssh-server
# This will either generate keys or if they already exist, restart sshd

# Get into our main directory for it to be the CWD for the rest.
cd /home/git/
KDHOME="/home/git/kamikazi-deploy"
KDRES="${KDHOME}/resources"

# Install our patched rethinkdb initscript that supports proxy mode.
cp ${KDRES}/mods/etc/init.d/rethinkdb /etc/init.d/rethinkdb

MYNAME=$(hostname)
echo -n "kamikazi-boot-late: We are: ${MYNAME}"


# If we were told to force a specific role, then do so.
if [ -e "/etc/kamikazi-deploy/role" ]; then
    forcedrole=$(cat /etc/kamikazi-deploy/role)
    ${KDRES}/config/roles/${forcedrole}

# Otherwise, if a role exists that matches our hostname, then execute it.
elif [ -e "${KDRES}/config/roles/${MYNAME}" ]; then
    ${KDRES}/config/roles/${MYNAME}
fi

# Attempt to find and join any local serf networks.
echo "kamikazi-boot-late-boot: Searching for serf nodes."
/usr/bin/serf-join

echo "kamikazi-boot-late-boot: Restarting nginx."
service nginx restart

echo "kamikazi-boot-late-boot: Removing early boot stamp to unlock redeploy."
rm /tmp/kamikazi-boot.stamp

echo "kamikazi-boot-late-boot: Enabling additional log files."
su -l -c ${KDHOME}/tools/enable-logs.sh ubuntu

# If we were told to enable X, then do so.
if [ ! -e "/etc/kamikazi-deploy/nogui" ]; then
    echo "kamikazi-boot-late-boot: Enabling GUI in 10 seconds."
    sleep 10
    service lightdm start
    echo "kamikazi-boot-late-boot: GUI started."
fi

echo "kamikazi-boot-late-boot: Nothing left to do."

