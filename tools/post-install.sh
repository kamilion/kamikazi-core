#!/bin/bash

# V0.5.0 Runs this script last during a deploy to deal with restarting services.

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

echo "post-install: Nothing left to do."

