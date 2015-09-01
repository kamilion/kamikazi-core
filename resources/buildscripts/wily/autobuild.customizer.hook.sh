#!/bin/bash
echo "Installing git."
apt-get install -y --no-install-recommends git
echo "Configuring git."
git config --global user.email "kamilion@gmail.com"
git config --global user.name "Graham Cantin"
git config --global push.default simple
mkdir -p /home/git
cd /home/git
echo "Checking out kamikazi-deploy repository..."
git clone https://kamilion@github.com/kamilion/kamikazi-deploy.git
echo "Attempting to rebuild ISO contents..."
cd /home/git/kamikazi-deploy/resources/buildscripts/wily/
apt update
apt full-upgrade
./00-build-clean-iso-from-source.sh
