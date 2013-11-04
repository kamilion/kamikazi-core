#!/bin/bash

# V0.5.0 uses this a minute after zurfa-boot.sh

# Get into our main directory for it to be the CWD for the rest.
cd /home/git/
ZDHOME="/home/git/zurfa-deploy"
ZDRES="${ZDHOME}/resources"

# Install our patched rethinkdb initscript that supports proxy mode.
cp ${ZDRES}/rethink/rethinkdb /etc/init.d/rethinkdb

RETHINK=$(which rethinkdb)

MYNAME=$(hostname)
echo -n "zurfa-boot-late: We are: ${MYNAME}"

if [ "${MYNAME}" == "wipemaster" ]; then
    echo "zurfa-boot-late-boot: I am the wipemaster, responsible for data storage."
    echo -e "{\n  "role": "wipemaster"\n}\n" > ${ZDRES}/serf/config-role.json
    sync; sync; sync;
    echo "zurfa-boot-late-boot: Restarting serf agent to change role."
    service serf restart
    echo "zurfa-boot-late-boot: Copying ISO to ram to serve updates for outdated actors."
    cp /isodevice/boot/isos/kamikazi.iso /tmp/kamikazi.iso
    # Mount some stuff and fiddle with rethink's storage location.
    mount LABEL="wipemaster" /srv -o subvol=storage
    swapon UUID="91cb9aed-d19d-4f94-8a1f-93c2e629ba71"
    swapon UUID="011bd987-4492-4fd4-aa6b-e3c137db59e7"
    # We shouldn't have a default instance running.
    cp ${ZDRES}/rethink/wanwipemaster.conf /etc/rethinkdb/instances.d/wanwipemaster.conf
    service rethinkdb start
else
    echo "zurfa-boot-late-boot: I am an actor, I must find a wipemaster."
    MASTER=$(serf members | grep wipemaster | sed "s/    /\t/g" | cut -f 2 )
    echo "zurfa-boot-late-boot: I am an actor, selected wipemaster: ${MASTER}"
    echo "zurfa-boot-late-boot: I am an actor, I must stop rethinkdb."
    service rethinkdb stop
    sleep 3;  # Give rethink a moment to clean up
    echo "zurfa-boot-late-boot: I am an actor, pointing rethinkdb proxy at ${MASTER}."
    # We shouldn't have a default instance running.
    cp ${ZDRES}/rethink/wanwipe.conf /etc/rethinkdb/instances.d/wanwipe.conf
    echo -e "\njoin=${MASTER}:29015\n" >> /etc/rethinkdb/instances.d/wanwipe.conf
    service rethinkdb start
fi



echo "zurfa-boot-late-boot: Restarting nginx."
service nginx restart


echo "zurfa-boot-late-boot: Nothing left to do."

