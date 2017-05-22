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
      
      # In kamikazi, all these services were masked at boot with an .override
      # But systemd changed all that. Now they're all disabled and we have to start them.
      # Right now this code probably won't do anything correctly until the service names are fixed.
      #/bin/systemctl start ceph-all;  # This is a no-op because the rest are 'manual'
      #/bin/systemctl start ceph-mon-all;  # So we should start ceph monitors.
      #sleep 30; # then sleep while the monitor starts
      if (/bin/systemctl status ceph-mon | grep -qs "running"); then
        #/bin/systemctl start ceph-osd-all;  # So we should start ceph OSDs with the monitor up.
        sleep 300; # then sleep while the OSDs sync into the cluster, 5 minutes should be enough.
        if (/bin/systemctl status ceph-mon | grep -qs "running"); then
          #/bin/systemctl start ceph-mds-all;  # So we should start ceph-mds with the OSDs up.
          # There's no way we'll get here because ceph-mon isn't the actual service.
          # Instead, it's some kind of crazy autogenerated crap.
          echo "Kamikazi-ceph: Monitor never came up!";
        fi
      fi
    fi
else
  sleep 15; # This will shut supervisord up about exiting too quickly.
fi

# And now we should become EXITED to supervisord and any other tasks relying on the above.
