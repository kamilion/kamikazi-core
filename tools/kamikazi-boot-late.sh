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
    ${KDRES}/tools/roles/${forcedrole}

# Otherwise, if a role exists that matches our hostname, then execute it.
elif [ -e "${KDRES}/tools/roles/${MYNAME}" ]; then
    ${KDRES}/tools/roles/${MYNAME}
fi

# Search for any other serf members on the internal LAN to join up with.
# Serf supports encryption if a key is stored in /isodevice/boot/config/serfkey
# Connections to an encrypted cluster will be denied if the key is missing or incorrect.
MY_ADAPTER="xenbr0"
MY_IPV4ADDRESS="$(ip addr show ${MY_ADAPTER} | grep "inet " | cut -d ' ' -f 6 | cut -d '/' -f 1)"
MY_NETWORK="$(echo ${MY_IPV4ADDRESS} | cut -d '.' -f 1,2,3).0/24"
for i in $(nmap -oG -Pn -p7946 --open ${MY_NETWORK} | grep "report for" | cut -d ' ' -f 6 | tr -d '()')
do
    if [ ${i} != ${MY_IPV4ADDRESS} ]; then
        echo "found serf running on ${i}";
        serf join ${i}
    fi
done

echo "kamikazi-boot-late-boot: Restarting nginx."
service nginx restart

echo "kamikazi-boot-late-boot: Removing early boot stamp to unlock redeploy."
rm /tmp/kamikazi-boot.stamp

echo "kamikazi-boot-late-boot: Enabling additional log files"
su -l -c ${KDHOME}/tools/enable-logs.sh ubuntu

echo "kamikazi-boot-late-boot: Nothing left to do."

