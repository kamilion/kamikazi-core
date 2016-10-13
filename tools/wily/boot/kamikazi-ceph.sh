#!/bin/bash

# Check if ceph has configuration around, and fire it up if we find any.
if [ -f /isodevice/boot/config/ceph/ceph.conf ]; then # ceph configuration exists.
    # Check for the bootup oneshot process to complete.
    while ! supervisorctl status kamikazi-boot | grep -q 'EXITED'; do sleep 3; done
    
    if [ -e /etc/kamikazi-core/noceph ]; then # we don't want to start it at boot.
      echo "Kamikazi-ceph: Found a ceph config, but not attempting to start ceph..."
      sleep 15; # This will shut supervisord up about exiting too quickly.
    else
      echo "Kamikazi-ceph: Found a ceph config, attempting to start ceph..."
      
      # In kamikazi, all these services are masked at boot with an .override
      /usr/sbin/service ceph-all start;  # This is a no-op because the rest are 'manual'
      /usr/sbin/service ceph-mon-all start;  # So we should start ceph monitors.
      sleep 30; # then sleep while the monitor starts
      if (service ceph-mon-all status | grep -qs "start/running"); then
        /usr/sbin/service ceph-osd-all start;  # So we should start ceph OSDs with the monitor up.
        sleep 300; # then sleep while the OSDs sync into the cluster, 5 minutes should be enough.
        if (service ceph-osd-all status | grep -qs "start/running"); then
          /usr/sbin/service ceph-mds-all start;  # So we should start ceph-mds with the OSDs up.
        fi
      fi
    fi
else
  sleep 15; # This will shut supervisord up about exiting too quickly.
fi

# And now we should become EXITED to supervisord and any other tasks relying on the above.
