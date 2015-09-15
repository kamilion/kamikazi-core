#!/bin/bash

# V0.8.0 runs this a minute after kamikazi-boot.sh to specialize a system for a task.

# First, make sure our bridges are up.
service openvswitch-switch start-bridges

# While the bridges are coming up, we also have to poke chrony.
sleep 1;  # Give openvswitch a headstart to make the external interfaces

# We kind of expect to have a external static IP configured in a lot of cases.
if [ ! -e "/etc/kamikazi-deploy/nodhcp" ]; then  # We should get external dhcp.
    if [ -e "/etc/network/interfaces.d/br0" ]; then  # We have an external if.
        while [ ! -d "/sys/class/net/br0" ]; do sleep 2; done  # Wait for it
        sleep 2;  # Wait for openvswitch to deal with bringing it up.
        dhclient -nw br0;  # If there's a dhcp server, get an IP if needed.
        sleep 2;  # Wait for openvswitch to deal with bringing it up.
    fi
fi

# We don't expect to have a internal static IP configured in a lot of cases.
# Normally it should be set as a static DHCP entry in dhcpd.

# Give openvswitch a headstart to make the internal interfaces
if [ -e "/etc/network/interfaces.d/xenbr0" ]; then  # Handle the internal xen bridge.
    while [ ! -d "/sys/class/net/xenbr0" ]; do sleep 2; done  # It exists.
    sleep 2;  # Wait for openvswitch to deal with bringing it up.
    dhclient -nw xenbr0;  # If there's a dhcp server, get another IP if needed.
    sleep 2;  # Wait for openvswitch to deal with bringing it up.
fi

sleep 1;  # Give dhcp a chance to bring an xenbr0 IP up if needed.
chronyc -a online;  # Tell Chrony to go online.
sleep 3;  # Give chrony 3000ms to do some lookups.
chronyc -a burst 2/5; # Tell Chrony to burst rapidly with other servers.
sleep 3;  # Give chrony 3000ms to get some burst replies.
chronyc -a makestep;  # Tell Chrony now is a good time to make the timestep.
# The main bridges should come up in less than fifteen seconds, hopefully.

# Second, make sure sshd is okay.
dpkg-reconfigure openssh-server
# This will either generate keys or if they already exist, restart sshd

# Get into our main directory for it to be the CWD for the rest.
cd /home/git/
KCHOME="/home/git/kamikazi-core"
KCRES="${KCHOME}/resources/latest"

# Install our patched rethinkdb initscript that supports proxy mode.
cp ${KCRES}/mods/etc/init.d/rethinkdb /etc/init.d/rethinkdb

MYNAME=$(hostname)
echo -n "kamikazi-boot-late: We are: ${MYNAME}"


# If we were told to force a specific role, then do so.
if [ -e "/etc/kamikazi-deploy/role" ]; then
    forcedrole=$(cat /etc/kamikazi-deploy/role)
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
if [ ! -e "/etc/kamikazi-deploy/nogui" ]; then
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

