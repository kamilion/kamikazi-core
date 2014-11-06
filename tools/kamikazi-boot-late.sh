#!/bin/bash

# V0.5.0 runs this a minute after kamikazi-boot.sh to specialize a system for a task.

# Get into our main directory for it to be the CWD for the rest.
cd /home/git/
KDHOME="/home/git/kamikazi-deploy"
KDRES="${KDHOME}/resources"

# Install our patched rethinkdb initscript that supports proxy mode.
cp ${KDRES}/mods/etc/init.d/rethinkdb /etc/init.d/rethinkdb

RETHINK=$(which rethinkdb)

MYNAME=$(hostname)
echo -n "kamikazi-boot-late: We are: ${MYNAME}"

if [ "${MYNAME}" == "wipemaster" ]; then
    echo "kamikazi-boot-late-boot: I am the wipemaster, responsible for data storage."
    echo -e '{\n  "role": "wipemaster"\n}\n' > ${KDRES}/serf/config-role.json
    sync; sync; sync;
    echo "kamikazi-boot-late-boot: Restarting serf agent to change role."
    service serf restart
    echo "kamikazi-boot-late-boot: Enabling swap for wipemaster."
    swapon -a
    echo "kamikazi-boot-late-boot: Copying ISO to ram to serve updates for outdated actors."
    cp /isodevice/boot/isos/kamikazi.iso /tmp/kamikazi.iso
    echo "kamikazi-boot-late-boot: Enabling btrfs volume 'wipemaster'."
    echo 'LABEL="wipemaster" /srv btrfs subvol=storage 0 0' >> /etc/fstab
    btrfs device scan  # This should fix the ctree error.
    mount /srv
    echo "kamikazi-boot-late-boot: Enabling RethinkDB instance 'wanwipemaster'."
    cp ${KDRES}/rethink/wanwipemaster.conf /etc/rethinkdb/instances.d/wanwipemaster.conf
    chown -R rethinkdb.rethinkdb /var/lib/rethinkdb
    sync
    sleep 1
    service rethinkdb start
    echo "kamikazi-boot-late-boot: RethinkDB instance 'wanwipemaster' is up"
    echo "kamikazi-boot-late-boot: Disabling diskmonitor for wipemaster."
    supervisorctl stop kamikazi-diskmonitor
    echo "kamikazi-boot-late-boot: Disabling diskworker for wipemaster."
    supervisorctl stop kamikazi-diskworker
    echo "kamikazi-boot-late-boot: Wipemaster should be active."
else
    echo "kamikazi-boot-late-boot: I am an actor, I must find a wipemaster."
    MASTER=$(serf members | grep wipemaster | sed -r "s/:7946//g" | sed -r "s/\s+/\t/g" | cut -f 2 )
    echo "kamikazi-boot-late-boot: I am an actor, selected wipemaster: ${MASTER}"
    if [ "$(lspci | grep MPT)" != "" ]; then  # If it's not blank, we need to load the driver.
        echo "kamikazi-boot-late-boot: MPT-Fusion SAS HBA detected. I must load mptsas."
        modprobe mptsas
    fi
    echo "kamikazi-boot-late-boot: I am an actor, I must stop rethinkdb."
    service rethinkdb stop
    sleep 3;  # Give rethink a moment to clean up
    echo "kamikazi-boot-late-boot: I am an actor, pointing RethinkDB proxy at ${MASTER}."
    cp ${KDRES}/rethink/wanwipe.conf /etc/rethinkdb/instances.d/wanwipe.conf
    sync
    echo -e "\njoin=${MASTER}:29015\n" >> /etc/rethinkdb/instances.d/wanwipe.conf
    mkdir -p /var/lib/rethinkdb/wanwipe/data/
    chown -R rethinkdb.rethinkdb /var/lib/rethinkdb
    sync
    sleep 1
    service rethinkdb start
    echo "kamikazi-boot-late-boot: RethinkDB is up, restarting diskmonitor."
    supervisorctl restart kamikazi-diskmonitor
    echo "kamikazi-boot-late-boot: Actor should be active."
fi



echo "kamikazi-boot-late-boot: Restarting nginx."
service nginx restart

echo "kamikazi-boot-late-boot: Removing early boot stamp to unlock redeploy."
rm /tmp/kamikazi-boot.stamp

echo "kamikazi-boot-late-boot: Enabling additional log files"
su -l -c ${KDHOME}/tools/enable-logs.sh ubuntu

echo "kamikazi-boot-late-boot: Nothing left to do."

