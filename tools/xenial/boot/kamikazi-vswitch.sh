#!/bin/bash

# V0.8.0 runs this during kamikazi-boot.sh to specialize system networking.

TIME=0  # Call timerbailout with the number of seconds to bailout after.
abortafter() { sleep 1; let TIME++; if [ ${TIME} -gt ${1} ]; then 
    echo "Kamikazi-boot: Failed to perform action after ${TIME} seconds, moving on...";
    break; fi }

MYNAME=$(hostname)
echo "kamikazi-vswitch: We are: ${MYNAME}"

echo "kamikazi-vswitch: Detecting environment..."
VIRTWHAT=$(virt-what)
if [ "${VIRTWHAT:0:6}" == "vmware" ]; then
    VMWAREWHAT=$(vmware-checkvm -p)
    VMWAREWHATHW=$(vmware-checkvm -h)
    echo "kamikazi-vswitch: VMWare ${VMWAREWHAT} environment..."
    echo "kamikazi-vswitch: ${VMWAREWHATHW}"
    sleep 2; # Keeps supervisord from freaking out.
    systemctl start NetworkManager; # Fire up NetworkMangler...
    echo "kamikazi-vswitch: Can't nest VMs, no need to init openvswitch."
    exit 0; # Exit early, we don't need bridges where we're going.
fi

echo "kamikazi-vswitch: Bringing up all openvswitchs."
# First, make sure our bridges are up.
service openvswitch-switch start-bridges

# While the bridges are coming up, we also have to poke chrony.
sleep 1;  # Give openvswitch a headstart to make the external interfaces
TIME=0; # Set the timeout to zero

# We kind of expect to have a external static IP configured in a lot of cases.
if [ ! -e "/etc/kamikazi-core/nodhcp" ]; then  # We should get external dhcp.
    echo "kamikazi-vswitch: Will attempt to DHCP on external interfaces."
    if [ -e "/etc/network/interfaces.d/br0" ]; then  # We have an external if.
        echo "kamikazi-vswitch: Waiting for br0 to come up..."
        while [ ! -d "/sys/class/net/br0" ]; do abortafter 10; done  # Wait for it
        echo "kamikazi-vswitch: Attepting to spawn a dhclient for br0."
        sleep 2;  # Wait for openvswitch to deal with bringing it up.
        dhclient -nw br0;  # If there's a dhcp server, get an IP if needed.
        sleep 2;  # Wait for openvswitch to deal with bringing it up.
    fi
fi

# We don't expect to have a internal static IP configured in a lot of cases.
# Normally it should be set as a static DHCP entry in dhcpd.
TIME=0; # Set the timeout to zero

# Give openvswitch a headstart to make the internal interfaces
if [ -e "/etc/network/interfaces.d/xenbr0" ]; then  # Handle the internal xen bridge.
    echo "kamikazi-vswitch: Waiting for xenbr0 to come up..."
    while [ ! -d "/sys/class/net/xenbr0" ]; do abortafter 10; done  # It exists.
    echo "kamikazi-vswitch: Attepting to spawn a dhclient for xenbr0."
    sleep 2;  # Wait for openvswitch to deal with bringing it up.
    dhclient -nw xenbr0;  # If there's a dhcp server, get another IP if needed.
    sleep 5;  # Wait for openvswitch to deal with bringing it up.
    echo "kamikazi-vswitch: Spawned a dhclient for xenbr0."
fi

echo "kamikazi-vswitch: Attempting to correct system time..."
sleep 5;  # Give dhcp a chance to bring an xenbr0 IP up if needed.
chronyc -a online;  # Tell Chrony to go online.
sleep 3;  # Give chrony 3000ms to do some lookups.
chronyc -a burst 2/5; # Tell Chrony to burst rapidly with other servers.
sleep 3;  # Give chrony 3000ms to get some burst replies.
chronyc -a makestep;  # Tell Chrony now is a good time to make the timestep.
# The main bridges should come up in less than fifteen seconds, hopefully.
echo "kamikazi-vswitch: Stepped system time."

echo "kamikazi-vswitch: Making sure sshd has host-keys..."
# Second, make sure sshd is okay.
dpkg-reconfigure openssh-server
# This will either generate keys or if they already exist, restart sshd
echo "kamikazi-vswitch: Network init completed..."

GOOGLEDOTCOM=$(curl -4s http://google.com/ )
if [ "${GOOGLEDOTCOM:0:12}" == "<HTML><HEAD>" ]; then
    echo "kamikazi-vswitch: IPv4 Network connection success..."
fi

GOOGLEDOTCOMV6=$(curl -6s http://google.com/ )
if [ "${GOOGLEDOTCOMV6:0:12}" == "<HTML><HEAD>" ]; then
    echo "kamikazi-vswitch: IPv6 Network connection success..."
fi

echo "kamikazi-vswitch: Nothing left to do."

