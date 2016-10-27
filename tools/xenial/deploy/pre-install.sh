#!/bin/bash

# V0.8.0 Runs this script fourth during a deploy to deal with obsolete services.

if [ -f /etc/supervisor.d/diskmonitor.ini ]; then
    echo "pre-install: Stopping old diskmonitor if existing..."
    supervisorctl stop diskmonitor
fi
if [ -f /etc/supervisor.d/rq-worker.ini ]; then
    echo "pre-install: Stopping old diskworker if existing..."
    supervisorctl stop rq-worker
fi

echo "pre-install: Syncing disk."
sync

echo "pre-install: Snoozing for a moment so the next script is freshly checked out."
sleep 1

echo "pre-install: Nothing left to do."


