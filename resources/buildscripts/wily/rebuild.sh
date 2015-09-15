#!/bin/bash
echo "KAMIKAZI-REBUILD: Cleaning up previous run..."
customizer -t
echo "KAMIKAZI-REBUILD: Extracting ISO..."
customizer -e
echo "KAMIKAZI-REBUILD: Triggering custom hook..."
customizer -k
echo "KAMIKAZI-REBUILD: Fixing xen on ISO..."
cp -f /home/ubuntu/git/kamikazi-core/resources/buildscripts/wily/isomods/* /home/kamikazi-15.10/ISO/isolinux/
rm -f /home/kamikazi-15.10/ISO/wubi.exe
rm -f /home/kamikazi-15.10/ISO/autorun.inf
echo "KAMIKAZI-REBUILD: Building output ISO..."
customizer -r
echo "KAMIKAZI-REBUILD: Complete."
exit 0

