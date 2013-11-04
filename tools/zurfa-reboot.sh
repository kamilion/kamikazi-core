#!/bin/bash

# V0.5.0 uses this to reboot.

MYNAME=$(hostname)
echo -n "zurfa-reboot: We are: ${MYNAME}"

if [ "${1}" == "all" ]; then
  supervisorctl start zurfa-reboot-real
fi
if [ "${1}" == "${MYNAME}" ]; then
  supervisorctl start zurfa-reboot-real
fi

