#!/bin/bash

# Earlier versions than 0.5.0 will run this on boot.

# Get into our main directory for it to be the CWD for the rest.
cd /home/git/

# Deal with our repositories.
zurfa-deploy/tools/pre-update.sh
zurfa-deploy/tools/update-repos.sh
zurfa-deploy/tools/post-update.sh
# Our repositories are up to date.
# Do any post-update installation scripts.
zurfa-deploy/tools/pre-install.sh
zurfa-deploy/tools/do-install.sh

# No longer applies to 0.4.x but commenting it out will have no effect
#  since bash is already running the old version of this from the media.
#zurfa-deploy/tools/post-install.sh

