#!/bin/bash
echo "KAMIKAZI: Force updating initial package mirror..."
cat > /etc/apt/sources.list <<EOF
deb http://ubuntu.localmsp.org/ubuntu/ wily main restricted universe multiverse
deb http://ubuntu.localmsp.org/ubuntu/ wily-updates main restricted universe multiverse
deb http://ubuntu.localmsp.org/ubuntu/ wily-security main restricted universe multiverse
EOF
echo "KAMIKAZI: Updating package lists..."
apt update
apt list --upgradable
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
echo "KAMIKAZI: Updating package mirror..."
cp -f /home/git/kamikazi-core/resources/latest/mods/etc/apt/sources.list /etc/apt/sources.list
echo "KAMIKAZI: Updating package lists..."
apt update
apt list --upgradable
echo "KAMIKAZI: Enabling squid-deb-proxy-client for local network..."
apt install squid-deb-proxy-client -y
echo "KAMIKAZI: Updating packages to current..."
apt full-upgrade -y
echo "KAMIKAZI: Running builder script..."
./00-build-clean-iso-from-source.sh
echo "KAMIKAZI: Autobuild complete."
exit 0

