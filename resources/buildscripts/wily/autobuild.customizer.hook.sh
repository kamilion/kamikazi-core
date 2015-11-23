#!/bin/bash
echo "KAMIKAZI: Updating package lists..."
apt update
apt list --upgradable
echo "KAMIKAZI: Enabling squid-deb-proxy-client for local network..."
apt install squid-deb-proxy-client -y
echo "KAMIKAZI: Installing git."
apt-get install -y --no-install-recommends git
echo "KAMIKAZI: Configuring git."
git config --global user.email "kamilion@gmail.com"
git config --global user.name "Graham Cantin"
git config --global push.default simple
mkdir -p /home/git
cd /home/git
echo "KAMIKAZI: Checking out kamikazi-core repository..."
git clone https://kamilion@github.com/kamilion/kamikazi-core.git
sleep 5
echo "KAMIKAZI: Checking out disker-gui repository..."
git clone https://kamilion@github.com/kamilion/disker-gui.git
sleep 5
echo "KAMIKAZI: Attempting to rebuild ISO contents..."
cd /home/git/kamikazi-core/resources/buildscripts/wily/
git pull
echo "KAMIKAZI: Updating packages to current..."
# Work around annoying recommends
apt-get install -y --no-install-recommends libgs9-common 
# Do the upgrade
apt full-upgrade -y
apt-get autoremove --purge -y
echo "KAMIKAZI: Running builder script..."
./00-build-clean-iso-from-source.sh
apt-get autoremove --purge -y
echo "KAMIKAZI: Autobuild complete."
exit 0

