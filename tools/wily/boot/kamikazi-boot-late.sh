#!/bin/bash

# V0.8.0 runs this a minute after kamikazi-boot.sh to specialize a system for a task.

# Get into our main directory for it to be the CWD for the rest.
cd /home/git/
KCHOME="/home/git/kamikazi-core"
KCRES="${KCHOME}/resources/latest"

# Install our patched rethinkdb initscript that supports proxy mode.
cp ${KCRES}/mods/etc/init.d/rethinkdb /etc/init.d/rethinkdb

MYNAME=$(hostname)
echo -n "kamikazi-boot-late: We are: ${MYNAME}"


# If we were told to force a specific role, then do so.
if [ -e "/etc/kamikazi-core/role" ]; then
    forcedrole=$(cat /etc/kamikazi-core/role)
    ${KCRES}/config/roles/${forcedrole}

# Otherwise, if a role exists that matches our hostname, then execute it.
elif [ -e "${KCRES}/config/roles/${MYNAME}" ]; then
    ${KCRES}/config/roles/${MYNAME}
fi

# Attempt to find and join any local serf networks.
echo "kamikazi-boot-late-boot: Searching for serf nodes."
serf-join

echo "kamikazi-boot-late-boot: Restarting nginx."
service nginx restart

echo "kamikazi-boot-late-boot: Removing early boot stamp to unlock redeploy."
rm /tmp/kamikazi-boot.stamp

echo "kamikazi-boot-late-boot: Enabling additional log files."
su -l -c ${KCHOME}/tools/enable-logs.sh ubuntu

# If we were told to enable X, then do so.
if [ ! -e "/etc/kamikazi-core/nogui" ]; then
    echo "kamikazi-boot-late-boot: Enabling GUI in 3 seconds."
    sleep 3
    service lightdm start
    echo "kamikazi-boot-late-boot: GUI started."
fi

echo "kamikazi-boot-late-boot: Stopping bootchart."
# Make sure the bootchart collector is dead, no matter what.
pkill -f /lib/bootchart/collector
# Make the stupid upstart script do it's post-stop.
service start bootchart; sleep 1; service stop bootchart;
echo "kamikazi-boot-late-boot: Stopped bootchart."



echo "kamikazi-boot-late-boot: Nothing left to do."

