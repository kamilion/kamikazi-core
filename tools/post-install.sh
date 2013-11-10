#!/bin/bash

# V0.5.0 Runs this script last during a deploy to deal with restarting services.

# Get into our main directory for it to be the CWD for the rest.
cd /home/git/
ZDHOME="/home/git/zurfa-deploy"
ZDRES="${ZDHOME}/resources"

# Does the boot stamp exist? If so, let boot-late handle stuff instead.
if [ ! -f /tmp/zurfa-boot.stamp ]; then
    echo "post-install: Restarting services to pick up any changes."

    echo "post-install: Restarting diskmonitor."
    supervisorctl restart zurfa-diskmonitor

    echo "post-install: Restarting diskworker."
    supervisorctl restart zurfa-diskworker

    echo "post-install: Restarting serf agent."
    service serf restart

    echo "post-install: Restarting RethinkDB."
    service rethinkdb restart

    echo "post-install: Restarting nginx."
    service nginx restart
fi

echo "post-install: Checking for IPMI support..."

IPMI_MANUFACTURER=$(ipmitool mc info | grep "Manufacturer ID" | sed 's/: /:  /g' | sed 's/ \+ /\t/g' | cut -f 3)
IPMI_MODELID=$(ipmitool mc info | grep "Product ID" | sed 's/: /:  /g' | sed 's/ \+ /\t/g' | cut -f 3 | cut -d ' ' -f 1)

echo "post-install: ipmitool says: ${IPMI_MANUFACTURER} ${IPMI_MODELID}"

if [ "${IPMI_MANUFACTURER}" = "6653"  ]; then  # Tyan Computer Corporation
    if [ "${IPMI_MODELID}" = "6673"  ]; then  # ASpeed AST1100?
        echo "post-install: This is a ***REMOVED*** ***REMOVED*** chassis."
        echo "post-install: Updating IPMI credentials and enabling DHCP."
        ipmitool exec ${ZDRES}/ipmi/ipmi-***REMOVED***.txt
    fi
fi

if [ "${IPMI_MANUFACTURER}" = "47488"  ]; then  # Supermicro
    if [ "${IPMI_MODELID}" = "43707"  ]; then  # NuvoTon WPCM450?
        echo "post-install: This is a Supermicro X8DT chassis."
    fi
fi

if [ "${IPMI_MANUFACTURER}" = "20569"  ]; then  # Dell
    if [ "${IPMI_MODELID}" = "52"  ]; then  # AST1100/AST2050 - http://poweredgec.com/latest_fw.html
        echo "post-install: This is a Dell C6100 chassis."
    fi
fi



echo "post-install: Nothing left to do."

