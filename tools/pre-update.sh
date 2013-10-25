#!/bin/bash

# We have no idea how many disks are connected. Hopefully it's less than 96.
echo "pre-update: v0.5.0 Image: Turning off all swap."

for i in {0..96}
  do
    swapoff -a
  done

echo "pre-update: Nothing left to do."


