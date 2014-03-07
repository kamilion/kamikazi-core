#!/bin/bash

# V0.5.0 runs this a minute after zurfa-boot.sh to specialize a system for a task.

# Get into our main directory for it to be the CWD for the rest.
cd /home/git/
ZDHOME="/home/git/zurfa-deploy"
ZDRES="${ZDHOME}/resources"

# Install our patched rethinkdb initscript that supports proxy mode.
cp ${ZDRES}/mods/etc/init.d/rethinkdb /etc/init.d/rethinkdb

RETHINK=$(which rethinkdb)

MYNAME=$(hostname)
echo -n "zurfa-boot-late: We are: ${MYNAME}"

if [ "${MYNAME}" == "wipemaster" ]; then
    echo "zurfa-boot-late-boot: I am the wipemaster, responsible for data storage."
    echo -e '{\n  "role": "wipemaster"\n}\n' > ${ZDRES}/serf/config-role.json
    sync; sync; sync;
    echo "zurfa-boot-late-boot: Restarting serf agent to change role."
    service serf restart
    echo "zurfa-boot-late-boot: Enabling swap for wipemaster."
    swapon -a
    echo "zurfa-boot-late-boot: Copying ISO to ram to serve updates for outdated actors."
    cp /isodevice/boot/isos/kamikazi.iso /tmp/kamikazi.iso
    echo "zurfa-boot-late-boot: Enabling btrfs volume 'wipemaster'."
    echo 'LABEL="wipemaster" /srv btrfs subvol=storage 0 0' >> /etc/fstab
    btrfs device scan  # This should fix the ctree error.
    mount /srv
    echo "zurfa-boot-late-boot: Enabling RethinkDB instance 'wanwipemaster'."
    cp ${ZDRES}/rethink/wanwipemaster.conf /etc/rethinkdb/instances.d/wanwipemaster.conf
    chown -R rethinkdb.rethinkdb /var/lib/rethinkdb
    sync
    sleep 1
    service rethinkdb start
    echo "zurfa-boot-late-boot: RethinkDB instance 'wanwipemaster' is up"
    echo "zurfa-boot-late-boot: Disabling diskmonitor for wipemaster."
    supervisorctl stop zurfa-diskmonitor
    echo "zurfa-boot-late-boot: Disabling diskworker for wipemaster."
    supervisorctl stop zurfa-diskworker
    echo "zurfa-boot-late-boot: Wipemaster should be active."
else
    echo "zurfa-boot-late-boot: I am an actor, I must find a wipemaster."
    MASTER=$(serf members | grep wipemaster | sed "s/    /\t/g" | cut -f 2 )
    echo "zurfa-boot-late-boot: I am an actor, selected wipemaster: ${MASTER}"
    if [ "$(lspci | grep MPT)" != "" ]; then  # If it's not blank, we need to load the driver.
        echo "zurfa-boot-late-boot: MPT-Fusion SAS HBA detected. I must load mptsas."
        modprobe mptsas
    fi
    echo "zurfa-boot-late-boot: I am an actor, I must stop rethinkdb."
    service rethinkdb stop
    sleep 3;  # Give rethink a moment to clean up
    echo "zurfa-boot-late-boot: I am an actor, pointing RethinkDB proxy at ${MASTER}."
    cp ${ZDRES}/rethink/wanwipe.conf /etc/rethinkdb/instances.d/wanwipe.conf
    sync
    echo -e "\njoin=${MASTER}:29015\n" >> /etc/rethinkdb/instances.d/wanwipe.conf
    mkdir -p /var/lib/rethinkdb/wanwipe/data/
    chown -R rethinkdb.rethinkdb /var/lib/rethinkdb
    sync
    sleep 1
    service rethinkdb start
    echo "zurfa-boot-late-boot: RethinkDB is up, restarting diskmonitor."
    supervisorctl restart zurfa-diskmonitor
    echo "zurfa-boot-late-boot: Actor should be active."
fi



echo "zurfa-boot-late-boot: Restarting nginx."
service nginx restart

echo "zurfa-boot-late-boot: Removing early boot stamp to unlock redeploy."
rm /tmp/zurfa-boot.stamp

echo "zurfa-boot-late-boot: Nothing left to do."

