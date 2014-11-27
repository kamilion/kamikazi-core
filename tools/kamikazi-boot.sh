#!/bin/bash

# V0.5.0 uses this instead of post-boot.sh

btrfs device scan  # Assemble any btrfs arrays early.

touch /tmp/kamikazi-boot.stamp

# Get into our main directory for it to be the CWD for the rest.
cd /home/git/

# Deal with updating our repositories.
supervisorctl start kamikazi-deploy

# Check for the oneshot process to complete.
while ! supervisorctl status kamikazi-deploy | grep -q 'EXITED'; do sleep 1; done
# Wait for the while loop to break out signalling success.

# Start the late boot process, now that the deployment is complete.
supervisorctl start kamikazi-boot-late


# Check for the oneshot process to complete.
while ! supervisorctl status kamikazi-boot-late | grep -q 'EXITED'; do sleep 1; done
# And now we should become EXITED to supervisord and any other tasks relying on the above.
