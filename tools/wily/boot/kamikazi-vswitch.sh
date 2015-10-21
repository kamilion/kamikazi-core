#!/bin/bash

# V0.8.0 runs this during kamikazi-boot.sh to specialize system networking.

MYNAME=$(hostname)
echo -n "kamikazi-vswitch: We are: ${MYNAME}"
echo -n "kamikazi-vswitch: Bringing up all openvswitchs."
# First, make sure our bridges are up.
service openvswitch-switch start-bridges

# While the bridges are coming up, we also have to poke chrony.
sleep 1;  # Give openvswitch a headstart to make the external interfaces

# We kind of expect to have a external static IP configured in a lot of cases.
if [ ! -e "/etc/kamikazi-core/nodhcp" ]; then  # We should get external dhcp.
    echo -n "kamikazi-vswitch: Will attempt to DHCP on external interfaces."
    if [ -e "/etc/network/interfaces.d/br0" ]; then  # We have an external if.
        while [ ! -d "/sys/class/net/br0" ]; do sleep 2; done  # Wait for it
        echo -n "kamikazi-vswitch: Attepting to spawn a dhclient for br0."
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
    echo -n "kamikazi-vswitch: Attepting to spawn a dhclient for xenbr0."
    sleep 2;  # Wait for openvswitch to deal with bringing it up.
    dhclient -nw xenbr0;  # If there's a dhcp server, get another IP if needed.
    sleep 5;  # Wait for openvswitch to deal with bringing it up.
    echo -n "kamikazi-vswitch: Spawned a dhclient for xenbr0."
fi

echo -n "kamikazi-vswitch: Attempting to correct system time..."
sleep 5;  # Give dhcp a chance to bring an xenbr0 IP up if needed.
chronyc -a online;  # Tell Chrony to go online.
sleep 3;  # Give chrony 3000ms to do some lookups.
chronyc -a burst 2/5; # Tell Chrony to burst rapidly with other servers.
sleep 3;  # Give chrony 3000ms to get some burst replies.
chronyc -a makestep;  # Tell Chrony now is a good time to make the timestep.
# The main bridges should come up in less than fifteen seconds, hopefully.
echo -n "kamikazi-vswitch: Stepped system time."

echo -n "kamikazi-vswitch: Making sure sshd has host-keys..."
# Second, make sure sshd is okay.
dpkg-reconfigure openssh-server
# This will either generate keys or if they already exist, restart sshd
echo -n "kamikazi-vswitch: Network init completed..."

GOOGLEDOTCOM=$(curl -4s http://google.com/ )
if [ "${GOOGLEDOTCOM:0:12}" == "<HTML><HEAD>" ]; then
    echo -n "kamikazi-vswitch: IPv4 Network connection success..."
fi

GOOGLEDOTCOMV6=$(curl -6s http://google.com/ )
if [ "${GOOGLEDOTCOMV6:0:12}" == "<HTML><HEAD>" ]; then
    echo -n "kamikazi-vswitch: IPv6 Network connection success..."
fi

echo -n "kamikazi-vswitch: Nothing left to do."

