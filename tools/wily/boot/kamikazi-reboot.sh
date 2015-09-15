#!/bin/bash

# V0.8.0 uses this to reboot.

MYNAME=$(hostname)
echo -n "kamikazi-reboot: We are: ${MYNAME}"

if [ "${1}" == "all" ]; then
  supervisorctl start kamikazi-reboot-real
fi
if [ "${1}" == "${MYNAME}" ]; then
  supervisorctl start kamikazi-reboot-real
fi

