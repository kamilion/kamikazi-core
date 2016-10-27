#!/bin/bash

# V0.8.0 uses this to shut down.

MYNAME=$(hostname)
echo "kamikazi-shutdown: We are: ${MYNAME}"

if [ "${1}" == "all" ]; then
  supervisorctl start kamikazi-shutdown-real
fi
if [ "${1}" == "${MYNAME}" ]; then
  supervisorctl start kamikazi-shutdown-real
fi

