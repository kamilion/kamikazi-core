#!/bin/bash

cd /home/git/
# for each folder, git pull
for D in */; do 
  cd ${D};  # Go into the repository.
  git stash;  # Stash any changes.
  git pull;  # Pull updates.
  git stash pop;  # Unstash changes (May fail!)
  cd ..;  # Go out of the repository.
done
