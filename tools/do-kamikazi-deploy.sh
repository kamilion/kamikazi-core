#!/bin/bash

# V0.5.0 Runs this script during a serf deploy to deal with platform updates.

# NOTE: THE ISO FILENAME MUST STAY THE SAME!
KU_URL="http://10.0.5.253/files/tmp/kamikazi.iso"

# Get into our main directory for it to be the CWD for the rest.
cd /home/git/
KDHOME="/home/git/kamikazi-deploy"
KDRES="${KDHOME}/resources"

echo "do-kamikazi-deploy: Going to deploy in the background."

supervisorctl start kamikazi-deploy
