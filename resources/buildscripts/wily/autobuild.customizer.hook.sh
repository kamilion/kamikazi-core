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
echo "KAMIKAZI: Attempting to rebuild ISO contents..."
cd /home/git/kamikazi-core/resources/buildscripts/wily/
echo "KAMIKAZI: Cleaning old kernels so DKMS does not complain."
apt-get purge -y linux-image* -q
echo "KAMIKAZI: Updating packages to current..."
apt full-upgrade -y
apt-get autoremove --purge -y
echo "KAMIKAZI: Running builder script..."
./00-build-clean-iso-from-source.sh
echo "KAMIKAZI: Installing fresh generic kernel image."
apt-get install -y linux-image-generic -q
echo "KAMIKAZI: Autobuild complete."
exit 0

